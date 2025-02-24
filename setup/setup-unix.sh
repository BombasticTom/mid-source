#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
#
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download/version/4.2.5/
haxelib install lime
haxelib install openfl
haxelib install flixel 5.8.0
haxelib install flixel-addons 3.2.3
haxelib install flixel-ui 2.6.1
haxelib install flixel-tools
# SScript is discontinued and it won't let you build with it so.
haxelib git SScript https://github.com/TechnikTil/SScriptBackup
haxelib install hxvlc 2.0.1 --skip-dependencies
haxelib install tjson 1.4.0
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc cf90f46a3bce81d5f8ca5def338fba82fc4f4ec1