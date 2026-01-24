#!/system/bin/sh
MOD="/data/adb/modules/batteryhoney/bin"
BH="$MOD/batteryhoney-bin"
BP="$MOD/batteryhoney-bypass"
run_bg() {
    local bin="$MOD/$1"
    if [ -f "$bin" ]; then
        chmod 0755 "$bin"
        nohup "$bin" >/dev/null 2>&1 &
    fi
}
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 5
done
sleep 2
chmod +x "$BH"
chmod +x "$BP"
sleep 30
run_bg "batteryhoney-bin"
run_bg "batteryhoney-bypass"