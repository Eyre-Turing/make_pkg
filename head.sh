#!/bin/bash

#__PARAM__

main()
{
	# 创建临时文件夹
	local tmpdir=$(mktemp -d)
	
	# 截取#__END__后面的内容，这部分内容是一个压缩包，里面保存资源
	if ! sed -b '1,/^#__END__$/d' $0 >"$tmpdir/pkg.tar" 2>/dev/null; then
		echo "Split pkg body fail"! >&2
		rm -rf "$tmpdir"
		exit 1
	fi
	
	# 解压到临时文件夹里
	if ! tar -xf "$tmpdir/pkg.tar" -C "$tmpdir"; then
		echo "Unpack pkg body fail"! >&2
		rm -rf "$tmpdir"
		exit 2
	fi
	
	# 执行解压包里的 pkg/cmd.sh 文件
	if ! chmod +x "$tmpdir/pkg/cmd.sh"; then
		echo "Make pkg body script runnable fail"! >&2
		rm -rf "$tmpdir"
		exit 3
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
