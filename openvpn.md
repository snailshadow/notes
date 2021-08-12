# openvpn

## 1 基础环境介绍

openvpn01 39.106.14.133 	172.26.20.34		centos7.9

openvpn02 39.106.31.58		172.26.20.33		centos7.9

## 2 安装openvpn

 ```bash
 yum install epel-release -y
 yum install openvpn -y #openvpn 服务端
 yum install easy-rsa -y  #证书管理工具
 cp /usr/share/doc/openvpn-2.4.11/sample/sample-config-files/server.conf /etc/openvpn/
 cp -r /usr/share/easy-rsa/ /etc/openvpn/easyrsa-server
 cp /usr/share/doc/easy-rsa-3.0.8/vars.example /etc/openvpn/easyrsa-server/3/vars
 ```

## 3 初始化pki和CA签发机构

```bash
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req server nopass
```





## server端配置文件

```bash
# cat /etc/openvpn/server.conf  |grep -Ev "^(#|;|^$)"
local 172.26.20.34
port 1194
proto tcp
dev tun
ca /etc/openvpn/certs/ca.crt
cert /etc/openvpn/certs/server.crt
key /etc/openvpn/certs/server.key  # This file should be kept secret
dh /etc/openvpn/certs/dh.pem
server 10.8.0.0 255.255.255.0
push "route 172.26.20.0 255.255.255.0"
client-to-client
keepalive 10 120
cipher AES-256-CBC
user nobody
group nobody
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log-append  /var/log/openvpn/openvpn.log
verb 3
mute 20
```

## client 配置文件

```shell
# tree /etc/openvpn/client/collin
collin/
├── ca.crt
├── client.ovpn
├── collin.crt
└── collin.key

# cat /etc/openvpn/client/collin/client.ovpn 
client
dev tun
proto tcp
remote 39.106.14.133 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert collin.crt
key collin.key
remote-cert-tls server
#tls-auth ta.key 1
cipher AES-256-CBC
verb 3
```



