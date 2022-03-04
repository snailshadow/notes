mautic安装

### 1. mysql5.7安装

1. 创建安装目录，并将mysql5.7版本上传到这个目录

```bash
# mkdir /apps
# mkdir /data/mysql -p
```

2. 执行mysql安装脚本

```bash
# sh install_mysql.sh
#!/bin/bash
. /etc/init.d/functions 
SRC_DIR=`pwd`
MYSQL='mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz'
COLOR="echo -e \\033[01;31m"
END='\033[0m'
MYSQL_ROOT_PASSWORD=123456
DATADIR=/data/mysql

if [ ! -d $DATADIR ];then
    mkdir -p $DATADIR
fi

check (){
cd  $SRC_DIR
if [ !  -e $MYSQL ];then
        $COLOR"缺少${MYSQL}文件"$END
        $COLOR"请将相关软件放在${SRC_DIR}目录下"$END
        exit
elif [ -e /usr/local/mysql ];then
        action "数据库已存在，安装失败" false
        exit
else
    return
fi
} 

install_mysql(){
    $COLOR"开始安装MySQL数据库..."$END
     yum  -y -q install libaio numactl-libs   libaio &> /dev/null
    cd $SRC_DIR
    tar xf $MYSQL -C /usr/local/
    MYSQL_DIR=`echo $MYSQL| sed -nr 's/^(.*[0-9]).*/\1/p'`
    ln -s  /usr/local/$MYSQL_DIR /usr/local/mysql
    chown -R  root.root /usr/local/mysql/
    id mysql &> /dev/null || { useradd -s /sbin/nologin -r  mysql ; action "创建mysql用户"; }

    echo 'PATH=/usr/local/mysql/bin/:$PATH' > /etc/profile.d/mysql.sh
    .  /etc/profile.d/mysql.sh
    cat > /etc/my.cnf <<-EOF
[mysqld]
server-id=1
log-bin
datadir=/data/mysql
socket=/data/mysql/mysql.sock                                                                                                   
log-error=/data/mysql/mysql.log
pid-file=/data/mysql/mysql.pid
[client]
socket=/data/mysql/mysql.sock
EOF
    mysqld --initialize --user=mysql --datadir=/data/mysql 
    cp /usr/local/mysql/support-files/mysql.server  /etc/init.d/mysqld
    chkconfig --add mysqld
    chkconfig mysqld on
    service mysqld start
    [ $? -ne 0 ] && { $COLOR"数据库启动失败，退出!"$END;exit; }
    MYSQL_OLDPASSWORD=`awk '/A temporary password/{print $NF}' /data/mysql/mysql.log`
    mysqladmin  -uroot -p$MYSQL_OLDPASSWORD password $MYSQL_ROOT_PASSWORD &>/dev/null
    action "数据库安装完成" 
}

check

install_mysql
```

3. 验证mysql是否安装成功

```bash
[root@vms9 apps]# mysql -uroot -p123456
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.7.21-log MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]>
```

### 2. httpd2.4安装

1. 配置yum源

```bash
# wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
# wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
```

2. 安装依赖

```bash
# yum install gcc pcre-devel openssl-devel expat-devel autoconf bison-devel bison flex -y
```

3. 编译安装httpd

```bash
#编译安装httpd
tar xvf apr-1.7.0.tar.bz2
tar xvf apr-util-1.6.1.tar.bz2 
tar xf httpd-2.4.43.tar.gz
mv apr-1.7.0 httpd-2.4.43/srclib/apr
mv apr-util-1.6.1 httpd-2.4.43/srclib/apr-util
./configure \
--prefix=/apps/httpd24 \
--enable-so \
--enable-ssl \
--enable-cgi \
--enable-rewrite \
--with-zlib \
--with-pcre \
--with-included-apr \
--enable-modules=most \
--enable-mpms-shared=all \
--with-mpm=event

make && make install
```

4. 配置环境变量

```bash
#准备PATH变量
vim /etc/profile.d/lamp.sh 
PATH=/apps/httpd24/bin:$PATH
. /etc/profile.d/lamp.sh
```

