#!/system/bin/sh
MODDIR=${0%/*}
clear="/data/local/tmp/ram-reclaim.log"
#===== Utility =====
eval_b64() {
    [ -f "$1" ] && eval "$(base64 -d "$1")" &
}

while [ -z "$(getprop sys.boot_completed)" ]; do
chmod 0755 "$MODDIR/sebastian.sh"
chmod 0755 "$MODDIR/monitor.sh"
chmod 0755 "$MODDIR/battery_honey_on.sh"
chmod 0755 "$MODDIR/battery_honey_off.sh"
rm -rf "$clear" >/dev/null &
    sleep 10
done
sh "$MODDIR/monitor.sh" &

get_cpu_name() {
  local codename=$(getprop ro.mediatek.platform)
  [ -z "$codename" ] && codename=$(getprop ro.board.platform)
  [ -z "$codename" ] && codename=$(grep -m1 'Hardware' /proc/cpuinfo | cut -d ':' -f2 | sed 's/^[ \t]*//')
  echo "${codename:-unknown}"
}

DEVICE_NAME=$(get_cpu_name)
su -lp 2000 -c "cmd notification post -S bigtext -t 'Battery Honey🔋' bh_tag 'Activated at $DEVICE_NAME'" >/dev/null &
