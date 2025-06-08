#!/system/bin/sh
MODDIR=${0%/*}
DEFAULT_DIR="/data/local/tmp/battery_honey_default"
LOG_FILE="/data/local/tmp/screen_freq.log"
LAST_STATE=""

echo "=== Battery Honey Screen CPU Watchdog Started at $(date) ===" > "$LOG_FILE"

#===== Get Screen State🔋 =====
get_screen_state() {
    dumpsys display | grep -iq "mScreenState=ON" && echo "on" || echo "off"
}

#===== Saves State for Fallback when screen ON🔋 =====
save_defaults() {
    mkdir -p "$DEFAULT_DIR"
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        [ -d "$policy" ] || continue
        name=$(basename "$policy")

        min=$(cat "$policy/cpuinfo_min_freq" 2>/dev/null)
        max=$(cat "$policy/cpuinfo_max_freq" 2>/dev/null)
        gov=$(cat "$policy/scaling_governor" 2>/dev/null)

        [ -n "$min" ] && echo "$min" > "$DEFAULT_DIR/$name.min"
        [ -n "$max" ] && echo "$max" > "$DEFAULT_DIR/$name.max"
        [ -n "$gov" ] && echo "$gov" > "$DEFAULT_DIR/$name.governor"

        echo "Saved [$name] MIN=$min MAX=$max GOV=$gov" >> "$LOG_FILE"
    done
    touch "$DEFAULT_DIR/.saved"
}

#===== Save🔋 =====
if [ ! -f "$DEFAULT_DIR/.saved" ]; then
    echo "[📝] Saving default CPU config..." >> "$LOG_FILE"
    save_defaults
fi

#===== Main Loop🔋 =====
while true; do
    SCREEN_STATE=$(get_screen_state)

    if [ "$SCREEN_STATE" != "$LAST_STATE" ]; then
        echo "[📲] Screen state changed to: $SCREEN_STATE" >> "$LOG_FILE"
        if [ "$SCREEN_STATE" = "off" ]; then
            sleep 2
            if [ "$(get_screen_state)" = "off" ]; then
                sh "$MODDIR/battery_honey_on.sh" &
                LAST_STATE="off"
            fi
        else
            sh "$MODDIR/battery_honey_off.sh" &
            LAST_STATE="on"
        fi
    fi

    sleep 2
done