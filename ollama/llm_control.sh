#!/bin/bash
BROWSER="chromium"

usage() {
    echo "Usage: $0 [OPTIONS] [ARGUMENTS...]"
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -su, --setup DRIVER     Either 'nvidia' or 'amd'. Installs podman and required packages for ollama GPU usage and open-webui"
    echo "  -s, --start BROWSER     Default: BROWSER=chromium. Start open-webui and ollama, and opens a window in BROWSER"
    echo "  -e, --end               Stops open-webui and ollama"
    echo "  -u, --upgrade           Stops and deletes open-webui and ollama, pulls new versions from main"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h | --help)
            usage
            exit 0
            ;;
        -su | --setup)
            SETUP=true
            DRIVER="$2"
            shift
            shift
            ;;
        -s | --start)
            START=true
            if [[ ! -z "$2" ]];then
                BROWSER="$2"
            fi
            shift
            shift
            ;;
        -e | --end)
            END=true
            shift
            ;;
        -u | --upgrade)
            UPGRADE=true
            shift
            ;;
    esac
done


if [[ $SETUP ]]; then
    case $DRIVER in
        "nvidia")
            sudo pacman -Sy podman
            yay -Sy nvidia-container-toolkit
            podman network create llm
            podman run -d -p 127.0.0.1:3000:8080 --network=llm -e WEBUI_AUTH=False -e ENABLE_SIGNUP=false -e OLLAMA_BASE_URL=http://ollama:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
            # if needed, edit /etc/containers/registries.conf - unqualified... and add docker.io
            podman run -d --name ollama --gpus all -v ollama:/root/.ollama --network=llm -p 127.0.0.1:11434:11434 ollama/ollama
            ;;
        "amd")
            echo "Not yet implemented"
            sudo pacman -Sy podman
            yay -Sy nvidia-container-toolkit
            podman network create llm
            podman run -d -p 127.0.0.1:3000:8080 --network=llm -e WEBUI_AUTH=False -e ENABLE_SIGNUP=false -e OLLAMA_BASE_URL=http://ollama:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
            # podman run -d --name ollama --gpus all -v ollama:/root/.ollama --network=llm -p 127.0.0.1:11434:11434 ollama/ollama
            ;;
        *)
            echo "It is 'nvidia' or 'amd' you bum"
            ;;
    esac
fi

if [[ "$UPGRADE" = true ]]; then
    podman stop open-webui 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "Removing open-webui"
        podman rm open-webui
    fi
    podman pull ghcr.io/open-webui/open-webui:main
    podman create -p 127.0.0.1:3000:8080 --network=llm -e WEBUI_AUTH=False -e ENABLE_SIGNUP=false -e OLLAMA_BASE_URL=http://ollama:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

    podman stop ollama 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "Removing ollama"
        podman rm ollama 
    fi
    podman pull ollama/ollama
    podman create --name ollama --gpus all -v ollama:/root/.ollama --network=llm -p 127.0.0.1:11434:11434 ollama/ollama
fi

if [[ "$START" = true ]]; then
    podman start open-webui 2>/dev/null
    if [[ $? -ne 0 ]]; then
        podman run -d -p 127.0.0.1:3000:8080 --network=llm -e WEBUI_AUTH=False -e ENABLE_SIGNUP=false -e OLLAMA_BASE_URL=http://ollama:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
    fi

    podman start ollama 2>/dev/null
    if [[ $? -ne 0 ]]; then
        podman run -d --name ollama --gpus all -v ollama:/root/.ollama --network=llm -p 127.0.0.1:11434:11434 ollama/ollama
    fi

    echo "Waiting 10 seconds for the containers to properly start"
    sleep 10
    "$BROWSER" "127.0.0.1:3000"
fi

if [[ "$END" = true ]]; then
    podman stop open-webui
    podman stop ollama
fi


