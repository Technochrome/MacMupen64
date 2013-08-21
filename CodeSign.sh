#!/bin/sh

#  CodeSign.sh
#  MacMupen64
#
#  Created by Rovolo on 8/20/13.
#
APP_BUNDLE=$BUILT_PRODUCTS_DIR/MacMupen64.app
CONTENTS=$APP_BUNDLE/Contents

ident=$(defaults read $CONTENTS/Info.plist CFBundleIdentifier)

for sign_target in $CONTENTS/PlugIns/* $CONTENTS/Frameworks/*/Versions/A $CONTENTS/libs/* $APP_BUNDLE; do
	echo codesign -s MacMupen64plus -i $ident -f "$sign_target"
	codesign -s MacMupen64plus -i $ident -f "$sign_target"
done

open $BUILT_PRODUCTS_DIR