#!/system/bin/sh

DEFAULT_DIR="/data/local/tmp/battery_honey_default"

for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$policy" ] || continue

    cpu_min=$(cat "$policy/cpuinfo_min_freq" 2>/dev/null)
    echo "$cpu_min" > "$policy/scaling_min_freq" 2>/dev/null
    echo "$cpu_min" > "$policy/scaling_max_freq" 2>/dev/null

    if [ -w "$policy/scaling_governor" ]; then
        echo "sugov_ext" > "$policy/scaling_governor" 2>/dev/null
    fi
done