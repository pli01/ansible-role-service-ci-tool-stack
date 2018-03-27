#!/bin/bash
set -x

[ -d build ] && rm -rf build
mkdir -p build

echo "# Prepare build directory"
( find * -type f ! -regex "build" -print0 | tar cf - --null -T - ) | ( cd build/ && tar xvf -)

echo "# Build requirements"
( cd build
  bash -x build.sh
)
