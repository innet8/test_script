#!/bin/bash
rm -rf result/*
title="高级配置测试"
ansible-playbook -i hosts test_network.yaml -v  -f 10



#生成mardown

echo "# $title" > ${title}.md
echo "|ip|上传速度|下载速度|" >>${title}.md
echo "| ------- | ------- | ------- |" >>${title}.md
for i in $(ls result); do
    Download=$(cat result/$i | grep "Download")
    Upload=$(cat result/$i | grep "Upload")

    ip=$(echo $i | sed 's/.log//g')
    echo "| $ip | $Upload | $Download |" >>${title}.md

done