5. 修改配置文件

```bash
#创建和配置用户和组
useradd -s /sbin/nologin -r -u 88 apache 
vim /apps/httpd24/conf/httpd.conf
User apache 
Group apache
#修改为event模式,编译时已指定，此项不再需修改，可选项
vim /apps/httpd24/conf/httpd.conf
LoadModule mpm_event_module modules/mod_mpm_event.so
#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so 
#LoadModule mpm_worker_module modules/mod_mpm_worker.so

httpd -M |grep mpm 
mpm_event_module (shared)

# 启动httpd
apachectl start
```

6. 启动httpd

```bash
# vim /usr/lib/systemd/system/httpd.service
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)
[Service]
Type=forking
#EnvironmentFile=/etc/sysconfig/httpd
ExecStart=/apps/httpd24/bin/apachectl start
#ExecStart=/apps/httpd24/bin/httpd $OPTIONS -k start
ExecReload=/apps/httpd24/bin/apachectl graceful
#ExecReload=/apps/httpd24/bin/httpd $OPTIONS -k graceful
ExecStop=/apps/httpd24/bin/apachectl stop
KillSignal=SIGCONT
PrivateTmp=true
[Install]
WantedBy=multi-user.target

# systemctl start httpd;systemctl status httpd
# systemctl enable httpd
```

### 3. php74安装

1. 安装系统依赖

```bash
# yum -y install gcc gcc-c++ libxml2-devel bzip2-devel libmcrypt-devel sqlite-devel oniguruma-devel libc-client-devel libcurl libcurl-devel libpng-devel libjpeg-devel freetype-devel libicu-devel libargon2-devel libxslt-devel libzip-devel git bzip2-devel

# 安装icu4
wget https://github.com/unicode-org/icu/releases/download/release-59-2/icu4c-59_2-src.tgz
tar -xvf icu4c-59_2-src.tgz
cd icu
./configure --prefix=/usr/local/icu
make && make install

```

2. 编译安装php7.4

```bash
# cd php-7.4.27
./configure \
--prefix=/apps/php74 \
--enable-mysqlnd \
--enable-mbstring \
--enable-xml \
--enable-sockets \
--enable-opcache \
--disable-rpath \
--enable-fpm \
--enable-bcmath \
--enable-shmop \
--enable-maintainer-zts \
--enable-fileinfo \
--enable-exif \
--enable-sysvsem \
--enable-inline-optimization \
--enable-mbregex \
--enable-mbstring \
--enable-gd \
--enable-ftp \
--enable-intl \
--with-icu-dir=/usr/local/icu/ \
--with-zlib \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-openssl \
--with-zlib \
--with-config-file-path=/etc \
--with-config-file-scan-dir=/etc/php.d \
--with-kerberos --with-imap --with-imap-ssl --with-libdir=lib64 \
--with-xsl \
--with-xmlrpc \
--with-gettext \
--with-curl \
--with-freetype

make -j 2 && make install
```

3. 配置环境变量

```bash
#准备PATH变量
#php7.4
vim /etc/profile.d/lamp.sh 
PATH=/apps/php74/bin:$PATH
. /etc/profile.d/lamp.sh
```

4. 修改php配置文件

```bash
# cd /usr/local/src/php-7.4.27

#准备php配置文件和启动文件
cp php.ini-production /etc/php.ini
cp sapi/fpm/php-fpm.service /usr/lib/systemd/system/ 
cd /apps/php74/etc
cp php-fpm.conf.default php-fpm.conf 
cd php-fpm.d/
cp www.conf.default www.conf

vim /etc/php.ini
memory_limit = 512M
date.timezone = Asia/Shanghai

#修改进程所有者
vim /apps/php74/etc/php-fpm.d/www.conf 
listen = /dev/shm/php-cgi.sock
listen.owner = apache
listen.group = apache
listen.mode = 0660
listen.allowed_clients = 127.0.0.1
```

5. 启动php-fpm服务

```
systemctl daemon-reload 
systemctl status php-fpm.service
systemctl enable --now php-fpm.service
```

