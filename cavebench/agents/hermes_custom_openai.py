
import json
import os
from typing import override

import yaml
from harbor.agents.base import AgentContext
from harbor.agents.installed import hermes as hermes_module
from harbor.agents.installed.hermes import Hermes
from harbor.environments.base import BaseEnvironment





_openai_keys = hermes_module._NATIVE_PROVIDERS["openai"][1]
hermes_module._NATIVE_PROVIDERS["openai"] = ("custom", _openai_keys)


class HermesCustomOpenAI(Hermes):

    @override
    async def install(self, environment: BaseEnvironment) -> None:




        await self.exec_as_root(
            environment,
            command="apt-get update && apt-get install -y curl git ripgrep xz-utils",
            env={"DEBIAN_FRONTEND": "noninteractive"},
        )
        branch_flag = f" --branch {self._version}" if self._version else ""
        await self.exec_as_agent(
            environment,
            command=(
                "set -euo pipefail; "
                'mkdir -p "$HOME/.local/bin"; '
                "printf '#!/bin/sh\\necho \\\"ffmpeg version cave-stub\\\"\\n' "
                '>"$HOME/.local/bin/ffmpeg"; '
                'chmod +x "$HOME/.local/bin/ffmpeg"; '
                'export PATH="$HOME/.local/bin:$PATH"; '
                "curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh "
                f"| bash -s -- --skip-setup --skip-browser{branch_flag} && "
                'export HERMES_HOME="${HERMES_HOME:-/tmp/hermes}" && '
                'mkdir -p "$HERMES_HOME" "$HERMES_HOME/sessions" '
                '"$HERMES_HOME/skills" "$HERMES_HOME/memories" && '
                "hermes version"
            ),
        )

    @staticmethod
    def _build_config_yaml(model: str) -> str:
        base_url = os.environ.get("OPENAI_BASE_URL")
        api_key = os.environ.get("OPENAI_API_KEY")
        if bool(base_url) != bool(api_key):
            raise ValueError("Set OPENAI_BASE_URL and OPENAI_API_KEY together")
        if base_url and api_key:
            model_config: str | dict[str, object] = {
                "default": model,
                "provider": "custom",
                "base_url": base_url,
                "api_key": api_key,
                "context_length": 200_000,
            }
            provider = None
        elif os.environ.get("OPENROUTER_API_KEY"):
            model_config = model
            provider = "auto"
        else:
            raise ValueError(
                "Set OPENAI_BASE_URL and OPENAI_API_KEY, or set OPENROUTER_API_KEY"
            )

        config = {
            "model": model_config,
            "toolsets": ["hermes-cli"],
            "agent": {"max_turns": 90},
            "memory": {
                "memory_enabled": False,
                "user_profile_enabled": False,
            },
            "compression": {"enabled": True, "threshold": 0.85},
            "terminal": {"backend": "local", "timeout": 180},
            "delegation": {"max_iterations": 50},
            "checkpoints": {"enabled": False},
        }
        if provider:
            config["provider"] = provider
        return yaml.dump(config, default_flow_style=False)

    def _convert_hermes_session_to_atif(
        self, jsonl_text: str, session_id: str
    ):
        records: list[dict[str, object]] = []
        for line in jsonl_text.splitlines():
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                continue
            if isinstance(record, dict):
                records.append(record)





        seen = getattr(self, "_cave_seen_hermes_session_ids", set())
        current = [
            record
            for record in records
            if not record.get("id") or record.get("id") not in seen
        ]
        if not current:
            return None
        self._cave_seen_hermes_session_ids = seen | {
            record["id"] for record in current if record.get("id")
        }
        current_jsonl = "\n".join(json.dumps(record) for record in current)

        trajectory = super()._convert_hermes_session_to_atif(
            current_jsonl, session_id
        )
        if trajectory is None:
            return None





        input_tokens = 0
        output_tokens = 0
        for record in current:
            input_tokens += int(record.get("input_tokens") or 0)
            output_tokens += int(record.get("output_tokens") or 0)

        if input_tokens > 0 or output_tokens > 0:
            trajectory.final_metrics.total_prompt_tokens = input_tokens
            trajectory.final_metrics.total_completion_tokens = output_tokens
        return trajectory

    @override
    async def run(
        self,
        instruction: str,
        environment: BaseEnvironment,
        context: AgentContext,
    ) -> None:
        try:
            await super().run(instruction, environment, context)
        finally:



            await self.exec_as_agent(
                environment,
                command=(
                    'export PATH="$HOME/.local/bin:$PATH" && '
                    "hermes sessions export /logs/agent/hermes-session.jsonl "
                    "2>/dev/null || true"
                ),
                env={"HERMES_HOME": "/tmp/hermes"},
                timeout_sec=30,
            )
