#!/bin/bash

if [ -z $1 ]; then
    version="TEST"
else
    version=$1
fi

mod_id=$(grep "id=" module.prop | cut -d'=' -f2-)

wget https://raw.githubusercontent.com/Systemless-DeBloaters/Framework/main/customize.sh
zip -r $mod_id-$version.zip ./ -x .git/\* Screenshots/\* .github/\* README.md build.sh .gitignore
rm customize.sh