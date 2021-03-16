# ELK

## 1 ElasticSearch

### 1.1 安装

​	ElaticSearch 下载地址：https://www.elastic.co/cn/downloads/elasticsearch，自7.X版本后，分为自带jdk 和 no jdk的版本。

1. 下载rpm/deb，上传到服务器，安装（rpm -ivh） --略

   注意：使用二进制包安装时，es不允许使用root用户运行，需要新建一个普通用户，并将安装程序目录和data+log目录的属主改为普通用户，并用普通用户才可以启动。

2. 创建es的日志和数据目录 

   `mkdir -pv /data/{es-data,es-logs}`

3. 修改配置文件

   `vim /etc/elaticsearch/elasticsearch.yml`

```yaml
# ---------------------------------- Cluster -----------------------------------
# 集群名称，集群内所有node配置一样
cluster.name: my-es-cluster
# ------------------------------------ Node ------------------------------------
# 节点名称，集群内必须唯一
node.name: node-1
# ----------------------------------- Paths ------------------------------------ 
# data和log目录(会自动创建)
path.data: /data/es-data
path.logs: /data/es-logs

# ---------------------------------- Network -----------------------------------
# Set the bind address to a specific IP (IPv4 or IPv6):
network.host: 0.0.0.0
# Set a custom port for HTTP:
http.port: 9200

# --------------------------------- Discovery ----------------------------------
# 节点列表
discovery.seed_hosts: ["10.80.0.41","10.80.0.42","10.80.0.43"]
# 能作为master的节点
cluster.initial_master_nodes: ["10.80.0.41","10.80.0.42","10.80.0.43"]

# ---------------------------------- Gateway -----------------------------------
# 半数以上 5-->3 3-->2
gateway.recover_after_nodes: 2

# ---------------------------------- Various ----------------------------------- 
# 建议设置为true 即：删除时需要指定索引，不能使用_all删除所有
action.destructive_requires_name: true

# 开启 支持跨域访问,head插件才可以使用
http.cors.enabled: true 
http.cors.allow-origin: "*"  # 外网所有地址都可以访问
```

默认通过systemctl start elaticsearch启动会报错，因为程序启动是通过elaticsearch用户来启动的，但是log和data目录对elaticsearch用户没有权限，解决方法：

- 修改data和log目录的属主

  `# chown -R elasticsearch.elasticsearch /data/`

- 修改启动文件的user和group

  ```shell
  vim elasticsearch.service
  User=elasticsearch
  Group=elasticsearch
  ```

### 1.2  启动

3. 启动elasticsearch

   `systemctl start elaticsearch`

4. 验证启动

   http://10.80.0.43:9200/

### 1.3 参数优化

通过二进制包安装启动时，操作系统有些参数需要调整

`vim /etc/security/limits.conf`

```
* hard nofile 1000000
* soft nofile 1000000
* hard nproc 65536
* soft nproc 65536
```

`vim /etc/sysctl.conf`

```
vm.max_map_count=655360
fs.file-max=655360
```

`vim /usr/lib/systemd/system/elasticsearch.service`

```
LimitNOFILE=1000000
LimitNPROC=65536
```

### 1.4 插件

#### 1.4.1 head 插件

1. github地址：https://github.com/mobz/elasticsearch-head

2. 安装docker：

`sh docker-install-centos.sh`

3. 安装head 插件：

`docker run -p 9100:9100 mobz/elasticsearch-head:5`

4. 修改容器为开启启动

`docker container update --restart=always mobz/elasticsearch-head:5

5. 访问head插件

http://10.80.0.41:9100/

![image-20210307144849615](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210307144849615.png)

#### 1.4.2 cerebo插件

github地址：https://github.com/lmenezes/cerebro

1. 下载最新版本上传到服务器  --略

2. 修改配置文件

   `vim conf/application.conf `

```
{
    host = "http://10.80.0.41:9200"
    name = "my-es-cluster"
}
```

3. 启动插件

   `nohup ./bin/cerobro & `

## 2 Logstash

### 2.1 安装

1. 下载地址：https://www.elastic.co/cn/downloads/past-releases#logstash   下载rpm包 

2.  使用rpm -ivh安装

3. 新建data和log目录

   `mkdir -pv /data/{logstash-data,logstash-logs}`

   `chown logstash.root -R /data`

4. 修改logstash配置文件

   - 修改data和log目录

   ```shell
   vim /etc/logstash/logstash.yml
   path.data: /data/logstash-data
   path.logs: /data/logstash-logs
   ```

   - 修改JAVA_HOME

   ```shell
   vim /usr/share/logstash/bin/logstash.lib.sh
   export JAVA_HOME=/usr/local/java/jdk1.8.0_171
   export PATH=$PATH:$JAVA_HOME/bin
   ```

### 2.2 启动

1. 默认用logstash用户启动    /etc/systemd/system/logstash.service

2. 启动logstash

   `systemctl start logstash;systemctl enable logstash`

   注意：启动前 需要至少有1个配置文件在/etc/logstash/conf.d/目录下。

### 2.3 收集日志示例

1. 标准输入和输出测试

   `/usr/share/logstash/bin/logstash -e 'input { stdin {} } output { stdout { codec => "rubydebug" } }'`

2. 通过标准输入收集数据，然后输出到某个文件

   `/usr/share/logstash/bin/logstash -e 'input { stdin {} } output { file { path => "/tmp/logstash-linux39.txt" } }'`

3. 将输出改成elasticsearch

   `/usr/share/logstash/bin/logstash -e 'input { stdin {} } output { elasticsearch { hosts => ["10.80.0.31:9200"]  index => "linux39-%{+YYYY.MM.dd}" } }'`

4. 将输入改成日志文件

   `/usr/share/logstash/bin/logstash -e 'input { file { path => "/var/log/messages" start_position => "beginning" stat_interval => "3"} } output { elasticsearch { hosts => ["10.80.0.41:9200"]  index => "messages-log-%{+YYYY.MM.dd}" } }'`

   start_position  string, one of ["beginning", "end"] 默认时end
   stat_interval number or string_duration  默认1s

   *tips: file的position信息保存在/usr/share/logstash/data/plugins/inputs/file/.sincedb_xxxx中，如果要想重新收集，需要先删除此文件*

5. 检查配置文件格式

   ``/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/filename -t`

6. 日志收集分类

   type => "tomcat-access-log"

## 3 kibana

### 3.1 安装

1. 下载地址：https://www.elastic.co/cn/downloads/past-releases#kibana  下载rpm包 

2.  使用rpm -ivh安装 

3. 修改配置文件

   ```shell
   vim /etc/kibana/kibana.yml
   server.port: 5601
   server.host: "0.0.0.0"
   elasticsearch.hosts: ["http://10.80.0.41:9200"]
   i18n.locale: "zh-CN" # 默认是英文界面，建议使用英文界面
   ```

### 3.2 启动

1. 启动logstash

   `systemctl start kibana;systemctl enable kibana`

2. 验证

   http://10.80.0.41:5601/

### 3.3 基本使用

1. 创建索引 Management--> 索引模式--> 输入匹配规则--->选择时间字段

![image-20210307203917812](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210307203917812.png)

![image-20210307204030478](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210307204030478.png)

![image-20210307204111838](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210307204111838.png)

## filebeat

