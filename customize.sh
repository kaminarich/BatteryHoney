#!/system/bin/sh

RAM_TOTAL_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
RAM_FREE_KB=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
RAM_TOTAL_GB=$(( (RAM_TOTAL_KB + 1048576 - 1) / 1048576 ))
RAM_FREE_GB=$(( (RAM_FREE_KB + 1048576 - 1) / 1048576 ))

get_cpu_codename() {
  local codename=$(getprop ro.mediatek.platform)
  [ -z "$codename" ] && codename=$(getprop ro.board.platform)
  [ -z "$codename" ] && codename=$(grep -m1 'Hardware' /proc/cpuinfo | cut -d ':' -f2 | sed 's/^[ \t]*//')
  echo "${codename:-unknown}"
}
ui_print "=========================================="
ui_print "   ___       __  __              "
ui_print "  / _ )___ _/ /_/ /____ ______ __"
ui_print " / _  / _ \`/ __/ __/ -_) __/ // /"
ui_print "/____/\\_,_/\\__/\\__/\\__/_/  \\_, / "
ui_print "  / // /__  ___  ___ __ __/___/  "
ui_print " / _  / _ \\/ _ \\/ -_) // /        "
ui_print "/_//_/\\___/_//_/\\__/\\_, /         "
ui_print "                   /___/         "
ui_print " "
ui_print "=========================================="
ui_print " "
ui_print "DEVICE       : $(getprop ro.build.product)"
ui_print "MODEL        : $(getprop ro.product.model)"
ui_print "MANUFACTURER : $(getprop ro.product.system.manufacturer)"
ui_print "BOARD        : $(getprop ro.product.board)"
ui_print "CODENAME     : $(get_cpu_codename)"
ui_print "ANDROID VER  : $(getprop ro.build.version.release)"
ui_print "KERNEL       : $(uname -r)"
ui_print "🧠 RAM       : ${RAM_TOTAL_GB} GB total / ${RAM_FREE_GB} GB free"
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
ui_print "=========================================="
ui_print "✅ Battery Honey installed – now go play long & hard, baby🔋"
ui_print "=========================================="