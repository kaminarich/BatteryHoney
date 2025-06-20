#!/system/bin/sh

LOG_FILE="/data/adb/modules/BatteryHoney/webroot/logs/ram-reclaim.log"
MEM_THRESHOLD_KB=2000000  # 2GB
ZRAM_DEV="/dev/block/zram0"
SWAPPINESS_AGGRESSIVE=60
SWAPPINESS_NORMAL=20

# ===== Utility Logging =====

log() {
    echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"
    tail -n 50 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
    
}
get_zram_original_data_size() {
    local zram_path
    for path in /sys/block/zram0 /sys/class/block/zram0; do
        if [ -e "$path/mm_stat" ]; then
            zram_path="$path"
            break
        fi
    done
    [ -z "$zram_path" ] && echo 0 && return 1

    awk '{print $1}' "$zram_path/mm_stat"
}
# ===== ZRAM Reset + Reactivate =====
reset_zram() {
    swapoff "$ZRAM_DEV" 2>/dev/null
    echo 1 > /sys/block/zram0/reset 2>/dev/null
    mkswap "$ZRAM_DEV" >/dev/null 2>&1
    swapon "$ZRAM_DEV" >/dev/null 2>&1
    log "[ZRAM] Reset + Re-enabled"
}

# ===== RAM Reclaimer =====
reclaim_memory() {
    write_log "[ACTION] Reclaim triggered"
    echo 1 > /proc/sys/vm/compact_memory
    echo 3 > /proc/sys/vm/drop_caches
    log "[DONE] Reclaimed memory from RAM"
}

# ===== Screen OFF Mode =====
screen_off() {
    echo $SWAPPINESS_AGGRESSIVE > /proc/sys/vm/swappiness
    log "[CONFIG] Swappiness set to $SWAPPINESS_AGGRESSIVE (Aggressive mode)"

    available=$(awk '/MemAvailable/ { print $2 }' /proc/meminfo)
    zram_used=$(get_zram_original_data_size)

    log "[INFO] MemAvailable: $((available / 1024)) MB | ZRAM used: $((zram_used / 1024 / 1024)) MB"

    if [ "$available" -lt "$MEM_THRESHOLD_KB" ]; then
        log "[TRIGGER] Mem below threshold – start reclaiming & monitoring ZRAM"

        reclaim_memory

        zram_total=$(cat /sys/block/zram0/disksize 2>/dev/null)
        if [ "$zram_used" -ge "$((zram_total * 90 / 100))" ]; then
            log "[ZRAM] ZRAM usage > 90%, resetting..."
            reset_zram
        fi
    else
        log "[OK] RAM Capacity in Good state - No Reclaim"
        log "[INFO] MemAvailable: $((available / 1024)) MB | ZRAM used: $((zram_used / 1024 / 1024)) MB"
    fi
}

# ===== Screen ON Mode =====
screen_on() {
available=$(awk '/MemAvailable/ { print $2 }' /proc/meminfo)
    zram_used=$(get_zram_original_data_size)
    echo $SWAPPINESS_NORMAL > /proc/sys/vm/swappiness
    log "[CONFIG] Swappiness set to $SWAPPINESS_NORMAL (Normal mode)"
    log "[INFO] MemAvailable: $((available / 1024)) MB | ZRAM used: $((zram_used / 1024 / 1024)) MB"
}

# ======= End =======