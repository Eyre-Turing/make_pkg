#!/bin/bash

# 自己的路径
self_path=$(dirname "$(realpath "$0")")

# 参数传入补丁包路径
save_pkg_path=$1
shift

# 加载接口
. "${self_path}/pkg-funcs.sh"

# 下面的内容可以随便改

# 获取包信息示例
echo "pkg path is: ${save_pkg_path}"
echo "pkg product name is: $("${save_pkg_path}" --name)"
echo "pkg version is: $("${save_pkg_path}" --version)"
echo "pkg author is: $("${save_pkg_path}" --author)"
echo "pkg description is: $("${save_pkg_path}" --description)"

# 遍历传入参数示例
while [ $# -gt 0 ]; do
	echo "Your pkg param: $1"
	shift
done

# 版本比较示例, version_gt 的具体用法参见 pkg-funcs.sh
if version_gt "$("${save_pkg_path}" --version)" "3.0.1"; then
	echo "pkg version greater than 3.0.1."
fi

# 输出提示信息示例
echo 'Hello world, the upgpkg you run is my first upgpkg.'
echo 'Now, I would like to write a flag file to current dir.'

# 包放出文件示例
cp "$self_path/files/flag.jpg" ./

echo 'Yes, the flag file is a jpg file.'
echo 'If you can see the flag file, then means succeed.'
