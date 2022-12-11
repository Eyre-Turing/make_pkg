#!/bin/bash

#__PARAM__

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

main()
{
	# 创建临时文件夹
	local tmpdir=$(mktemp -d)

	# 截取#__END__后面的内容，这部分内容是一个tar包，里面保存资源。截取并解压到临时文件夹里
	if ! sed -b '1,/^#__END__$/d' -- "$0" 2>/dev/null | dd_gauge "Unpack: " "$(stat -c %s -- "$0")" " unpacked" | tar -x -C "$tmpdir"; then
		echo "Unpack pkg body fail"! >&2
		rm -rf "$tmpdir"
		return 1
	fi

	# 执行解压包里的 pkg/cmd.sh 文件
	if ! chmod +x "$tmpdir/pkg/cmd.sh"; then
		echo "Make pkg body script runnable fail"! >&2
		rm -rf "$tmpdir"
		return 1
	fi

	/bin/bash "$tmpdir/pkg/cmd.sh" "$(realpath "$0")" "${@}"
	local status=$?

	# 删除临时文件夹
	rm -rf "$tmpdir"

	return $status
}

# 解析调用参数
if [ $# -gt 0 ]; then
	case $1 in
		"--help" | "-h")
			echo "Usage:"
			echo "$0 for run the pkg main program, or $0 [option] for see pkg info."
			echo "  Option: "
			echo "  --name        | -n   see product name."
			echo "  --version     | -v   see product version."
			echo "  --author      | -a   see product author."
			echo "  --description | -d   see product description."
			echo "  --pkg-param   | -p   then pass the operation parameters to the packet."
			exit 0
			;;
		"--name" | "-n")
			echo "$NAME"
			exit 0
			;;
		"--version" | "-v")
			echo "$VERSION"
			exit 0
			;;
		"--author" | "-a")
			echo "$AUTHOR"
			exit 0
			;;
		"--description" | "-d")
			echo "$DESCRIPTION"
			exit 0
			;;
		"--pkg-param" | "-p")
			shift
			;;
		*)
			echo "Invalid param"! >&2
			exit 1
			;;
	esac
fi

main "${@}"

exit $?
#__END__
