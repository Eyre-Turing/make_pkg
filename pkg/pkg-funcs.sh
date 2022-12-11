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
	version_gt "$version_b" "$version_a"
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

# 打印进度条
# 参数1 label	标签，显示在最左边
# 参数2 current	当前进度，0~100的整数
# 参数3 tip		提示信息，显示在最右边（默认为当前进度）
# 参数4 length	进度条长度，整数，字符个数（默认为50）
# 参数5 chr		填充字符，进度条填充用（默认为=）
# 显示如：
# label[========             ]tip
print_gauge()
{
	local label=$1					# 标签，显示在最左边
	local current=$2				# 当前进度，0~100的整数
	local tip=${3:-" $current%%"}	# 提示信息，显示在最右边（默认为当前进度）
	local length=${4:-50}			# 进度条长度，整数，字符个数（默认为50）
	local chr=${5:-=}				# 填充字符，进度条填充用（默认为=）

	local cur_chr_n=$((current * length / 100))
	printf "\r${label}["
	local i
	for ((i = 0; i < cur_chr_n; i++)); do
		printf "$chr"
	done
	for ((i = cur_chr_n; i < length; i++)); do
		printf " "
	done
	printf "]${tip}"
}

# 读入标准输入的方式统计进度条
# 参数1 label		标签，显示在最左边
# 参数2 size			标准输入流总大小
# 参数3 over_tip		结束时的提示（默认为100%）
# 参数4 length		进度条长度，整数，字符个数（默认为50）
# 参数5 chr			填充字符，进度条填充用（默认为=）
dd_gauge()
{
	local label=$1					# 标签，显示在最左边
	local size=$2					# 标准输入流总大小
	local over_tip=${3:-" 100%%"}	# 结束时的提示（默认为100%）
	local length=${4:-50}			# 进度条长度，整数，字符个数（默认为50）
	local chr=${5:-=}				# 填充字符，进度条填充用（默认为=）

	local count=0
	local current
	local tip=""
	while ((count < size)); do
		dd bs=512 count=10000 2>/dev/null
		((count += 5120000))
		((current = count * 100 / size))
		((current > 100)) && current=100
		[ "$current" == "100" ] && tip=$over_tip
		print_gauge "$label" "$current" "$tip" "$length" "$chr" >&2
	done
	echo >&2
}

# 对dd_gauge封装一层，自动计算文件大小
# 参数1 label		标签，显示在最左边
# 参数2 filename		文件名
# 参数3 over_tip		结束时的提示（默认为100%）
# 参数4 length		进度条长度，整数，字符个数（默认为50）
# 参数5 chr			填充字符，进度条填充用（默认为=）
dd_gauge_from_file()
{
	local label=$1					# 标签，显示在最左边
	local filename=$2				# 文件名
	local over_tip=${3:-" 100%%"}	# 结束时的提示（默认为100%）
	local length=${4:-50}			# 进度条长度，整数，字符个数（默认为50）
	local chr=${5:-=}				# 填充字符，进度条填充用（默认为=）

	local size=$(stat -c %s -- "$filename")
	dd_gauge "$label" "$size" "$over_tip" "$length" "$chr" <"$filename"
}

# 读入标准输入的方式按需求显示进度条
# 参数1 label		标签，显示在最左边
# 参数2 over_tip		结束时的提示（默认为当前进度）
# 参数3 length		进度条长度，整数，字符个数（默认为50）
# 参数4 chr			填充字符，进度条填充用（默认为=）
show_gauge()
{
	local label=$1			# 标签，显示在最左边
	local over_tip=$2		# 结束时的提示（默认为当前进度）
	local length=${3:-50}	# 进度条长度，整数，字符个数（默认为50）
	local chr=${4:-=}		# 填充字符，进度条填充用（默认为=）

	local current
	local tmp
	while read current; do
		tmp=$current
		print_gauge "$label" "$current" "" "$length" "$chr" >&2
	done
	print_gauge "$label" "$tmp" "$over_tip" "$length" "$chr" >&2
	echo >&2
}
