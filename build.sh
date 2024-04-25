#!/bin/bash

if [ -z $1 ]; then
    version="TEST"
else
    version=$1
fi

mod_id=$(grep "id=" module.prop | cut -d'=' -f2-)

# Get Tools
mkdir tools
cd tools
wget https://raw.githubusercontent.com/Systemless-DeBloaters/Framework/main/tools/aapt
wget https://raw.githubusercontent.com/Systemless-DeBloaters/Framework/main/tools/aapt64
cd ..

wget https://raw.githubusercontent.com/Systemless-DeBloaters/Framework/main/customize.sh
zip -r $mod_id-$version.zip ./ -x .git/\* Screenshots/\* .github/\* README.md build.sh .gitignore LICENSE
rm customize.sh