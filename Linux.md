# Linux 基础

## 1 基础小知识

1. 开源协议



2. Linux镜像网站
   - CentOS
     https://wiki.centos.org/Download
     http://mirrors.aliyun.com
     http://mirrors.sohu.com
     http://mirrors.163.com
     https://mirrors.tuna.tsinghua.edu.cn/centos/
   - Ubuntu
     http://cdimage.ubuntu.com/releases/ server版
     http://releases.ubuntu.com/ desktop版
   
3. 终端类型  tty 虚拟终端(64个)，pty 伪终端 例如:SSH  `$tty` 查看当前的终端设备

4. GHONE （C，图形库gtk），KDE（C++，图形库qt），XFCE（轻量级桌面）

5. 提示符格式；`echo $PS1`

6. $OLDPWD 存储上一个路径，$PWD 存储当前路径

7. 命令（type -a cmd）
   - 内部命令   enable -n cmd 禁用，enable cmd 启用，enable -n 查看所有禁用的命令
   - 外部命令    whatis cmd，whereis，which
   - 命令别名    alias，unalias，配置在bashrc中，\alias 取消别名命令，使用与原命令
   - 命令缓存    hash -l 查看，hash -r 清空

8. 命令行补全： `apt install bash-completion`

9. history显示时间和用户 

   ```shell
   vim /etc/profile  or ~/.bash_profile
   export HISTCONTROL=ignoreboth   # 忽略重复命令和以空格开头的命令
   export HISTTIMEFORMAT="%F %T `whoami`"
   ```

10. 帮忙文档  mandb（centos7），makewhatis（centos6），man命令：

   1：用户命令
   2：系统调用
   3：C库调用
   4：设备文件及特殊文件
   5：配置文件格式
   6：游戏
   7：杂项
   8：管理类的命令
   9：Linux 内核API

10. windows和linux 换行符

    - windows    \r\n    (hexdump -C filename     0d0a   cat -A filename   显示   ^M$)
    - linux          \r       (hexdump -C filename     0a        cat -A filename   显示   ^$)

11. 编码转换：iconv -f gb2312 -t UTF-8 wingb2312.txt  -o winUTF-8.txt

12. 预定义通配符：man 7 glob

     <img src="C:\Users\Collin.Xia\AppData\Roaming\Typora\typora-user-images\image-20210312161222900.png" alt="image-20210312161222900" style="zoom:65%;" style="margin-left:45px" />

13. 批量修改文件名 `rename 's/txt/txt.bak/'  *.txt`

14. basename 只取文件名（基名），不要路径，dirname 只取路径，不要文件名

15. 显示目录树：tree -d -L 1 /home   

16. 删除大文件：cat /dev/null > filename  or  > filename

17. 硬链接与软连接

    - 硬链接：本质上是同一个文件，innodeId相同，不能跨分区，删除无影响，不支持目录
    - 软连接：本质上是不同的文件，innodeId不同，能跨分区，删除源文件软连接不可用，支持目录

18. JDK配置环境变量

```shell
$ vim /etc/profile
export JAVA_HOME=/usr/lib/jvm/java-1.8.0_171
export JRE_HOME=$JAVA_HOME/jre 
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
```

### 1.1 自定义 .vimrc

