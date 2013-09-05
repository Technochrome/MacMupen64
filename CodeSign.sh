#!/bin/sh

#  Get the application ready for Deployment

#  Change this for your system
DESTINATION=/Users/rovolo/Dropbox/Public/MacMupen64/

APP_NAME=MacMupen64

APP_BUNDLE=$BUILT_PRODUCTS_DIR/$APP_NAME.app
CONTENTS=$APP_BUNDLE/Contents

ident=$(defaults read $CONTENTS/Info.plist CFBundleIdentifier)

for sign_target in $CONTENTS/PlugIns/* $CONTENTS/Frameworks/*/Versions/A $CONTENTS/libs/* $APP_BUNDLE; do
	echo codesign -s MacMupen64plus -i $ident "$sign_target"
	codesign -s MacMupen64plus -i $ident "$sign_target"
done

cd $BUILT_PRODUCTS_DIR
echo zip -r $APP_NAME $APP_NAME.app

zip -r $APP_NAME $APP_NAME.app > /dev/null
mv $BUILT_PRODUCTS_DIR/$APP_NAME.zip $DESTINATION/$APP_NAME.app.zip