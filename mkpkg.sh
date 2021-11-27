#!/bin/bash

# 复制引导脚本到 pkg.run 包头部，只复制到 #__END__ 后面如果还有内容去掉
sed -n '1,/^#__END__$/p' head.sh >pkg.run

# 替换 pkg.run 的 #__PARAM__ 部分为包信息
param_flag_line=$(grep -n '^#__PARAM__$' pkg.run | awk -F ':' '{print $1}')
sed -i "${param_flag_line}r pkgparam.txt" pkg.run

# 转换为 unix 模式，防止不小心以 dos 模式保存时 \r\n 行尾对运行有影响
if which dos2unix 2>/dev/null; then
	dos2unix pkg.run
else
	echo 'skip dos2unix, because dos2unix command not found.' >&2
fi

# 打包资源文件
tar -c pkg -f pkg.tar

# 追加复制资源文件到 pkg.run 文件底部
dd if=pkg.tar >>pkg.run 2>/dev/null

# 删除
rm -f pkg.tar
