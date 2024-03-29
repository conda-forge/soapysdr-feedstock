#!/usr/bin/env bash

set -ex

mkdir build
cd build

# enable components explicitly so we get build error when unsatisfied
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_LIBDIR=lib
    -DPYTHON_EXECUTABLE=$PYTHON
    -DSOAPY_SDR_EXTVER=$PKG_BUILDNUM
    -DSOAPY_SDR_ROOT_ENV="CONDA_PREFIX"
    -DENABLE_APPS=ON
    -DENABLE_DOCS=OFF
    -DENABLE_LIBRARY=ON
    -DENABLE_PYTHON=ON
    -DENABLE_TESTS=ON
)

if [[ $python_impl == "pypy" ]] ; then
    # we need to help cmake find pypy
    cmake_config_args+=(
        -DPYTHON_LIBRARY=$PREFIX/lib/`$PYTHON -c "import sysconfig; print(sysconfig.get_config_var('LDLIBRARY'))"`
        -DPYTHON_INCLUDE_DIR=`$PYTHON -c "import sysconfig; print(sysconfig.get_paths()['include'])"`
    )
fi

cmake ${CMAKE_ARGS} .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
ctest --output-on-failure
fi
cmake --build . --config Release --target install
