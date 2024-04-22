#!/system/bin/sh

chooseport_legacy() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false
  while true; do
    timeout 0 $MODPATH/common/addon/Volume-Key-Selector/tools/$ARCH32/keycheck
    timeout $delay $MODPATH/common/addon/Volume-Key-Selector/tools/$ARCH32/keycheck
    local sel=$?
    if [ $sel -eq 42 ]; then
      return 0
    elif [ $sel -eq 41 ]; then
      return 1
    elif $error; then
      abort "Volume key not detected!"
    else
      error=true
      echo "Volume key not detected. Try again"
    fi
  done
}

chooseport() {
  # Original idea by chainfire and ianmacd @xda-developers
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false
  while true; do
    local count=0
    while true; do
      timeout $delay /system/bin/getevent -lqc 1 2>&1 > $TMPDIR/events &
      sleep 0.5; count=$((count + 1))
      if (`grep -q 'KEY_VOLUMEUP *DOWN' $TMPDIR/events`); then
        return 0
      elif (`grep -q 'KEY_VOLUMEDOWN *DOWN' $TMPDIR/events`); then
        return 1
      fi
      [ $count -gt 6 ] && break
    done
    if $error; then
      # abort "Volume key not detected!"
      echo "Volume key not detected. Trying keycheck method"
      export chooseport=chooseport_legacy VKSEL=chooseport_legacy
      chooseport_legacy $delay
      return $?
    else
      error=true
      echo "Volume key not detected. Try again"
    fi
  done
}

debloat_list="$MODPATH/bloat_packagelist.txt"
id=$(grep "id=" $MODPATH/module.prop | cut -d'=' -f2-)
last_install="/data/adb/modules/$id"

if [ -f "$last_install/.lastreplace" ]; then
  REPLACE=""
  ui_print "- Installing... (This could take some time :D)"
else
  REPLACE=$(cat "$last_install/.lastreplace")
  REPLACE="$REPLACE "
  ui_print "- (Re)Installing... (This could take some time :D)"
fi

ui_print "| Do you want to install the default configuration [Press Vol+]"
ui_print "| Or Customize your installation? [Press Vol-]"
ui_print "| Waiting until a key is pressed..."

if chooseport; then
  CUSTOMIZE=false
else
  CUSTOMIZE=true
fi

# Loop through each line in the output of the one-liner
while IFS= read -r PACKAGE_NAME; do
  # Check if the line is empty
  if [[ -z "$PACKAGE_NAME" || "$PACKAGE_NAME" =~ ^# ]]; then
    continue
  fi

  #        Get The Path of the App | Remove "package:"   | Remove the last part  | Just give me a uniqe Output
  APP_PATH=$(pm path $PACKAGE_NAME | sed "s/package://g" | sed 's|\(.*\)/.*|\1|' | uniq)

  if [ -z "$APP_PATH" ]; then
    continue
  fi

  if [[ ! -z $(echo "$APP_PATH" | grep -E "^/data/app/.*$") ]]; then
    rm -rf $APP_PATH # TODO: IF REMOVED DO THE UI_PRINT
    ui_print "- Removed Updates of $PACKAGE_NAME ($APP_PATH)"
    continue
  fi

  # Add /system to paths that start with anything other then /system
  if [ -z $(echo $APP_PATH | grep -E "^\/(system)\/.*$") ]; then
    APP_PATH="/system$APP_PATH"
  fi

  REPLACE="$REPLACE$APP_PATH "

done < "$debloat_list"

echo $REPLACE > "$MODPATH/.lastreplace"

ui_print "- ******************** 𝗡𝗢𝗧𝗜𝗖𝗘 ********************"
ui_print "-        𝗜𝗳 𝗮𝗻𝘆 𝗮𝗽𝗽𝘀 𝗮𝗿𝗲 𝗹𝗲𝗳𝘁, 𝗜𝗻𝘀𝘁𝗮𝗹𝗹 𝘁𝗵𝗲 𝗺𝗼𝗱𝘂𝗹𝗲     "
ui_print "-           𝗔𝗴𝗮𝗶𝗻 𝗪𝗜𝗧𝗛𝗢𝗨𝗧 𝗿𝗲𝗺𝗼𝘃𝗶𝗻𝗴 𝗶𝘁 𝗳𝗶𝗿𝘀𝘁         "
ui_print "- ************************************************"

ui_print "- ************************************"
ui_print "- Installation Done! Reboot & Enjoy :)"
ui_print "- ************************************"