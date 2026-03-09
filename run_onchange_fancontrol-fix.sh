#!/bin/bash
# Deploy fancontrol auto-fix script and systemd drop-in
# This ensures fancontrol survives hwmon renumbering across reboots

sudo tee /usr/local/bin/fancontrol-fix > /dev/null << 'SCRIPT'
#!/bin/bash
CONF="/etc/fancontrol"
NCT_HWMON=""
K10_HWMON=""

for hwmon in /sys/class/hwmon/hwmon*; do
    name=$(cat "$hwmon/name" 2>/dev/null)
    num=$(basename "$hwmon")
    case "$name" in
        nct6799) NCT_HWMON="$num" ;;
        k10temp) K10_HWMON="$num" ;;
    esac
done

if [ -z "$NCT_HWMON" ] || [ -z "$K10_HWMON" ]; then
    echo "Could not find required hwmon devices" >&2
    exit 1
fi

NCT_PATH=$(readlink -f "/sys/class/hwmon/$NCT_HWMON/device" | sed 's|/sys/||')
K10_PATH=$(readlink -f "/sys/class/hwmon/$K10_HWMON/device" | sed 's|/sys/||')

cat > "$CONF" << FANEOF
# Configuration file for fancontrol
INTERVAL=10
DEVPATH=${K10_HWMON}=${K10_PATH} ${NCT_HWMON}=${NCT_PATH}
DEVNAME=${K10_HWMON}=k10temp ${NCT_HWMON}=nct6799
FCTEMPS=${NCT_HWMON}/pwm2=${K10_HWMON}/temp1_input ${NCT_HWMON}/pwm6=${K10_HWMON}/temp1_input ${NCT_HWMON}/pwm7=${K10_HWMON}/temp1_input
FCFANS=${NCT_HWMON}/pwm2=${NCT_HWMON}/fan2_input ${NCT_HWMON}/pwm6=${NCT_HWMON}/fan6_input ${NCT_HWMON}/pwm7=${NCT_HWMON}/fan7_input
MINTEMP=${NCT_HWMON}/pwm2=55 ${NCT_HWMON}/pwm6=55 ${NCT_HWMON}/pwm7=55
MAXTEMP=${NCT_HWMON}/pwm2=95 ${NCT_HWMON}/pwm6=95 ${NCT_HWMON}/pwm7=95
MINSTART=${NCT_HWMON}/pwm2=30 ${NCT_HWMON}/pwm6=30 ${NCT_HWMON}/pwm7=30
MINSTOP=${NCT_HWMON}/pwm2=20 ${NCT_HWMON}/pwm6=20 ${NCT_HWMON}/pwm7=20
MINPWM=${NCT_HWMON}/pwm2=20 ${NCT_HWMON}/pwm6=20 ${NCT_HWMON}/pwm7=20
MAXPWM=${NCT_HWMON}/pwm2=255 ${NCT_HWMON}/pwm6=255 ${NCT_HWMON}/pwm7=255
AVERAGE=${NCT_HWMON}/pwm2=6 ${NCT_HWMON}/pwm6=6 ${NCT_HWMON}/pwm7=6
FANEOF

echo "fancontrol config updated: nct6799=$NCT_HWMON k10temp=$K10_HWMON"
SCRIPT
sudo chmod +x /usr/local/bin/fancontrol-fix

sudo mkdir -p /etc/systemd/system/fancontrol.service.d
sudo tee /etc/systemd/system/fancontrol.service.d/fix-hwmon.conf > /dev/null << 'DROPIN'
[Service]
ExecStartPre=/usr/local/bin/fancontrol-fix
DROPIN

sudo systemctl daemon-reload
