#!/bin/bash
# rm -rf result/*
title="硬盘读写测试"
# ansible-playbook -i hosts test_ioread.yaml -v -f 10


shell_tr=""
shell_ip="["
shell_write_data="["
shell_read_data="["

for i in $(ls result); do

    READ=$(cat result/$i | grep "READ" | sed 's/, run=.*//g' | awk '{print $2,$3}' | sed 's/,//g')
    WRITE=$(cat result/$i | grep "WRITE" | sed 's/, run=.*//g' | awk '{print $2,$3}' | sed 's/,//g')
    _READ=$(echo $READ | awk -F ':' '{print $2}' | awk -F ',' '{print $1}' | awk -F '(' '{print $2}' | )




    
        echo $READ| awk   '{print $2}'|sed 's#MB/s)##g'



    __READ=$(printf "%.0f" $_READ)
    __WRITE=$(printf "%.0f" $_WRITE)
    READ=$(cat result/$i | grep "READ" | sed 's/, run=.*//g')
    ip=$(echo $i | sed 's/.log//g')
    shell_write_data=$shell_write_data"$__WRITE,"

    shell_read_data=$shell_read_data"$__READ,"
    shell_ip=$shell_ip"\"$ip\","
    echo "| $ip | $READ | $WRITE |" >>${title}.md
    shell_tr=$shell_tr"<tr><td>$ip</td><td>$READ</td><td>$WRITE</td></tr>"

    
done

shell_ip=$(echo $shell_ip|sed 's#,$##g')"]"
shell_write_data=$(echo $shell_write_data|sed 's#,$##g')"]"
shell_read_data=$(echo $shell_read_data|sed 's#,$##g')"]"

echo $shell_read_data
eval "cat  <<EOF
        $(<./tmp.html)
EOF" >${title}.html





