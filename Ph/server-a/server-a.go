package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/exec"
	"time"

	"github.com/creack/pty"
)

func executeCommand(command string) error {

	cmd := exec.Command("bash", "-c", command)

	ptmx, err := pty.Start(cmd)
	if err != nil {
		return err
	}
	defer ptmx.Close()

	go io.Copy(os.Stdout, ptmx)
	go io.Copy(ptmx, os.Stdin)

	err = cmd.Wait()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return exitErr
		}
		return err
	}

	return nil
}

// func executeCommand(command string) (string, error) {

// 	cmd := exec.Command("bash", "-c", command)

// 	var stdout, stderr bytes.Buffer
// 	cmd.Stdout = &stdout
// 	cmd.Stderr = &stderr

// 	err := cmd.Run()
// 	if err != nil {
// 		return "", fmt.Errorf("执行命令时发生错误：%w", err)
// 	}

// 	output := stdout.String()
// 	if len(output) > 0 {
// 		fmt.Println(output)
// 	}

// 	errOutput := stderr.String()
// 	if len(errOutput) > 0 {
// 		fmt.Fprintln(os.Stderr, errOutput)
// 	}

// 	return output, nil
// }

func startSocket(socketPath string) (err error) {

	// 创建Unix域Socket监听
	ln, err := net.ListenUnix("unix", &net.UnixAddr{socketPath, "unix"})
	if err != nil {
		fmt.Println("无法启动监听：", err)
		return err
	}

	fmt.Println("已启动监听")

	// 接收连接
	conn, err := ln.AcceptUnix()
	if err != nil {
		fmt.Println("无法接受连接：", err)
		return err
	}

	fmt.Println("已接受连接")

	// 接收心跳消息并回复
	buffer := make([]byte, 1024)
	for {
		n, err := conn.Read(buffer)
		if err != nil {
			fmt.Println("无法接收心跳消息:", err)
			break
		}

		heartbeat := string(buffer[:n])
		fmt.Println("收到心跳消息:", heartbeat)

		// 发送心跳回复
		reply := "heartbeat reply"
		_, err = conn.Write([]byte(reply))
		if err != nil {
			fmt.Println("无法发送心跳回复:", err)
			break
		}

		fmt.Println("已发送心跳回复:", reply)
	}
	defer conn.Close()

	return nil
}

func socketConnect(socketPath string) (err error) {

	conn, err := net.DialUnix("unix", nil, &net.UnixAddr{socketPath, "unix"})

	if err != nil {
		fmt.Println("无法连接到Socket:", err)
		return err
	}

	fmt.Println("已连接到Socket")

	for {
		// 发送心跳消息
		message := "heartbeat"
		_, err = conn.Write([]byte(message))
		if err != nil {
			fmt.Println("无法发送心跳消息:", err)
			break
		} else {
			fmt.Println("已发送心跳消息:", message)
		}

		// 等待对方回复
		buffer := make([]byte, 1024)
		conn.SetReadDeadline(time.Now().Add(2 * time.Second))
		n, err := conn.Read(buffer)
		if err != nil {
			fmt.Println("无法接收心跳回复:", err)
			break
		}

		reply := string(buffer[:n])
		fmt.Println("收到心跳回复:", reply)

		time.Sleep(1 * time.Second)
	}

	defer conn.Close()

	return nil
}

var Pool map[string]int

func init() {
	Pool = make(map[string]int)

}

func main() {

	socketPath := "../server-a.sock"
	// 检查文件是否存在
	if _, err := os.Stat(socketPath); os.IsNotExist(err) {
		fmt.Println("文件不存在")
	} else {
		// 删除文件
		err := os.Remove(socketPath)
		if err != nil {
			fmt.Println("删除文件失败:", err)
		} else {
			fmt.Println("成功删除文件")
		}
	}
	go func() {
		log.Println("连接服务器")
		i := 0
		for {
			err := socketConnect("../server-b.sock")
			if err != nil {
				log.Println("失败连接", err)
				if i == 5 {
					log.Println("超时连接拉起对面服务器")

					//查看进程是否存在
					// if p, ok := Pool["server-b"]; ok {
					// 	log.Println("进程存杀死进程")
					// 	log.Println("kill -9 " + p)
					// 	log.Println(executeCommand("kill -9 " + p))

					// }
					cmd := "go run ../server-b/server-b.go     "

					err := executeCommand(cmd)

					if err != nil {
						log.Println("进程拉起失败:", err)
					} else {

						log.Println("进程已开始执行", err)
					}

					// pid, err := executeCommand("nohup go run ../server-b/server-b.go>/dev/null 2>&1 & echo $! > run.pid&")
					// if err != nil {
					// 	log.Println("进程拉起失败")

					// } else {
					// 	Pool["server-b"] = pid
					// 	i = 0
					// }

				}
			} else {
				log.Println("连接成功")
				time.Sleep(60 * time.Second)

				i = 0
			}

			time.Sleep(1 * time.Second)
			i += 1

		}

	}()
	startSocket(socketPath)

}
