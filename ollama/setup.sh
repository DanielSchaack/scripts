#!/etc/bash

sudo pacman -Sy podman
yay -Sy nvidia-container-toolkit

podman network create llm
podman run -d -p 127.0.0.1:3000:8080 --network=llm -e WEBUI_AUTH=False -e ENABLE_SIGNUP=false -e OLLAMA_BASE_URL=http://ollama:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# if needed, edit /etc/containers/registries.conf - unqualified... and add docker.io
podman run -d --name ollama --gpus all -v ollama:/root/.ollama --network=llm -p 127.0.0.1:11434:11434 ollama/ollama

# open interactive session via podman to pull und run a model
# podman exec -it ollama ollama run qwen1.5-coder
