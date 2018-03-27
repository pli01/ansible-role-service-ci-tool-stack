#!/bin/bash

packagename=${1:? $(basename $0) PACKAGENAME VERSION needed}
version=${2:-latest}

filename=${packagename}-${version}

[ -d dist ] && rm -rf dist
mkdir -p dist

( cd build && tar --exclude ".git"  -zcvf ../dist/${filename}.tar.gz . )

echo "# Package generated"
ls -l dist/${filename}.tar.gz
