#!/bin/bash

#__PARAM__

main()
{
	# 创建临时文件夹
	local tmpdir=$(mktemp -d)
	
	# 截取#__END__后面的内容，这部分内容是一个压缩包，里面保存资源
	sed -nb '/^#__END__$/,$p' $0 | dd of="$tmpdir/pkg.tar" bs=1 skip=9 2>/dev/null
	
	# 解压到临时文件夹里
	tar -xf "$tmpdir/pkg.tar" -C "$tmpdir"
	
	# 执行解压包里的 pkg/cmd.sh 文件
	chmod +x "$tmpdir/pkg/cmd.sh"
	local path=$(realpath "$0")
	path=${path%/*}
	"$tmpdir/pkg/cmd.sh" "$path" "${@}"
	
	# 删除临时文件夹
	rm -rf "$tmpdir"
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
			echo "Name: $NAME"
			exit 0
			;;
		"--version" | "-v")
			echo "Version: $VERSION"
			exit 0
			;;
		"--author" | "-a")
			echo "Author: $AUTHOR"
			exit 0
			;;
		"--description" | "-d")
			echo "Description: $DESCRIPTION"
			exit 0
			;;
		"--pkg-param" | "-p")
			shift
			;;
		*)
			echo "Invalid param!" >&2
			exit 1
			;;
	esac
fi

main "${@}"

exit 0
#__END__