### 4. httpd支持php-fpm

```bash
vim /apps/httpd24/conf/httpd.conf 
#取消下面3行的注释
LoadModule proxy_module modules/mod_proxy.so 
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
LoadModule rewrite_module modules/mod_rewrite.s
#修改下面行
<IfModule dir_module> 
DirectoryIndex index.php index.html
</IfModule> 

<IfModule mime_module>
    TypesConfig conf/mime.types
    AddType application/x-compress .Z   # 增加
    AddType application/x-gzip .gz .tgz # 增加
</IfModule> 

# 文件结尾增加
ProxyRequests Off
IncludeOptional conf/conf.d/*.conf
```

### 5 httpd 配置虚拟主机

```bash
# mkdir /apps/httpd24/conf/conf.d
# vim /apps/httpd24/conf/conf.d/vhost1.conf 
listen 8080

<VirtualHost *:8080>
  #ServerAdmin admin@example.com
  DocumentRoot "/data/mautic/mautic"
  #ServerName www.mautic.com

  ErrorLog "/apps/httpd24/logs/www.mautic.com_error_apache.log"
  CustomLog "/apps/httpd24/logs/www.mautic.com_apache.log" common
  <Files ~ (\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)$>
    Order allow,deny
    Deny from all
  </Files>
  <FilesMatch \.php$>
    SetHandler "proxy:unix:/dev/shm/php-cgi.sock|fcgi://localhost"
  </FilesMatch>
<Directory "/data/mautic/mautic">
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  Require all granted
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
</VirtualHost>

[root@vms19 conf.d]# cat vhost3.conf 
listen 8082

<VirtualHost *:8082>
  #ServerAdmin admin@example.com
  DocumentRoot "/data/mautic/mauticcn"
  #ServerName www.mautic.com

  ErrorLog "/apps/httpd24/logs/www.mauticcn.com_error_apache.log"
  CustomLog "/apps/httpd24/logs/www.mauticcn.com_apache.log" common
  <Files ~ (\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)$>
    Order allow,deny
    Deny from all
  </Files>
  <FilesMatch \.php$>
    SetHandler "proxy:unix:/dev/shm/php-cgi.sock|fcgi://localhost"
  </FilesMatch>
<Directory "/data/mautic/mauticcn">
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  Require all granted
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
```

### 6 部署mautic

1. 从git下载mautic最新版本，并上传到/data/mautic目录 下载地址：https://github.com/mautic/mautic.git

```bash
# mkdir /data/mautic;cd /data/mautic
# unzip mautic-4.x.zip ;rm -rf mautic-4.x.zip 
# mv mautic-4.x/ mautic
```

2. 安装composer和pear

```bash
# 安装composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# 安装php扩展管理工具pear/pecl
wget http://pear.php.net/go-pear.phar -O go-pear.php
php go-pear.php  #回车继续
```

3. 检查php扩展

```
composer check
```

![image-20220214131558148](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20220214131558148.png) 

4. 安装php扩展

```bash
#卸载系统自带的libzip
yum  -y remove libzip-devel

#从官网下载并安装libzip
wget https://libzip.org/download/libzip-1.3.2.tar.gz
tar xvf libzip-1.3.2.tar.gz
cd libzip-1.3.2
./configure
make && make install

# 安装php扩展zip  下载地址https://pecl.php.net
mkdir /etc/php.d
wget https://pecl.php.net/get/zip-1.20.0.tgz
pecl install zip-1.20.0.tgz
echo "extension=zip.so" >> /etc/php.d/extension.ini
systemctl restart php-fpm
```

5. 创建mautic数据库

```bash
[root@vms19 mautic]# mysql -uroot -p123456
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.7.21-log MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]> create database mautic;
Query OK, 1 row affected (0.00 sec)
```

7. 使用composer安装php项目依赖

```bash
# cd /data/mautic/mautic
# composer install
```

8. 图形化安装mautic

   http://10.80.0.19/

![image-20220214183607989](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20220214183607989.png)  

登录成功后：

![image-20220215105430523](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20220215105430523.png)

