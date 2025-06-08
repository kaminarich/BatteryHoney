#!/system/bin/sh

RAM_TOTAL_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
RAM_TOTAL_GB=$(( (RAM_TOTAL_KB + 1048576 - 1) / 1048576 ))

get_cpu_name() {
  local codename=$(getprop ro.mediatek.platform)
  [ -z "$codename" ] && codename=$(getprop ro.board.platform)
  [ -z "$codename" ] && codename=$(grep -m1 'Hardware' /proc/cpuinfo | cut -d ':' -f2 | sed 's/^[ \t]*//')
  [ -z "$codename" ] && codename="unknown"

  local cpu_name="Unknown CPU"
  case "$codename" in
    mt6789) cpu_name="Helio G99 | G100 | Ultimate" ;;
    mt6785) cpu_name="Helio P90" ;;
    mt6893) cpu_name="Dimensity 1200" ;;
    mt6895) cpu_name="Dimensity 1300" ;;
    mt6769) cpu_name="Helio G88" ;;
    mt6769t) cpu_name="Helio G96" ;;
    mt6833) cpu_name="Dimensity 700" ;;
    mt6853) cpu_name="Dimensity 920" ;;
     # MediaTek Helio Series
    mt6761) cpu_name="Helio A22" ;;
    mt6762) cpu_name="Helio P22" ;;
    mt6763) cpu_name="Helio P23" ;;
    mt6765) cpu_name="Helio P35" ;;
    mt6767) cpu_name="Helio P35" ;; # juga sama codename
    mt6768) cpu_name="Helio P65" ;;
    mt6771) cpu_name="Helio P60" ;;
    mt6779) cpu_name="Helio P70" ;;
    mt6785) cpu_name="Helio P90" ;;
    mt6795) cpu_name="Helio X20" ;;
    mt6797) cpu_name="Helio X25" ;;
    mt6799) cpu_name="Helio X30" ;;
    mt6769) cpu_name="Helio G88" ;;
    mt6769t) cpu_name="Helio G96" ;;
    mt6762g) cpu_name="Helio G81" ;;
    mt6775) cpu_name="Helio X23" ;;
    mt6779t) cpu_name="Helio P70 (T variant)" ;;
    
    # MediaTek Dimensity Series
    mt6833) cpu_name="Dimensity 700" ;;
    mt6853) cpu_name="Dimensity 920" ;;
    mt6855) cpu_name="Dimensity 900" ;;
    mt6863) cpu_name="Dimensity 6100" ;;
    mt6865) cpu_name="Dimensity 6100+" ;;
    mt6873) cpu_name="Dimensity 6050" ;;
    mt6877) cpu_name="Dimensity 9200" ;;
    mt6885) cpu_name="Dimensity 1300" ;;
    mt6889) cpu_name="Dimensity 8100" ;;
    mt6891) cpu_name="Dimensity 1100" ;;
    mt6893) cpu_name="Dimensity 1200" ;;
    mt6895) cpu_name="Dimensity 1300" ;;
    mt6896) cpu_name="Dimensity 8050" ;;
    mt6983) cpu_name="Dimensity 9200+" ;;
    mt6985) cpu_name="Dimensity 9200+" ;; # variant
    mt6987) cpu_name="Dimensity 6100+" ;; # variant
    
    # Legacy / Others
    mt6735) cpu_name="Helio P10" ;;
    mt6737) cpu_name="Helio A20" ;;
    mt6739) cpu_name="Helio A22 (Alternate)" ;;
    mt6750) cpu_name="Helio P10" ;;
    mt6755) cpu_name="Helio P10" ;;
    mt6757) cpu_name="Helio P20" ;;
    mt6758) cpu_name="Helio P20" ;;
    mt6761) cpu_name="Helio A22" ;;
    mt6797m) cpu_name="Helio X23" ;;
    mt6799m) cpu_name="Helio X30" ;;

    # Variants / Device-specific codename (common on phones)
    mt6763t) cpu_name="Helio P23 (T variant)" ;;
    mt6765t) cpu_name="Helio P35 (T variant)" ;;
    mt6768t) cpu_name="Helio P65 (T variant)" ;;

    # Others fallback
    mt8127) cpu_name="MT8127 (Legacy Tablet SoC)" ;;
    mt8163) cpu_name="MT8163 (Tablet SoC)" ;;
    mt8173) cpu_name="MT8173 (Tablet SoC)" ;;
    mt8516) cpu_name="MT8516 (Audio SoC)" ;;
    *) cpu_name="$codename (Gacor Ultimate)" ;;
  esac
  echo "$cpu_name"
}

# Header Biar keren
ui_print "==============================================="
ui_print "🔋 Installing Battery Honey 🔋"
ui_print " "
ui_print "DEVICE       : $(getprop ro.build.product)"
ui_print "MODEL        : $(getprop ro.product.model)"
ui_print "MANUFACTURER : $(getprop ro.product.system.manufacturer)"
ui_print "BOARD        : $(getprop ro.product.board)"
ui_print "CPU          : $(get_cpu_name)"
ui_print "ANDROID VER  : $(getprop ro.build.version.release)"
ui_print "KERNEL       : $(uname -r)"
ui_print "🧠 RAM       : ${RAM_TOTAL_GB} GB"
ui_print " "

# Naughty Splash Muehehe
sleep 1.2
case "$((RANDOM % 12 + 1))" in
  1)  ui_print "- Ready to fuck your battery drain goodbye! 🔋💦" ;;
  2)  ui_print "- This module’s so sticky, your uptime will beg for release. 🍯😈" ;;
  3)  ui_print "- Battery lasting longer than your ex ever did. 💀💋" ;;
  4)  ui_print "- Drip less. Last longer. Just like you wish. 😏🔋" ;;
  5)  ui_print "- G99? More like G-Spot… we're stroking performance right. 💦" ;;
  6)  ui_print "- Touch your screen. Feel the climax of efficiency. 😈🔥" ;;
  7)  ui_print "- From screen-on to screen-off… every second's a tease. 🍑" ;;
  8)  ui_print "- Honey sweet, system tight – that's how we fuck lag. 💋🔧" ;;
  9)  ui_print "- Cum control meets current control. Stay charged, daddy. ⚡😏" ;;
  10) ui_print "- It’s not just power saving… it’s power *seduction*. 😘🔋" ;;
  11) ui_print "- She said go longer. Battery Honey said say no more. 💦📱" ;;
  12) ui_print "- Thermal’s tamed, power’s chained. Time to dominate uptime. 🔥😈" ;;
esac

# Footer
ui_print " "
ui_print "==============================================="
ui_print "✅ Battery Honey installed – now go play long & hard, baby🔋"
ui_print "==============================================="