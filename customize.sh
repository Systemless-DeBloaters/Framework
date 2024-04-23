#!/system/bin/sh

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
  ui_print "- 𝗜𝗻𝘀𝘁𝗮𝗹𝗹𝗶𝗻𝗴... (𝗧𝗵𝗶𝘀 𝗰𝗼𝘂𝗹𝗱 𝘁𝗮𝗸𝗲 𝘀𝗼𝗺𝗲 𝘁𝗶𝗺𝗲 :𝗗)"
else
  REPLACE=$(cat "$last_install/.lastreplace")
  REPLACE="$REPLACE "
  ui_print "- (𝗥𝗲)𝗜𝗻𝘀𝘁𝗮𝗹𝗹𝗶𝗻𝗴... (𝗧𝗵𝗶𝘀 𝗰𝗼𝘂𝗹𝗱 𝘁𝗮𝗸𝗲 𝘀𝗼𝗺𝗲 𝘁𝗶𝗺𝗲 :𝗗)"
fi

ui_print
ui_print "- 𝗗𝗼 𝘆𝗼𝘂 𝘄𝗮𝗻𝘁 𝘁𝗼 𝗜𝗻𝘀𝘁𝗮𝗹𝗹"
ui_print "-  𝗪𝗶𝘁𝗵 𝘁𝗵𝗲 𝗱𝗲𝗳𝗮𝘂𝗹𝘁 𝗰𝗼𝗻𝗳𝗶𝗴𝘂𝗿𝗮𝘁𝗶𝗼𝗻?"
ui_print "                 [● 𝗣𝗿𝗲𝘀𝘀 𝗩𝗼𝗹+]"
ui_print
ui_print "- 𝗢𝗿 𝗖𝘂𝘀𝘁𝗼𝗺𝗶𝘇𝗲 𝘆𝗼𝘂𝗿 𝗶𝗻𝘀𝘁𝗮𝗹𝗹𝗮𝘁𝗶𝗼𝗻?"
ui_print "                 [● 𝗣𝗿𝗲𝘀𝘀 𝗩𝗼𝗹-]"
ui_print
ui_print "- 𝗪𝗮𝗶𝘁𝗶𝗻𝗴 𝘂𝗻𝘁𝗶𝗹 𝗮 𝗸𝗲𝘆 𝗶𝘀 𝗽𝗿𝗲𝘀𝘀𝗲𝗱..."
ui_print

if chooseport 15; then
  ui_print "Installing with the default config..."
  CUSTOMIZE=false
else
  ui_print "OK, You're gonna customize the installation :D"
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

  if [ $CUSTOMIZE == true ]; then
    ui_print "Remove $PACKAGE_NAME?"
    ui_print "[Yes: Vol+] [No: Vol-]"

    if ! chooseport 15; then
      continue
    fi

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