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
2. 忽略大消息 :set ic(ignorecase 的缩写)   或者 \c搜索的内容

### 2.9 ps

1. 查看进程包含多少线程  cat /proc/pid/status or ps -T pid

### 2.10 top

1. 查看某进程下各个线程占用的资源    top -H -p pid
2. 
>>>>>>> b2779f1a52b5538cfa1f11c99ab3c1e2365a8fd6

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