```bash
# cat ~/.vimrc
"" #######################################################################
""定义函数SetTitle，自动插入文件头 
autocmd BufNewFile *.py,*.cpp,*.sh,*.java exec ":call SetTitle()"

"" shell文件头
function AddTitlesh()
    call append(0,"\#!/bin/sh")
    call append(1,"# ******************************************************")
    call append(2,"# Author       : Collin.Xia")
    call append(3,"# Last modified: ".strftime("%Y-%m-%d %H:%M"))
    call append(4,"# Email        : tianyu29792569@163.com")
    call append(5,"# blog         : https://www.cnblogs.com/snailshadow")
    call append(6,"# Filename     : ".expand("%:t"))
    call append(7,"# Description  : ")
    call append(8,"# ******************************************************")
    echohl WarningMsg | echo "Successful in adding copyright." | echohl None
endf

"" python文件头
function AddTitlepy()
    call append(0,"\#!/usr/bin/env python")
    call append(1,"# ******************************************************")
    call append(2,"# Author       : Collin.Xia")
    call append(3,"# Last modified: ".strftime("%Y-%m-%d %H:%M"))
    call append(4,"# Email        : tianyu29792569@163.com")
    call append(5,"# blog         : https://www.cnblogs.com/snailshadow")
    call append(6,"# Filename     : ".expand("%:t"))
    call append(7,"# Description  : ")
    call append(8,"# ******************************************************")
    echohl WarningMsg | echo "Successful in adding copyright." | echohl None
endf

"" 更新修改时间
function UpdateTitle()
     normal m'
     execute '/# Last modified/s@:.*$@\=strftime(":\t%Y-%m-%d %H:%M")@'
     normal ''
     normal mk
     execute '/# Filename/s@:.*$@\=":\t".expand("%:t")@'
     execute "noh"
     normal 'k
     echohl WarningMsg | echo "Successful in updating the copyright." | echohl None
endfunction

function TitleDetsh()
    let n=1
    while n < 10
        let line = getline(n)
        if line =~ '^\#\s*\S*Last\smodified\S*.*$'
            call UpdateTitle()
            return
        endif
        let n = n + 1
    endwhile
    call AddTitlesh()
endfunction

function TitleDetpy()
    let n=1
    while n < 10
        let line = getline(n)
        if line =~ '^\#\s*\S*Last\smodified\S*.*$'
            call UpdateTitle()
            return
        endif
        let n = n + 1
    endwhile
    call AddTitlepy()
endfunction

func SetTitle()
    "如果文件类型为.sh文件 
    if &filetype == 'sh'
        call TitleDetsh() 
    elseif &filetype == 'python'
        call TitleDetpy()
    else
        call setline(1,"/*")
        call append(line("."), "* Author: collin.xia")
        call append(line(".")+1, "* Created Time: ".strftime("%c"))
        call append(line(".")+2, "*/")
        call append(line(".")+3, "")
    endif
    "新建文件后，自动定位到文件末尾
    autocmd BufNewFile * normal G
endfunc
set paste
```

### 1.2 vmware网卡变动

```
linux 加了新网卡，配置文件也改好，但是ifconfig 就是没有这个接口，ifup就报错说不能up这个接口。
解决方法，把这个文件干掉，重启。这里是记录当前的网卡信息
/etc/udev/rules.d/70-persistent-net.rules
```



## 2 基础命令

### 2.1 查看硬件信息

1. cpu信息：lscpu  ， cat /proc/cpuinfo
2. 内存信息：free，cat /proc/meminfo
3. 分区信息：lsblk，cat /proc/parttitions

### 2.2 时间和日期

1. date 
   - 日期转换为unix时间戳  `date -d '2021-03-21 00:00:00' +%s` 
   - unix时间戳转换为日期  `date -d @timestamp`

2. clock/hwclock
   - 根据硬件始终校正系统时钟   -s 
   - 根据系统时间校正硬件时钟   -w
3. 时区  /etc/localtime（软连接），# timedatectl set-timezone Asia/Shanghai

### 2.3 会话管理

1. screen
   - 创建：screen -S screenName
   - 查看：screen -ls
   - 进入：screen -x screenName
   - 退出：ctrl+a+d
2. tmux

### 2.4 包管理

1. dpkg 

| ↘                        | rpm                                                          | dpkg                                                         |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 显示所有已安装的套件名称 | rpm -qa                                                      | dpkg -l (小写L)                                              |
| 显示套件包含的所有档案   | rpm -ql                                                      | dpkg -L                                                      |
| 显示特定档案所属套件名称 | rpm -qf /path/to/file                                        | dpkg -S /path/to/file                                        |
| 显示指定套件是否安装     | rpm -q softwarename (只显示套件名称) rpm -qi softwarename (显示套件资讯) | dpkg -l softwarename (小写L,只列出简洁资讯) dpkg -s softwarename (显示详细资讯) |

2. apt-file 

   搜索文件/命令

```shell
$ apt install apt-file
$ apt update
$ apt list locate  或者 apt list |grep locate
$ apt search locate
```





### 2.5  tr

tr命令：转换，删除，合并重复字符

```bash
$ tr 'a-z' 'A-Z' </etc/issue  # 小写字母转换为大写字母
$ tr -d 'abc' </etc/fstab # 删除abc任意字符
$ df | grep '^/dev/' |tr -s ' ' %|cut -d% -f5|sort -n|tail -1 #-s 合并重复字符
```

### 2.6 grep

1. grep 过滤注释行和空行  `# grep  -v -e ^[[:space:]].*# -e ^# -e ^$ 1.txt`
2. 单词匹配
   - 词首/词尾   `# grep "\bhell" 1.txt    or   # grep "hell\b" 1.txt`
   - 整个单词    `# grep "\bhell\b" 1.txt`
3. 分组  `# grep "\(test\)\{3\}" 1.txt` 
4. 逻辑或  `# grep "root\|admin" /etc/passwd` 等价于 `# grep -E "root|admin" /etc/passwd`

### 2.7  ss

1. 查看链接服务器最多的IP地址:

   `ss -nt |grep ESTAB |tr -s ' ' :|cut -d: -f6 |sort |uniq -c |sort -nr |head -n 3`

