#!/bin/sh
# Quiesce the RTL8125 right before reboot so the next OS (Windows) gets a
# clean chip. Best-effort: removing the PCI device drops it to D3.
DEV=$(basename "$(readlink -f /sys/class/net/eno1/device 2>/dev/null)")
[ -n "$DEV" ] && [ -e "/sys/bus/pci/devices/$DEV/remove" ] && \
  echo 1 > "/sys/bus/pci/devices/$DEV/remove" 2>/dev/null
exit 0
