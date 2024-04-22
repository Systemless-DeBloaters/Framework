#!/system/bin/sh

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