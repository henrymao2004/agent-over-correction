FROM python:3.11-slim
ARG OPENCODE_VERSION=1.17.1
ARG GOAL_PLUGIN_SPEC=@prevalentware/opencode-goal-plugin@0.1.1
ENV NVM_DIR=/root/.nvm
RUN apt-get update \
    && apt-get install -y --no-install-recommends bash ca-certificates curl git xz-utils \
    && rm -rf /var/lib/apt/lists/*
RUN set -eo pipefail; \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash; \
    . "${NVM_DIR}/nvm.sh"; \
    nvm install 22; \
    nvm alias default 22; \
    npm install -g "opencode-ai@${OPENCODE_VERSION}"; \
    opencode plugin -g "${GOAL_PLUGIN_SPEC}"; \
    opencode --version; \
    opencode debug config > /tmp/opencode-config.json; \
    grep -F '@prevalentware/opencode-goal-plugin' /tmp/opencode-config.json
