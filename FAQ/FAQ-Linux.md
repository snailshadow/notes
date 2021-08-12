# FAQ

## Linux

### FAQ01-20210319 Ubuntu ssh链接报错"服务器发送了一个意外的数据包"

1. 问题现象

ssh 连接服务器报错如图

 ![image-20210319162444352](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210319162605.png)

systemctl status ssh 有很多报错信息

![image-20210319162754909](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210319162755.png)

2. 解决方法
   修改/etc/ssh/sshd_config，在最后增加一行配置，修改后重启sshd服务 `systemctl restsrt sshd`

```
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha1
```



### FAQ02-20210602 CentOS 6 解决 Device eth0 does not seem to be present

1. 问题现象

   `ifconfig -a` 看不到eth0信息，且执行`service network restart` 报错“Device eth0 does not seem to be present”。

2. 问题原因

   在虚拟机（Vmware）中移动了Centos系统对应的文件，导致重新配置时，网卡的MAC地址变了，输入ifconfig -a,找不到eth0

3. 解决方法

   ```bash
   # rm -rf /etc/udev/rules.d/70-persistent-net.rules
   # reboot
   ```

   



