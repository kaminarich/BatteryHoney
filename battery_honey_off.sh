#!/system/bin/sh

DEFAULT_DIR="/data/local/tmp/battery_honey_default"

for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$policy" ] || continue
    name=$(basename "$policy")

    def_min=$(cat "$DEFAULT_DIR/$name.min" 2>/dev/null)
    def_max=$(cat "$DEFAULT_DIR/$name.max" 2>/dev/null)
    def_gov=$(cat "$DEFAULT_DIR/$name.governor" 2>/dev/null)

    [ -n "$def_min" ] && echo "$def_min" > "$policy/scaling_min_freq" 2>/dev/null
    [ -n "$def_max" ] && echo "$def_max" > "$policy/scaling_max_freq" 2>/dev/null
    [ -n "$def_gov" ] && echo "$def_gov" > "$policy/scaling_governor" 2>/dev/null
done