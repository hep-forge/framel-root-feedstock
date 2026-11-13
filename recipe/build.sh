#! /usr/bin/bash

mkdir build
cd build
# ${CMAKE_ARGS} carries conda-build's own -DCMAKE_BUILD_TYPE=Release
# (plus toolchain/strip paths) -- omitting it leaves CMAKE_BUILD_TYPE
# unset (this project's own CMakeLists.txt never defaults it either),
# producing an unoptimized, unstripped debug-info binary.
# Classic dictionaries on every platform. A C++ module (lib/*.pcm built
# from FrameFormat.modulemap) records root-plus's headers as they were at
# build time; once root-plus is rebuilt with any header change, cling
# refuses it ("TKeyboard has different definitions in different
# modules"). Classic dictionaries only name the headers, so they keep
# working across root-plus rebuilds. They are also the only option on
# macOS (conda-forge ROOT 6.38's rootcling crashes building modules) and
# linux-aarch64 (ROOT built with runtime_cxxmodules=OFF).
EXTRA_ARGS=(-DROOT_RUNTIME_CXXMODULES=OFF)

cmake .. ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX "${EXTRA_ARGS[@]}"

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
