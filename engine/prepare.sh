#!/bin/sh

if [ ! -d "engine" ]; then
	echo "Please run this script from the base ynodeploy directory"
	exit 1
fi

fixes_patch_path="$(pwd)"/engine/buildscript-fixes.patch
cd repos/easyrpg_buildscripts
git apply "$fixes_patch_path"
