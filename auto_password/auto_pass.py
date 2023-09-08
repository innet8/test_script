import requests, datetime, json
from httpsig.requests_auth import HTTPSignatureAuth
import re
import os
import json
import sys
from ansible_runner import run
import math

import string
import random

#### 主要功能
# 定时任务每周修改一次
# 获取jumpserver 账号密码端口相关信息
# 生成ansible-host修改密码列表持久化本地打日志
# ansible-playbook  增加密钥
# ansible-playbook  修改密码
# 调用接口更新修改jumpserver 密码


def event_handler(data):
    if data["event"] == "playbook_on_stats":  # 获取特定事件中的数据
        print("抓取事件数据")
        print("{}: {}".format("event_data", data["event_data"]))
        # 获取执行失败的机器
        unreachable_hosts = set(data["event_data"]["dark"].keys())
        failed_hosts = set(data["event_data"]["failures"].keys())
        problem_hosts = list(unreachable_hosts | failed_hosts)
        # 移除执行失败的主机 不进行更改
        print(f"执行失败的host:{problem_hosts}")
        print("执行失败主机数量", len(problem_hosts))

        for i in problem_hosts:
            # 读取文件
            with open("data.json", "r") as f:
                data = json.loads(f.read())

            # 修改数据
            try:
                del data[i]
            except KeyError as err:
                pass

            # 保存更新后的数据
            with open("data.json", "w") as f:
                json.dump(data, f)

        return True  # 只保存特定事件数据
    elif data["event"] == "runner_on_ok" and data["event_data"]["task"] == "test task":
        print("{}: {}".format("命令输出", data["event_data"]["res"]["stdout"]))
        return True  # 只保存特定事件数据
    else:
        print("\n产生事件")
        for k, v in data.items():
            print("{}: {}".format(k, v))
        return False  # 不保存其他事件数据
def new_password(length):
            alpha   = "abcdefghijklmnopqrstuvwxyz"
            num     = "0123456789"
            special = "~!#%^&*()_+,.?+-"
            #pass_len = int(input("Enter Password Length: "))
            pass_len=random.randint(length,length)
            # length of password  5:3:2
            alpha_len   = pass_len//2
            num_len     = math.ceil(pass_len*30/100)
            special_len = pass_len-(alpha_len+num_len)
            password = []
            def generate_pass(length, array, is_alpha=False):
                for i in range(length):
                    index = random.randint(0, len(array) - 1)
                    character = array[index]
            
                    if is_alpha:
                        case = random.randint(0, 1)
                        if case == 1:
                            character = character.upper()
                    password.append(character)
            generate_pass(alpha_len, alpha, True)
            generate_pass(num_len, num)
            generate_pass(special_len, special)
            random.shuffle(password)
            gen_password = ""
            for i in password:
                gen_password = gen_password + str(i)
            
            return gen_password

def new_password_bak(length):
    characters = string.ascii_letters + string.digits + string.punctuation
    characters = characters.replace("'", "")
    characters = characters.replace("@", "")
    characters = characters.replace('"', "")
    password = "".join(random.choice(characters) for _ in range(length))
    return password


