#!/usr/bin/env bash
set -Eeuo pipefail

device="${1:-all}"

case "$device" in
  all)
    jq -cn '{
      include: [
        {device: "phone-3a", manifest: "manifests/sm7635/phone-3a.json"},
        {device: "phone-3a-pro", manifest: "manifests/sm7635/phone-3a-pro.json"},
        {device: "phone-4a", manifest: "manifests/sm7635/phone-4a.json"}
      ]
    }'
    ;;
  phone-3a|phone-3a-pro|phone-4a)
    jq -cn \
      --arg device "$device" \
      --arg manifest "manifests/sm7635/$device.json" \
      '{include: [{device: $device, manifest: $manifest}]}'
    ;;
  *)
    printf 'Unsupported device: %s\n' "$device" >&2
    exit 2
    ;;
esac
