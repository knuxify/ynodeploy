#!/bin/sh -xe

# Script to build minnaengine.
# (Wrapper to do the build in Docker; for the actual build commands, see _build.sh.)

docker build -t minnaengine_emsdk .
docker run --rm -v $(pwd):/src -u $(id -u):$(id -g) minnaengine_emsdk ./_build.sh

[ ! -d output ] && mkdir output
cp easyrpg_buildscripts/emscripten/bin/ynoengine-simd.js output/ynoengine-simd.js
cp easyrpg_buildscripts/emscripten/bin/ynoengine-simd.wasm output/ynoengine-simd.wasm
cp easyrpg_buildscripts/emscripten/bin/ynoengine-simd.wasm output/easyrpg-player.wasm
