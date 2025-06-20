#!/system/bin/sh

# === BatteryHoney: Screen OFF Mode ===

DEFAULT_DIR="/data/local/tmp/battery_honey_default"
LOG_FILE="/data/adb/modules/BatteryHoney/webroot/logs/ram-reclaim.log"
LOG_TITLE="───[ Sebastian RAM Reclaim Log ]───"
MEM_THRESHOLD_KB=3000000  # 2500 MB
LOG="/data/adb/modules/BatteryHoney/webroot/logs/screen_freq.log"
# ===== CPU Governor Tuning (Save Power) =====

log() {
    echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"
    tail -n 50 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
}
log2() {
    echo "[$(date '+%F %T')] $1" >> "$LOG"
    tail -n 50 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
}
#=========================================
log2 "[🌙] Setting CPU to lowest freq for BatteryHoney..."

for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$policy" ] || continue
    name=$(basename "$policy")

    cpu_min=$(cat "$policy/cpuinfo_min_freq" 2>/dev/null)
    [ -n "$cpu_min" ] && {
        echo "$cpu_min" > "$policy/scaling_min_freq" 2>/dev/null
        echo "$cpu_min" > "$policy/scaling_max_freq" 2>/dev/null
    }

    if [ -w "$policy/scaling_governor" ]; then
        echo "powersave" > "$policy/scaling_governor" 2>/dev/null
    fi

    log2 "[$name] set MIN=MAX=$cpu_min GOV=powersave"
done

# Optional: turunin GPU governor atau freq juga (kalau ada path-nya)
GPU_GOV_PATH="/sys/class/devfreq/*gpu*/governor"
for gov_path in $GPU_GOV_PATH; do
    [ -w "$gov_path" ] && echo "powersave" > "$gov_path" 2>/dev/null && log2 "[GPU] Set governor to powersave"
done

log2 "[✅] CPU & GPU set to low-power mode."

MODDIR=${0%/*}
. $MODDIR/sebastian.sh
screen_off
