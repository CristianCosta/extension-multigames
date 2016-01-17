@echo off
SET dir=%~dp0
cd %dir%
haxelib remove extension-multiSocialFeatures
haxelib local extension-multiSocialFeatures.zip
