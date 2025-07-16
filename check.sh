#!/system/bin/sh

BATTERYHONEY_PROP="/data/adb/modules/BatteryHoney/module.prop"


MODULES=("armpit" "asu" "vulkanopt")
TAGS_OK=("Armpit Sync" "ASU Sync" "VulkanOPT Sync")
TAGS_FAIL=("Armpit" "ASU" "VulkanOPT")


if [ -f "$BATTERYHONEY_PROP" ]; then
    DESC=$(grep "^description=" "$BATTERYHONEY_PROP" | cut -d= -f2-)
    CLEAN_DESC=$(echo "$DESC" | sed -E 's/ *\[✓\][^[]+//g' | sed -E 's/ *\[x\][^[]+//g' | sed 's/[[:space:]]*$//')

    APPEND_STR=""

    for i in "${!MODULES[@]}"; do
        MOD="${MODULES[$i]}"
        TAG_OK="${TAGS_OK[$i]}"
        TAG_FAIL="${TAGS_FAIL[$i]}"

        if [ -d "/data/adb/modules/$MOD" ]; then
            APPEND_STR="$APPEND_STR [✓] $TAG_OK"
        else
            APPEND_STR="$APPEND_STR [x] $TAG_FAIL"
        fi
    done

    FINAL_DESC="$CLEAN_DESC$APPEND_STR"

    cp "$BATTERYHONEY_PROP" "$BATTERYHONEY_PROP.bak"

    sed -i '/^description=/d' "$BATTERYHONEY_PROP"

    echo -e "\ndescription=$FINAL_DESC" >> "$BATTERYHONEY_PROP"
fi