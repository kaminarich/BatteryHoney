#!/system/bin/sh

# Loop pemantauan layar dan pengaturan CPU
while true; do
  if dumpsys power | grep -iq "mHoldingDisplaySuspendBlocker=false"; then
    # == LAYAR MATI ==

    echo "[BatteryHoney] Layar mati - optimasi dimulai" >> /dev/kmsg

    # Kill semua aplikasi user kecuali yang ada di blacklist
    for app in $(cmd package list packages -3 | cut -d':' -f2); do
      case "$app" in
        com.whatsapp|org.telegram.messenger|tw.nekomimi.nekogram) continue ;;  # Lewati app ini
        *) am force-stop "$app" ;;
      esac
    done

    # Clear cache
    sync; echo 3 > /proc/sys/vm/drop_caches
    if [ -x "$(command -v busybox)" ]; then
      busybox echo 3 > /proc/sys/vm/drop_caches
    fi

    echo "[BatteryHoney] RAM & cache dibersihkan, apps dihentikan" >> /dev/kmsg

    # Set frekuensi CPU ke nilai rendah hanya saat layar mati
    for cpu in 0 1 2 3 4 5; do
      echo 500000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
      echo 500000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq
    done

    for cpu in 6 7; do
      echo 750000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
      echo 750000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq
    done

    echo "[BatteryHoney] Frekuensi CPU diset ke nilai rendah" >> /dev/kmsg

    # Tunggu 5 detik agar tidak spam
    sleep 5

  else
    # == LAYAR HIDUP ==

    # Tidak melakukan perubahan pada frekuensi CPU ketika layar hidup
    echo "[BatteryHoney] Layar hidup - frekuensi CPU tidak diubah" >> /dev/kmsg

    sleep 5
  fi
done