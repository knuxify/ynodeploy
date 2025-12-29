#!/bin/sh -xe

# Build script to rebuild ynoengine.
# (Internal script; use the ./build.sh wrapper to run this in Docker.)

basedir="$(pwd)"
reposdir="$basedir"/repos

# Build dependencies
cd "$reposdir"/easyrpg_buildscripts/emscripten
./0_build_everything.sh

# Set build variables for liblcf and ynoengine
export PATH="$PATH:$reposdir/easyrpg_buildscripts/emscripten/bin" # for icu-config
export CFLAGS="-O2 -g0 -sUSE_SDL=0"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="-I$reposdir/easyrpg_buildscripts/emscripten/include"
export LDFLAGS="-L$reposdir/easyrpg_buildscripts/emscripten/lib -sEXPORT_ALL=1"
export EM_CFLAGS="-Wno-warn-absolute-paths"
export EMCC_CFLAGS="$EM_CFLAGS"
export EM_PKG_CONFIG_PATH="$reposdir/easyrpg_buildscripts/emscripten/lib/pkgconfig"
export EASYRPG_BUILDSCRIPTS="$reposdir/easyrpg_buildscripts"

# Build liblcf
cd "$reposdir"/liblcf

emcmake cmake . -Bbuild -G Ninja --preset=emscripten-release \
	-DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_C_FLAGS="$CFLAGS $CPPFLAGS" -DCMAKE_CXX_FLAGS="$CXXFLAGS $CPPFLAGS" \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_INSTALL_PREFIX="$reposdir/easyrpg_buildscripts/emscripten" \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DCMAKE_PREFIX_PATH="$reposdir/easyrpg_buildscripts/emscripten" \
	-DCMAKE_FIND_ROOT_PATH="$reposdir/easyrpg_buildscripts/emscripten"

cmake --build build --target clean
cmake --build build
cmake --build build --target install

# Build ynoengine
cd "$reposdir"/ynoengine

# Build ynoengine-simd
emcmake cmake . -Bbuild -G Ninja --preset=yno-simd-release \
	-DCMAKE_CXX_COMPILER_LAUNCHER="" \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_C_FLAGS="$CFLAGS $CPPFLAGS" -DCMAKE_CXX_FLAGS="$CXXFLAGS $CPPFLAGS" \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_INSTALL_PREFIX="$reposdir/easyrpg_buildscripts/emscripten" \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DCMAKE_PREFIX_PATH="$reposdir/easyrpg_buildscripts/emscripten" \
	-DCMAKE_FIND_ROOT_PATH="$reposdir/easyrpg_buildscripts/emscripten"

cmake --build build --target clean
cmake --build build
cmake --build build --target install

# Build ynoengine (no simd)
rm -r build

emcmake cmake . -Bbuild -G Ninja --preset=yno-release \
	-DCMAKE_CXX_COMPILER_LAUNCHER="" \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_C_FLAGS="$CFLAGS $CPPFLAGS" -DCMAKE_CXX_FLAGS="$CXXFLAGS $CPPFLAGS" \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_INSTALL_PREFIX="$reposdir/easyrpg_buildscripts/emscripten" \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DCMAKE_PREFIX_PATH="$reposdir/easyrpg_buildscripts/emscripten" \
	-DCMAKE_FIND_ROOT_PATH="$reposdir/easyrpg_buildscripts/emscripten"

cmake --build build --target clean
cmake --build build
cmake --build build --target install

echo ""
echo "Done!"
