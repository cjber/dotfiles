#!/bin/bash

status=$(tailscale status --json 2>/dev/null)

if [[ -z "$status" ]]; then
    echo '{"text":"󰖂 off","class":"disconnected","tooltip":"Tailscale is not running"}'
    exit 0
fi

backend_state=$(echo "$status" | jq -r '.BackendState // empty')
self_ip=$(echo "$status" | jq -r '.TailscaleIPs[0] // empty')
hostname=$(echo "$status" | jq -r '.Self.HostName // empty')
peers=$(echo "$status" | jq '[.Peer[] | select(.Online == true)] | length')

case "$backend_state" in
    Running)
        tooltip="Tailscale connected\nIP: ${self_ip}\nHostname: ${hostname}\nOnline peers: ${peers}"
        echo "{\"text\":\"󰖂\",\"class\":\"connected\",\"tooltip\":\"${tooltip}\"}"
        ;;
    Stopped)
        echo '{"text":"󰖂 off","class":"disconnected","tooltip":"Tailscale is stopped"}'
        ;;
    NeedsLogin)
        echo '{"text":"󰖂 login","class":"warning","tooltip":"Tailscale needs re-authentication"}'
        ;;
    *)
        echo "{\"text\":\"󰖂 ${backend_state}\",\"class\":\"warning\",\"tooltip\":\"Tailscale: ${backend_state}\"}"
        ;;
esac
