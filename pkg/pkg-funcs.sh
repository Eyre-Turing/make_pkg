#!/bin/bash

# 参数1代表的版本号是否比参数2的高
# 若成立，则返回0；否则返回1
# 注意，在shell里，返回0才是真!!!!!!!!
# 调用示例:
# if version_gt 1.2.3 1.11.2; then
#      echo yes
# else
#      echo no
# fi
# 上述示例会输出 no
version_gt()
{
	local version_a=$1
	local version_b=$2
	if echo $version_a | grep '[^0-9.]' >/dev/null; then
		echo "Invalid version '$version_a'"! >&2
		return 1
	fi
	if echo $version_b | grep '[^0-9.]' >/dev/null; then
		echo "Invalid version '$version_b'"! >&2
		return 0
	fi
	local alen=$(echo $version_a | awk -F '.' '{print NF}')
	local blen=$(echo $version_b | awk -F '.' '{print NF}')
	local len=$alen
	[ $alen -lt $blen ] && len=$blen
	for i in $(seq 1 $len); do
		local ai=$(echo $version_a | awk -F '.' "{print \$${i}}")
		local bi=$(echo $version_b | awk -F '.' "{print \$${i}}")
		[ -z "$ai" ] && ai=0
		[ -z "$bi" ] && bi=0
		if [ $ai -gt $bi ]; then
			return 0
		fi
		if [ $ai -lt $bi ]; then
			return 1
		fi
	done
	return 1
}

# 参数1代表的版本号是否比参数2的低
version_lt()
{
	local version_a=$1
	local version_b=$2
	if echo $version_a | grep '[^0-9.]' >/dev/null; then
		echo "Invalid version '$version_a'"! >&2
		return 1
	fi
	if echo $version_b | grep '[^0-9.]' >/dev/null; then
		echo "Invalid version '$version_b'"! >&2
		return 0
	fi
	local alen=$(echo $version_a | awk -F '.' '{print NF}')
	local blen=$(echo $version_b | awk -F '.' '{print NF}')
	local len=$alen
	[ $alen -lt $blen ] && len=$blen
	for i in $(seq 1 $len); do
		local ai=$(echo $version_a | awk -F '.' "{print \$${i}}")
		local bi=$(echo $version_b | awk -F '.' "{print \$${i}}")
		[ -z "$ai" ] && ai=0
		[ -z "$bi" ] && bi=0
		if [ $ai -lt $bi ]; then
			return 0
		fi
		if [ $ai -gt $bi ]; then
			return 1
		fi
	done
	return 1
}

# 参数1代表的版本号是否不低于参数2的
version_ge()
{
	! version_lt "$@"
}

# 参数1代表的版本号是否不高于参数2的
version_le()
{
	! version_gt "$@"
}

# 参数1代表的版本号是否与参数2的相同
version_eq()
{
	version_le "$@" && version_ge "$@"
}

# 参数1代表的版本号是否与参数2的不同
version_ne()
{
	! version_eq "$@"
}
