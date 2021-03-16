# Prometheus

## Prometheus-server

### Systemctl启动

```shell
cat /usr/lib/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/prometheus/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus/prometheus.yml
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
TimeoutStopSec=20s

[Install]
WantedBy=multi-user.target
```

- 启动prometheus ：systemctl enable prometheus;systemctl start prometheus
- 重新加载配置： systemctl reload prometheus

- 



## Grafana

### 安装

````shell
$ wget https://s3-us-westwest-2.amazonaws.com/grafana-releases/release/grafana-5.3.25.3.2-1.x86_64.rpm
$ yum -y localinstall grafanagrafana-5.3.25.3.2-1.x86_64.rpm
$ systemctl start grafana-server && systemctl enable grafana-server
````

### 访问grafana

http://192.168.20.174:3000

### SMTP 邮件告警

1. 修改grafana配置文件

```shell
$ vim /etc/grafana/grafana.ini
#################################### SMTP / Emailing ##########################
[smtp]
enabled = true
host = smtp.163.com:465
user = tianyu29792569@163.com
# If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
password = 1qaz2wsx3edc
;cert_file =
;key_file =
;skip_verify = false
from_address = tianyu29792569@163.com
from_name = Grafana
# EHLO identity in SMTP dialog (defaults to instance_name)
ehlo_identity = dashboard.example.com

```

2. grafana 界面增加channel
3. dashboard alert页面选择这个channel

## Alertmanager

### 启动

```shell
# cat alertmanager.service 
[Unit]
Description=AlertManager
Documentation=https://alertmanager.io/
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/prometheus/alertmanager/alertmanager --config.file /usr/local/prometheus/alertmanager/alertmanager.yml
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
TimeoutStopSec=20s

[Install]
WantedBy=multi-user.target

$ systemctl start alertmanager && systemctl enable alertmanager
```



### 配置文件

```yaml
# cat alertmanager.yml 
global:
  smtp_smarthost: 'smtp.163.com:465'
  smtp_from: 'git201901xdx@163.com'
  smtp_auth_username: 'git201901xdx@163.com'
  smtp_auth_password: 'Ab123456'
  smtp_require_tls: false

route:
  receiver: mail

receivers:
- name: 'mail'
  email_configs:
  - to: 'tianyu29792569@163.com'
```

## Pushgateway

### 启动

```shell
$ cat pushgateway.service 
[Unit]
Description=pushgateway
Documentation=https://prometheus.io/
After=network.target

[Service]
#Type设置为notify时，服务会不断重启
Type=simple
ExecStart=/usr/local/prometheus/pushgateway/pushgateway
Restart=on-failure
TimeoutStopSec=20s

[Install]
WantedBy=multi-user.target

$ systemctl enable pushgateway;systemctl start pushgateway
```





## 监控

### 监控docker

1. 安装docker

centos7内核版本低，linux与docker版本的兼容性问题。会报错误“oci runtime error: container_linux.go:247: starting container process”

```shell
$ yum update 
$ yum remove docker  docker-common docker-selinux dockesr-engine
$ yum install -y yum-utils device-mapper-persistent-data lvm2
$ yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ yum list docker-ce --showduplicates | sort -r
$ yum install docker-ce
$ systemctl start docker;systemctl enable docker
```

2. 安装cAdvisor

```shell
$ docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  google/cadvisor:latest
  
  $ docker update --restart=always cadvisor
```

3. prometheus.yaml 配置

```yaml
  - job_name: 'docker'
    file_sd_configs:
      - files:
        - targets/dockers/*.json
        refresh_interval: 1m
```

4. targets 配置

```json
[{
	"targets":[
	"10.80.0.31:8080",
	"10.80.0.32:8080",
	"10.80.0.33:8080",
	"10.80.0.34:8080"
	],
	"labels":{
	"application": "docker"
	}
}]
```

### 监控node

启动node-exporter

```shell
# cat node_exporter.service 
[Unit]
Description=Node-Exporter
Documentation=https://prometheus.io/
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/prometheus/node-exporter/node_exporter \
        --collector.textfile.directory /usr/local/prometheus/node-exporter/monitor_file \
        --collector.mountstats \
        --collector.systemd \
        --collector.tcpstat --web.listen-address=:9600
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
TimeoutStopSec=20s

[Install]
WantedBy=multi-user.target
```

- 启动node-exporter：systemctl enable node_exporter;systemctl start node_exporter
- 重新加载配置： systemctl reload node_exporter

### 监控文件信息

echo 'metadata{role="Prometheus",label ="collect file information"} 1' | tee /usr/local/prometheus/node-exporter/monitor_file/metadata.prom

### 监控oracle

1. 下载oracle_exporter   [https://github.com/iamseth/oracledb_exporter/releases](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fiamseth%2Foracledb_exporter%2Freleases)
2. export DATA_SOURCE_NAME=用户名/密码@ 数据库服务名

```shell
$ export DATA_SOURCE_NAME=system/oracle@10.80.0.10:1521/orcl
```

3. 编辑/etc/ld.so.conf ，在文件结尾插入下面内容

```shell
$ vim /etc/ld.so.conf 
/u01/oracle/product/11.2.0/db_1/lib/libclntsh.so.18.1
```

4. 启动oracle_exporter

```shell
$ nohup oracledb_exporter --log.level="error" --web.listen-address="0.0.0.0:9161" &
```

5. 验证 http://10.80.0.10:9161/metrics
6. Prometheus配置

```json
- job_name: 'oracle'
    static_configs:
    - targets: ['10.80.0.10:9161']
```



*Tips:ImportError: libclntsh.so.18.1: cannot open shared object file: No such file or directory 解决方法*

1. 设置环境变量

```shell
$ vim /etc/profile  #增加如下内容
export ORACLE_BASE=/u01/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
LD_LIBRARY_PATH=$ORACLE_HOME/lib
export LD_LIBRARY_PATH
$ source /etc/profile
```

2. 创建软连接

```shell
$ cd /u01/oracle/product/11.2.0/db_1/lib
$ ln -s libclntsh.so.11.1 libclntsh.so.18.1
$ chown -h oracle:oinstall libclntsh.so.18.1
```

3. 执行

````shell
$ ldconfig
````





