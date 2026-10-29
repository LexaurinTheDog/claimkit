#!/usr/bin/env bash
# Run OpenUI (wandb/openui) locally for spec mockups. See docs/factory/MOCKUPS.md.
#
#   ./.factory/scripts/openui.sh up       # start on http://127.0.0.1:7878
#   ./.factory/scripts/openui.sh down
#   ./.factory/scripts/openui.sh status
#
# Pinned by digest. Bound to loopback only. Models come from the local Ollama; no
# provider API keys and no wandb credentials are passed in, so nothing leaves the
# machine except the mockup preview's CDN requests for Tailwind.

set -euo pipefail

IMAGE="ghcr.io/wandb/openui@sha256:5495cec13b7212a6b1766df317c3541acecfb8173531ebdfe700689fbb822eac"
NAME="factory-openui"
PORT="${OPENUI_PORT:-7878}"

command -v docker >/dev/null 2>&1 || { echo "error: docker is required" >&2; exit 2; }

running() { [ -n "$(docker ps -q --filter "name=^${NAME}$")" ]; }

case "${1:-status}" in
  up)
    if running; then echo "OpenUI already running: http://127.0.0.1:${PORT}"; exit 0; fi
    docker run -d --rm --name "$NAME" \
      -p "127.0.0.1:${PORT}:7878" \
      -e OPENUI_ENVIRONMENT=local \
      -e OLLAMA_HOST=http://host.docker.internal:11434 \
      "$IMAGE" >/dev/null
    for _ in $(seq 1 60); do
      curl -sf -o /dev/null "http://127.0.0.1:${PORT}/" && { echo "OpenUI running: http://127.0.0.1:${PORT}"; exit 0; }
      sleep 1
    done
    echo "error: OpenUI did not answer within 60s; see: docker logs $NAME" >&2
    exit 1
    ;;
  down)
    running && docker stop "$NAME" >/dev/null
    echo "OpenUI stopped"
    ;;
  status)
    if running; then echo "OpenUI running: http://127.0.0.1:${PORT}"; else echo "OpenUI not running"; exit 1; fi
    ;;
  *)
    echo "usage: $0 up|down|status" >&2
    exit 2
    ;;
esac