<<<<<<< HEAD

### 2.8 ps

1. 查看僵尸进程 ps -A -ostat,ppid,pid,cmd | grep -e '^[zZ]'
=======
### 2.8  vim

1. 精确匹配单词	 /\\<hello\\>
2. 忽略大小写消息 :set ic(ignorecase 的缩写)   或者 \c搜索的内容
3. 粘贴格式错乱：set paste

### 2.9 ps

1. 查看进程包含多少线程  cat /proc/pid/status or ps -T pid

### 2.10 top

1. 查看某进程下各个线程占用的资源    top -H -p pid

## 3 IO重定向

### 3.1 多行重定向

使用"<<终止词"命令从键盘把多行重定向给STDIN，直到终止词位置之前所有的文本都发送给STDIN，有时称为"就地文本(here document)"

```shell
# cat << EOF
> 1
> 2
> 3
> 4
> EOF
```

### 3.2 管道

STDERR 通过管道转发，使用 "2>&1 |"  或者 "|&" 实现

```shell
# ls aaa 2>&1 |grep aaa
# ls aaa |& grep aaa
```





## 4 DNS

- @：也就是ZONE_NAME，NS(Name Server): ZONE_NAME --> FQDN
- MX(Mail eXchanger): ZONE_NAME --> FQDN
- A（address）：  FQDN-->IPv4
- AAAA：FQDN-->IPv6
- PTR(pointer)：IP-->FQDN
- CNAME(Canonical NAME): FQDN-->FQDN

## 5 自签名ssl证书

```shell
#创建证书存放目录
$ mkdir /etc/httpd/conf/certs;cd /etc/httpd/certs
#自签CA证书
$ openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 3650 -out ca.crt
#自制key和csr文件
$ openssl req -newkey rsa:4096 -nodes -sha256 -keyout www.httpsproxy.net.key -out www.httpsproxy.net.csr
#签发证书
$ openssl x509 -req -days 3650 -in www.httpsproxy.net.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out www.httpsproxy.net.crt
#验证证书内容
$ openssl x509 -in www.httpsproxy.net.crt -noout -text
```

# 部署服务

## 1 apache反向代理

1. 官网下载源码包:http://archive.apache.org/dist/httpd/
2. 编译

```bash
$ ./configure --prefix=/apps/httpd-2.4.29 \
--enable-proxy --enable-proxy-http --enable-proxy-ftp --enable-proxy-fcgi --enable-proxy-fdpass --enable-proxy-scgi --enable-proxy-connect --enable-proxy-ajp --enable-proxy-balancer --enable-proxy-express \
--enable-lbmethod-byrequests --enable-lbmethod-bytraffic --enable-lbmethod-bybusyness --enable-lbmethod-heartbeat \
--enable-proxy-hcheck \
--enable-lbmethod-heartbeat --enable-heartmonitor --enable-ssl --enable-ssl-staticlib-deps
```

3. 开启的模块

```shell
LoadModule authn_file_module modules/mod_authn_file.so
LoadModule authn_core_module modules/mod_authn_core.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule authz_groupfile_module modules/mod_authz_groupfile.so
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule access_compat_module modules/mod_access_compat.so
LoadModule auth_basic_module modules/mod_auth_basic.so
LoadModule watchdog_module modules/mod_watchdog.so
LoadModule filter_module modules/mod_filter.so
LoadModule mime_module modules/mod_mime.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule env_module modules/mod_env.so
LoadModule headers_module modules/mod_headers.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule version_module modules/mod_version.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_connect_module modules/mod_proxy_connect.so
LoadModule proxy_ftp_module modules/mod_proxy_ftp.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
LoadModule proxy_scgi_module modules/mod_proxy_scgi.so
LoadModule proxy_uwsgi_module modules/mod_proxy_uwsgi.so
LoadModule proxy_fdpass_module modules/mod_proxy_fdpass.so
LoadModule proxy_wstunnel_module modules/mod_proxy_wstunnel.so
LoadModule proxy_ajp_module modules/mod_proxy_ajp.so
LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
LoadModule proxy_express_module modules/mod_proxy_express.so
LoadModule proxy_hcheck_module modules/mod_proxy_hcheck.so
LoadModule session_module modules/mod_session.so
LoadModule session_cookie_module modules/mod_session_cookie.so
LoadModule session_dbd_module modules/mod_session_dbd.so
LoadModule slotmem_shm_module modules/mod_slotmem_shm.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule lbmethod_byrequests_module modules/mod_lbmethod_byrequests.so
LoadModule lbmethod_bytraffic_module modules/mod_lbmethod_bytraffic.so
LoadModule lbmethod_bybusyness_module modules/mod_lbmethod_bybusyness.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule heartmonitor_module modules/mod_heartmonitor.so
LoadModule status_module modules/mod_status.so
LoadModule autoindex_module modules/mod_autoindex.so
LoadModule dir_module modules/mod_dir.so
LoadModule alias_module modules/mod_alias.so
```

