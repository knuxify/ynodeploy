#!/bin/sh -xe

# Script to build minnaengine.
# (Wrapper to do the build in Docker; for the actual build commands, see _build.sh.)

if [ ! -e repos ]; then
	echo "Please run this script from the base ynodeploy directory"
	exit 1
fi

docker build -t minnaengine_emsdk engine
docker run --rm -v $(pwd):/src -u $(id -u):$(id -g) minnaengine_emsdk engine/_build.sh

cp repos/easyrpg_buildscripts/emscripten/bin/ynoengine-simd.js repos/forest-orb/ynoengine-simd.js
cp repos/easyrpg_buildscripts/emscripten/bin/ynoengine-simd.wasm repos/forest-orb/ynoengine-simd.wasm
cp repos/easyrpg_buildscripts/emscripten/bin/ynoengine-simd.wasm repos/forest-orb/easyrpg-player.wasm
cp repos/easyrpg_buildscripts/emscripten/bin/ynoengine.js repos/forest-orb/ynoengine.js
cp repos/easyrpg_buildscripts/emscripten/bin/ynoengine.wasm repos/forest-orb/ynoengine.wasm
