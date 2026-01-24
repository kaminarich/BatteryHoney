#!/system/bin/sh

SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true

REPLACE="
"

print_modname() {
  ui_print "░█░█░█▀█░█▀█░█▀▀░█░█"
  sleep 0.05
  ui_print "░█▀█░█░█░█░█░█▀▀░░█░"
  sleep 0.05
  ui_print "░▀░▀░▀▀▀░▀░▀░▀▀▀░░▀░"
  sleep 0.05
  ui_print ""
  sleep 1
  ui_print "Made by : kaminarich | kaminarich_here"
  ui_print ""
  sleep 5
}


on_install() {

  ui_print "> Extracting module files..."
  unzip -o "$ZIPFILE" 'bin/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'cortex/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'webroot/*' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'service.sh' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'post-fs-data.sh' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'uninstall.sh' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'module.prop' -d $MODPATH >&2
  
  ui_print " "
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0777 0777
}





