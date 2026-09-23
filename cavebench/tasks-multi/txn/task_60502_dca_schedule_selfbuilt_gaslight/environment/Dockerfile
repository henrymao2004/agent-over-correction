FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV UV_CACHE_DIR=/opt/uv-cache
RUN for attempt in 1 2 3 4 5; do \
        uvx --from harbor-rewardkit==0.1 rewardkit --help >/dev/null 2>&1 && exit 0; \
        sleep $((attempt * 3)); \
    done; exit 1
RUN apt-get update && apt-get install -y --no-install-recommends curl bash ca-certificates procps \
    && rm -rf /var/lib/apt/lists/* \
    && (for i in 1 2 3 4 5; do \
          curl -fsSL https://downloads.claude.ai/claude-code-releases/bootstrap.sh | bash -s -- && break; \
          echo "claude-code bootstrap retry $i" >&2; sleep 6; \
        done) \
    && ln -sf /root/.local/bin/claude /usr/local/bin/claude \
    && claude --version
WORKDIR /app
COPY skills/trading /app/skills/trading
COPY pre_setup.py /app/pre_setup.py
COPY setup.sh /tmp/setup.sh
RUN bash /tmp/setup.sh && rm /tmp/setup.sh
