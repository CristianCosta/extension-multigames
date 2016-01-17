#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -f extension-multiSocialFeatures.zip
zip -0r extension-multiSocialFeatures.zip extension haxelib.json include.xml dependencies 
