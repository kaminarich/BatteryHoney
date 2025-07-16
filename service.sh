#!/system/bin/sh

# ====== Wait Boot ======
while [ -z "$(getprop sys.boot_completed)" ]; do
    sleep 5
done

BATTERYHONEY_DIR="/data/adb/modules/BatteryHoney"
BATTERYHONEY_PROP="$BATTERYHONEY_DIR/module.prop"
CHECK_SCRIPT="$BATTERYHONEY_DIR/check.sh"

while [ ! -f "$BATTERYHONEY_PROP" ]; do
    sleep 2
done

chmod +x "$CHECK_SCRIPT"
chmod +x "$BATTERYHONEY_DIR/system/bin/sebastian2"
chmod +x "$BATTERYHONEY_DIR/system/bin/inotifywait"
/system/bin/sh "$CHECK_SCRIPT"

get_cpu_name() {
    local codename=$(getprop ro.mediatek.platform)
    [ -z "$codename" ] && codename=$(getprop ro.board.platform)
    [ -z "$codename" ] && codename=$(grep -m1 'Hardware' /proc/cpuinfo | cut -d ':' -f2 | sed 's/^[ \t]*//')
    echo "${codename:-unknown}"
}

DEVICE_NAME=$(get_cpu_name)
su -lp 2000 -c "cmd notification post -S bigtext -t 'Battery Honey🔋' bh_tag 'Activated at $DEVICE_NAME'" >/dev/null &

nohup "$BATTERYHONEY_DIR/system/bin/sebastian2" >/dev/null 2>&1 &