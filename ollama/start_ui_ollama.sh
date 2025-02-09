#!/usr/bin/bash

podman start open-webui
podman start ollama
chromium 127.0.0.1:3000
