#!/bin/bash
rm -rf result/*
title="硬盘读写测试"
ansible-playbook -i hosts test_ioread.yaml -v -f 10

shell_tr=""
shell_ip="["
shell_write_data="["
shell_read_data="["

for i in $(ls result); do

    READ=$(cat result/$i | grep "READ" | sed 's/, run=.*//g' | awk '{print $2,$3}' | sed 's/,//g')
    WRITE=$(cat result/$i | grep "WRITE" | sed 's/, run=.*//g' | awk '{print $2,$3}' | sed 's/,//g')
    ip=$(echo $i | sed 's/.log//g')
    _READ=$(printf "%.0f" $(echo ${READ} | awk '{print $2}' | sed 's#(##g;s#)##g;s#MB/s##g'))

    _WRITE=$(printf "%.0f" $(echo ${WRITE} | awk '{print $2}' | sed 's#(##g;s#)##g;s#MB/s##g'))

 
    shell_write_data=$shell_write_data"$_WRITE,"
    shell_read_data=$shell_read_data"$_READ,"
    shell_ip=$shell_ip"\"$ip\","
    shell_tr=$shell_tr"<tr><td>$ip</td><td>$READ</td><td>$WRITE</td></tr>"

done

shell_ip=$(echo $shell_ip | sed 's#,$##g')"]"
shell_write_data=$(echo $shell_write_data | sed 's#,$##g')"]"
shell_read_data=$(echo $shell_read_data | sed 's#,$##g')"]"

eval "cat  <<EOF
        $(<./template.html)
EOF" >${title}.html
