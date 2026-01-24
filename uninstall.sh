#!/system/bin/sh

if [ -d "/data/local/tmp/batteryhoney" ]; then
  rm -rf "/data/local/tmp/batteryhoney"
fi

rm -f "/data/local/tmp/honey_tmp_preview"
rm -f "/data/local/tmp/honey_preview.webp"
rm -f "/data/local/tmp/honey_preview"
rm -f "/data/local/tmp/batteryhoney_error.log"

exit 0
