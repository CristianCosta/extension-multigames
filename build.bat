@echo off
SET dir=%~dp0
cd %dir%
if exist extension-multiSocialFeatures.zip del /F extension-multiSocialFeatures.zip
winrar a -afzip extension-multiSocialFeatures.zip extension haxelib.json include.xml dependencies
pause