#! /usr/bin/bash

mkdir build-scripts
cd build-scripts

cmake $RECIPE_DIR/scripts
cd ..

mkdir build
cd build
# ${CMAKE_ARGS} carries conda-build's own -DCMAKE_BUILD_TYPE=Release
# (plus toolchain/strip paths) -- omitting it leaves CMAKE_BUILD_TYPE
# unset (this project's own CMakeLists.txt never defaults it either),
# producing an unoptimized, unstripped debug-info binary.
# Classic dictionaries, as for root-plus: on macOS conda-forge ROOT 6.38's
# rootcling crashes building C++ modules, and wherever ROOT itself has no
# runtime C++ modules (conda-forge cross-compiles linux-aarch64 with
# runtime_cxxmodules=OFF: no etc/cling/module.modulemap to build on).
EXTRA_ARGS=()
if [[ "$(uname)" == "Darwin" ]] || [[ "$(root-config --has-runtime_cxxmodules)" != "yes" ]]; then
    EXTRA_ARGS+=(-DROOT_RUNTIME_CXXMODULES=OFF)
fi

cmake .. ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX "${EXTRA_ARGS[@]}"

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