class jumserver:
    def __init__(self, KeyID, SecretID, jms_url):
        self.auth = None
        self.jms_url = jms_url
        self.hostlist = {}
        self.KeyID = KeyID
        self.SecretID = SecretID

    def get_auth(self):
        signature_headers = ["(request-target)", "accept", "date"]
        self.auth = HTTPSignatureAuth(
            key_id=self.KeyID,
            secret=self.SecretID,
            algorithm="hmac-sha256",
            headers=signature_headers,
        )

    # 更新用户密码
    def up_user_password(self, id):
        url = self.jms_url + "/api/v1/assets/assets/%s/" % id
        gmt_form = "%a, %d %b %Y %H:%M:%S GMT"
        headers = {
            "Accept": "application/json",
            "X-JMS-ORG": "00000000-0000-0000-0000-000000000002",
            "Date": datetime.datetime.utcnow().strftime(gmt_form),
        }
        response = requests.get(url, auth=self.auth, headers=headers)
        data = json.loads(response.text)
        for i in range(len(data["accounts"])):
            self.get_host_password(data["accounts"][i]["id"])

    # 获取用户信息
    def get_host_info(self):
        url = self.jms_url + "/api/v1/assets/assets/"

        gmt_form = "%a, %d %b %Y %H:%M:%S GMT"
        headers = {
            "Accept": "application/json",
            "X-JMS-ORG": "00000000-0000-0000-0000-000000000002",
            "Date": datetime.datetime.utcnow().strftime(gmt_form),
        }

        response = requests.get(url, auth=self.auth, headers=headers)
        data = json.loads(response.text)

        for i in range(len(data)):
            self.hostlist[data[i]["address"]] = {
                "port": data[i]["protocols"][0]["port"],
                "created_by": data[i]["created_by"],
                "nodes_display": data[i]["nodes_display"],
                "address": data[i]["address"],
                "id": data[i]["id"],
            }
            self.up_user_password(self.hostlist[data[i]["address"]]["id"])

        with open("data.json", "w+") as file:
            file.write(json.dumps(j.hostlist, indent=4))
            file.close()

    # 根据信息id 获取主机密码
    def get_host_password(self, id):
        url = self.jms_url + "/api/v1/accounts/account-secrets/%s/" % id
        gmt_form = "%a, %d %b %Y %H:%M:%S GMT"
        headers = {
            "Accept": "application/json",
            "X-JMS-ORG": "00000000-0000-0000-0000-000000000002",
            "Date": datetime.datetime.utcnow().strftime(gmt_form),
        }
        response = requests.get(url, auth=self.auth, headers=headers)
        data = json.loads(response.text)
        try:
            self.hostlist[data["asset"]["address"]]["password"] = data["secret"]
            self.hostlist[data["asset"]["address"]]["username"] = data["name"]
            self.hostlist[data["asset"]["address"]]["data"] = data

        except KeyError as err:
            pass

        return data["name"], data["secret"], data

    # 根据信息id  更新jumpserver 密码记录
    def update_jumpserver_password(self, data):
        url = self.jms_url + "/api/v1/accounts/accounts/%s/" % data["id"]
        gmt_form = "%a, %d %b %Y %H:%M:%S GMT"
        headers = {
            "Accept": "application/json",
            "X-JMS-ORG": "00000000-0000-0000-0000-000000000002",
            "Date": datetime.datetime.utcnow().strftime(gmt_form),
        }
        response = requests.put(url, auth=self.auth, headers=headers, json=data)

        print(
            "更新jumpserver 记录",
            response.status_code,
            data["secret"],
            data["username"],
            data["asset"]["address"],
        )


if __name__ == "__main__":
    j = jumserver(
        jms_url="http://154.207.98.172",
        KeyID="9f8c2c92-68dd-4fd8-8790-3473ac7586b9",
        SecretID="3c1a525a-a1e0-43f7-aac4-08edf1c8ab5e",
    )
    j.get_auth()
    # jumpserver获取信息相关
    j.get_host_info()
    with open("data.json", "r") as f:
        data = json.loads(f.read())
        print("更新主机数量", len(data))
        with open("hosts", "w") as f:
            f.write("[server]\n")
        for k, v in data.items():
            # 待匹配字符串
            p = v["password"]
            # 使用正则表达式进行匹配
            match = re.match(r"^-----BEGIN OPENSSH PRIVATE KEY", p)
            # 判断是否匹配成功
            if match:
                continue
            else:
                with open("hosts", "a") as f:
                    new_pass = new_password(16)
                    f.write(
                        "%s  ansible_port=\"%s\" ansible_user=\"%s\"  ansible_ssh_pass=\"%s\" new_password=\"%s\"  \n"
                        % (k, v["port"], v["username"], v["password"], new_pass)
                    )
                    data[k]["data"]["secret"] = new_pass

        # 保存更新后的数据
        with open("data.json", "w") as f:
            f.write(json.dumps(data, indent=4))

    # 设置 ANSIBLE_SSH_CONTROL_PATH 环境变量

    def run_ansible_playbook(playbook_path, inventory_path):
        # 运行 playbook
        result = run(
            playbook=playbook_path,
            inventory=inventory_path,
            event_handler=event_handler,  # 配置handler方法
        )

        # 打印执行结果
        print(result)

    # playbook_path = '/home/ansible/hello.yaml'
    # inventory_path = '/home/ansible/hosts'
    playbook_path = "/Users/mac-512/script/up_password.yaml"
    inventory_path = "/Users/mac-512/script/hosts2"
    # 执行ansible 修改linux密码
    run_ansible_playbook(playbook_path, inventory_path)
    # 修改jumpserver_password 资产显示密码
    with open("data.json", "r") as f:
        data = json.loads(f.read())
        print("更新主机数量", len(data))
        for k, v in data.items():
            # 待匹配字符串
            p = v["password"]
            # 使用正则表达式进行匹配
            match = re.match(r"^-----BEGIN OPENSSH PRIVATE KEY", p)
            # 判断是否匹配成功
            if match:
                continue
            else:
                ds = data[k]["data"]

                j.update_jumpserver_password(ds)
