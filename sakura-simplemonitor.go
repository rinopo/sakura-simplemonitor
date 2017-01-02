package main

import (
	"fmt"
	"net"
	"os"

	"github.com/sacloud/libsacloud/api"
)

func main() {
	var err error

	if len(os.Args) != 2 {
		fmt.Println("error: Usage: " + os.Args[0] + " さくらのユーザー名")
		os.Exit(1)
	}

	var user = os.Args[1]

	var host = user + ".sakura.ne.jp"

	addr, err := net.LookupIP(host)

	if err != nil {
		fmt.Println("error:", err)
		os.Exit(1)
	}

	// settings
	var (
		token  = "%%token%%"
		secret = "%%secret%%"

		zone = "tk1a" // 東京第1ゾーン
		//      zone         = "is1a" // 石狩第1ゾーン
		//      zone         = "is1b" // 石狩第2ゾーン
		//      zone         = "tk1v" // サンドボックス（シンプル監視動かない）

		target      = addr[0].String()
		description = user
		loop        = 60
		port        = "80"
		path        = "/"
		status      = "200"
		//      webhookurl   = ""
	)

	// authorize
	client := api.NewClient(token, secret, zone)

	// create a simple monitor
	fmt.Println("creating a simple monitor")
	param := client.SimpleMonitor.New(target)
	param.Description = description
	param.SetDelayLoop(loop)
	param.SetHealthCheckHTTP(port, path, status, host)
	param.EnableNotifyEmail(true)
	//  param.EnableNofitySlack(webhookurl)

	param, err = client.SimpleMonitor.Create(param)

	if err != nil {
		fmt.Println("error:", err)
		os.Exit(1)
	}

	fmt.Println("created a simple monitor")
}
