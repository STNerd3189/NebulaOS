FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    powershell \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace

CMD ["bash", "-lc", "pwd && ls -la"]
