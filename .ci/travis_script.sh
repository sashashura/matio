#!/bin/bash

set -x #echo on

if [[ "$COVERITY_SCAN_BRANCH" == 1 ]]; then
    exit 0
fi

if [[ "${USE_CMAKE:-no}" == "no" ]]; then
    make "CPPFLAGS=-DMAX_RANK=$MAX_RANK"
    make check
else
    BUILD_DIR=$HOME/matio_cmake
    pushd $BUILD_DIR
    cmake --build . -- -j8
    popd

    mkdir -p test
    cp $BUILD_DIR/test_snprintf ./test
    cp $BUILD_DIR/test_mat ./test
    mkdir -p tools
    cp $BUILD_DIR/matdump ./tools
fi

./test/test_snprintf
./test/test_mat -H
./test/test_mat -L
./test/test_mat -V
./tools/matdump -v -H
./tools/matdump -V
./tools/matdump -d ./MSL/Modelica/Resources/Data/Tables/test_v6.mat s

if [[ "$WITH_ZLIB" != "no" ]];
    then ./tools/matdump -d ./MSL/Modelica/Resources/Data/Tables/test_v7.mat s
    for f in ./matfilerw/src/test/resources/*.mat; do ./tools/matdump -v $f; done
    for f in ./matfilerw/src/test/resources/*.mat; do ./tools/matdump -v -d -f whos -h $f; done
    for f in ./matfilerw/src/test/resources/mcos/*.mat; do ./tools/matdump -v $f; done
    for f in ./matfilerw/src/test/resources/mcos/*.mat; do ./tools/matdump -v -f whos $f; done
fi
if [[ "$ENABLE_MAT73" == "yes" ]]; then
    ./tools/matdump -d ./MSL/Modelica/Resources/Data/Tables/test_v7.3.mat s
fi