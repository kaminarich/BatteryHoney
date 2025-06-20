#!/system/bin/sh

# === BatteryHoney: Screen ON Mode ===
DEFAULT_DIR="/data/local/tmp/battery_honey_default"
LOG="/data/adb/modules/BatteryHoney/webroot/logs/screen_freq.log"
LOG_FILE="/data/adb/modules/BatteryHoney/webroot/logs/ram-reclaim.log"

log2() {
    echo "[$(date '+%F %T')] $1" >> "$LOG"
    tail -n 50 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
}
log2 "[🔓] Restoring CPU & GPU from BatteryHoney low-power mode..."

# ===== CPU Governor & Frequency Restore =====
for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$policy" ] || continue
    name=$(basename "$policy")

    def_min=$(cat "$DEFAULT_DIR/$name.min" 2>/dev/null)
    def_max=$(cat "$DEFAULT_DIR/$name.max" 2>/dev/null)
    def_gov=$(cat "$DEFAULT_DIR/$name.governor" 2>/dev/null)

    [ -n "$def_min" ] && echo "$def_min" > "$policy/scaling_min_freq" 2>/dev/null
    [ -n "$def_max" ] && echo "$def_max" > "$policy/scaling_max_freq" 2>/dev/null
    [ -n "$def_gov" ] && echo "$def_gov" > "$policy/scaling_governor" 2>/dev/null

    log2 "[$name] Restored MIN=$def_min MAX=$def_max GOV=$def_gov"
done

# ===== Optional: Restore GPU governor =====
GPU_GOV_PATH="/sys/class/devfreq/*gpu*/governor"
[ -f "$DEFAULT_DIR/gpu.governor" ] && {
    def_gpu_gov=$(cat "$DEFAULT_DIR/gpu.governor")
    for gov_path in $GPU_GOV_PATH; do
        [ -w "$gov_path" ] && echo "$def_gpu_gov" > "$gov_path" 2>/dev/null && log2 "[GPU] Restored governor to $def_gpu_gov"
    done
}

log2 "[✅] CPU & GPU config restored."
# ===== ( ZRAM ) =====
MODDIR=${0%/*}
. $MODDIR/sebastian.sh
screen_on
