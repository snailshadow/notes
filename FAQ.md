# FAQ

## Linux

### FAQ01-20210319 Ubuntu ssh链接报错"服务器发送了一个意外的数据包"

- 问题现象

  ssh 连接服务器报错如图

   ![image-20210319162444352](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210319162605.png)

  systemctl status ssh 有很多报错信息

  ![image-20210319162754909](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210319162755.png)

- 解决方法

  1. 修改/etc/ssh/sshd_config，在最后增加一行配置

  ```
  KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha1
  ```

  2. 重启sshd服务 `systemctl restsrt sshd`

  