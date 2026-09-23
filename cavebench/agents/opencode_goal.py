
import copy
import os
from typing import Any, override

from harbor.agents.installed.opencode import OpenCode
from harbor.environments.base import BaseEnvironment


class OpenCodeGoal(OpenCode):

    GOAL_PLUGIN_PACKAGE = "@prevalentware/opencode-goal-plugin"
    GOAL_PLUGIN_VERSION = "0.1.1"
    GOAL_PLUGIN_SPEC = f"{GOAL_PLUGIN_PACKAGE}@{GOAL_PLUGIN_VERSION}"
    OPENCODE_VERSION = "1.17.1"

    def __init__(
        self,
        *args: Any,
        opencode_config: dict[str, Any] | None = None,
        version: str | None = None,
        **kwargs: Any,
    ) -> None:
        goal_options: dict[str, Any] = {
            "auto_continue": True,
            "defer_while_tasks_active": True,
            "max_auto_turns": 25,
            "max_goal_duration_seconds": 1800,
        }
        config = copy.deepcopy(opencode_config) if opencode_config else {}






        anthropic_base_url = os.environ.get("ANTHROPIC_BASE_URL")
        if anthropic_base_url:
            provider_config = config.setdefault("provider", {}).setdefault(
                "anthropic", {}
            )
            provider_config.setdefault("options", {})["baseURL"] = (
                anthropic_base_url.rstrip("/")
            )

        configured_plugins = config.get("plugin", [])
        if not isinstance(configured_plugins, list):
            raise ValueError("opencode_config.plugin must be a list")

        merged_plugins: list[Any] = []
        goal_plugin_seen = False
        for entry in configured_plugins:
            package = entry[0] if isinstance(entry, list) and entry else entry
            if package != self.GOAL_PLUGIN_PACKAGE:
                merged_plugins.append(entry)
                continue
            goal_plugin_seen = True
            supplied_options = (
                entry[1]
                if isinstance(entry, list)
                and len(entry) > 1
                and isinstance(entry[1], dict)
                else {}
            )
            merged_plugins.append(
                [self.GOAL_PLUGIN_PACKAGE, {**goal_options, **supplied_options}]
            )

        if not goal_plugin_seen:
            merged_plugins.insert(0, [self.GOAL_PLUGIN_PACKAGE, goal_options])
        config["plugin"] = merged_plugins

        super().__init__(
            *args,
            opencode_config=config,
            version=version or self.OPENCODE_VERSION,
            **kwargs,
        )

    @override
    async def install(self, environment: BaseEnvironment) -> None:




        await self.exec_as_agent(
            environment,
            command=(
                "set -euo pipefail; "
                ". ~/.nvm/nvm.sh; "
                "opencode --version && "
                "mkdir -p /logs/agent/setup && "
                "opencode debug config "
                "> /logs/agent/setup/opencode-config.json && "
                f"grep -F {self.GOAL_PLUGIN_PACKAGE} "
                "/logs/agent/setup/opencode-config.json >/dev/null && "
                f"printf '%s\\n' {self.GOAL_PLUGIN_SPEC} "
                "> /logs/agent/setup/opencode-goal-plugin.txt"
            ),
        )
