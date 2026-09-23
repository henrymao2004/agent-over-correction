FROM python:3.11-slim
ARG HERMES_VERSION=
RUN apt-get update \
    && apt-get install -y --no-install-recommends bash ca-certificates curl git ripgrep xz-utils \
    && rm -rf /var/lib/apt/lists/*
RUN set -euo pipefail; \
    branch_flag=""; \
    if [ -n "${HERMES_VERSION}" ]; then branch_flag="--branch ${HERMES_VERSION}"; fi; \
    curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh \
      | bash -s -- --skip-setup --skip-browser ${branch_flag}; \
    export PATH="/root/.local/bin:${PATH}"; \
    hermes version
