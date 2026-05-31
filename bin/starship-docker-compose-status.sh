#!/usr/bin/env bash
# Status dos containers do docker compose do diretório atual (ex.: 3/5 on).

set -uo pipefail

command -v docker >/dev/null 2>&1 || exit 1

compose=""
for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  if [[ -f "$f" ]]; then
    compose="$f"
    break
  fi
done
[[ -n "$compose" ]] || exit 1

if docker compose version >/dev/null 2>&1; then
  dc() { docker compose -f "$compose" "$@"; }
else
  dc() { docker-compose -f "$compose" "$@"; }
fi

mapfile -t services < <(dc config --services 2>/dev/null)
[[ ${#services[@]} -gt 0 ]] || exit 1

declare -A state
while read -r svc st; do
  [[ -n "$svc" && -n "$st" ]] || continue
  if [[ "${state[$svc]:-}" != "running" ]]; then
    state[$svc]="$st"
  fi
done < <(dc ps -a --format '{{.Service}} {{.State}}' 2>/dev/null)

total=${#services[@]}
running=0
for svc in "${services[@]}"; do
  [[ "${state[$svc]:-}" == "running" ]] && ((running++)) || true
done

if (( running == total )); then
  printf '%d/%d on' "$running" "$total"
elif (( running == 0 )); then
  printf '%d/%d off' "$running" "$total"
else
  printf '%d/%d on' "$running" "$total"
fi
