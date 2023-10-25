package main

import (
	"fmt"
	"net"
	"os"
	"time"
)

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
func socketConnect(socketPath string) {

	conn, err := net.DialUnix("unix", nil, &net.UnixAddr{socketPath, "unix"})

	if err != nil {
		fmt.Println("无法连接到Socket:", err)
		return
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

	conn.Close()
}
func main() {
	socketPath := "../server-b.sock"
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
	go startSocket(socketPath)

	socketConnect("../server-a.sock")

}