4. 修改配置文件

```shell
# httpd.conf 在最后增加
Include conf.d/*.conf
# 配置https反向代理
# cat conf.d/httpd-vhosts.conf 
Listen 443
<VirtualHost 10.80.0.14:443>

ServerName rtdm-sas.cn.prod
ServerAlias rtdm-sas.cn.prod
ErrorLog "|/usr/sbin/rotatelogs -l -f -c logs/rtdm-sascn.prod_ssl_error.log-%Y%m%d 86400"
LogFormat "%{Host}i [remote: %h (%a)] [user: %u (%{login}C)] [%{%d/%b/%Y:%T}t.%{msec_frac}t %{%z}t] \"%r\" %>s [dur: %D us (%T s)] [SID=%{JSESSIONID}C] [conn: %P, %X] \"%!200,302,304,401{Content-Type}o\" \"%{U
ser-agent}i\" \"CALLID=%{CALLID}i\" \"SOAPAction=%{SOAPAction}i\" \"%!200,302,304{X-Requested-With}o\""TransferLog "|/usr/sbin/rotatelogs -l -f -c logs/rtdm-sascn.prod_ssl_access.log-%Y%m%d 86400"

<IfModule mod_ssl.c>
SSLEngine on
SSLCertificateFile conf/certs/rtdm-sas.cn.prod.crt
SSLCertificateKeyFile conf/certs/rtdm-sas.cn.prod.key
#SSLCertificateChainFile conf/certs/www.httpsproxy.net.crt
</IfModule>
<IfModule mod_cache.c>
CacheDisable /
</IfModule>
<Proxy balancer://rtdmcluster/>
BalancerMember http://47.95.234.142:5000 disablereuse=on 
#hcmethod=TCP hcinterval=5 hcpasses=2 hcfails=3
BalancerMember http://10.80.0.11:80 disablereuse=on timeout=2s connectiontimeout=1 
# hcmethod=TCP hcinterval=5 hcpasses=2 hcfails=3
</Proxy>
ProxyPass / balancer://rtdmcluster/
ProxyPassReverse / balancer://rtdmcluster/

</VirtualHost>
```

## 2 升级openssl

```shell
$ yum -y install perl perl-devel gcc gcc-c++
$ cd /usr/local/src
$ wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_1c.tar.gz
$ tar xzvf ./OpenSSL_1_1_1c.tar.gz
$ cd openssl-OpenSSL_1_1_1c/
$ ./config
$ make
$ make install
$ mv /usr/bin/openssl /usr/bin/oldopenssl
$ ln -s /usr/local/bin/openssl /usr/bin/openssl
$ ln -s /usr/local/lib64/libssl.so.1.1 /usr/lib64/
$ ln -s /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/
$ openssl version
```

## 3 部署NFS

### 3.1 服务端部署NFS

1. 安装NFS

   ```shell
   $ yum  install  -y nfs-utils
   ```

2. 配置NFS共享目录

   ```shell
   $ vim /etc/exports
   /opt/sas_share 10.67.194.10(rw,sync,no_root_squash,no_subtree_check)
   /opt/sas_share 10.67.194.11(rw,sync,no_root_squash,no_subtree_check)
   /opt/sas_share 10.67.194.12(rw,sync,no_root_squash,no_subtree_check)
   ```

3. 启动NFS服务

   ```shell
   # 设置开机自启动
   systemctl  enable  rpcbind.service
   systemctl  enable  nfs-server.service
   ## 启动NFS
   systemctl start rpcbind.service
   systemctl start nfs-server.service
   ```

4. 验证NFS服务器启动成功

   ```shell
   $ rpcinfo -p
   ```

5. 查看可共享的目录

   ```shell
   $ exportfs -v
   /opt/sas_share    	10.67.194.10(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
   $ exportfs -rv
   exporting 10.67.194.10:/opt/sas_share
   ```

### 3.2 客户端挂载NFS目录

1. 检查服务端的共享目录

   ```shell
   $ showmount -e nfs服务器的IP
   ```

2. 挂载NFS

   ```shell
   $ mount  -t nfs4 nfs服务器IP:/opt/sas_share     /opt/sas_share
   ```

3. 开机挂载

   ```shell
   $ vi  /etc/fstab
   # 加上
   nfs服务器IP:/opt/sas_share    /opt/sas_share   nfs4 ro,hard,intr,proto=tcp,port=2049,noauto 0 0
   ```

   







