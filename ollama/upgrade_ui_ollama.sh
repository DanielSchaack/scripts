#!/usr/bin/bash
podman stop open-webui && podman rm open-webui && podman pull ghcr.io/open-webui/open-webui:main
podman run -d -p 127.0.0.1:3000:8080 --network=llm -e WEBUI_AUTH=False -e ENABLE_SIGNUP=false -e OLLAMA_BASE_URL=http://ollama:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

podman stop ollama && podman rm ollama && podman pull ollama/ollama
podman run -d --name ollama --gpus all -v ollama:/root/.ollama --network=llm -p 127.0.0.1:11434:11434 ollama/ollama
