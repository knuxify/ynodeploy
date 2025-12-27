#!/bin/sh

git clone https://github.com/EasyRPG/buildscripts easyrpg_buildscripts
git clone https://github.com/EasyRPG/liblcf
git clone https://github.com/ynoproject/ynoengine

cd easyrpg_buildscripts
git am ../buildscript-fixes.patch
