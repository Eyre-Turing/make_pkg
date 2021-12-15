#!/bin/bash

# 自己的路径
self_path=$(realpath "$0")
self_path=${self_path%/*}

# 参数传入补丁包路径
save_pkg_path=$1
shift

echo "pkg path is: ${save_pkg_path}"

while [ $# -gt 0 ]; do
	echo "Your pkg param: $1"
	shift
done

echo 'Hello world, the upgpkg you run is my first upgpkg.'
echo 'Now, I would like to write a flag file to current dir.'

cp "$self_path/files/flag.jpg" ./

echo 'Yes, the flag file is a jpg file.'
echo 'If you can see the flag file, then means succeed.'
