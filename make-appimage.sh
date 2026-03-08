#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q blender | awk '{print $2; exit}') # example command to get version of application here
VERSION=${VERSION#*:}
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/blender.svg
export DESKTOP=/usr/share/applications/blender.desktop
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PYTHON=1
export DEPLOY_SDL=1
export OPTIMIZE_LAUNCH=1

# Deploy dependencies
quick-sharun \
	/usr/bin/blender*         \
	/usr/share/blender        \
	/usr/lib/libssl.so*       \
	/usr/lib/libcblas.so*     \
	/usr/lib/liblapack.so*    \
	/usr/lib/libopenblas.so*  \
	/usr/lib/libquadmath.so*  \
	/opt/intel/oneapi/tcm/*/lib/libtcm.so*

# blender needs the files of its share directory relative to it
ln -sr ./AppDir/share/blender/* ./AppDir/bin

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --test ./dist/*.AppImage

