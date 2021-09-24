# 部署ceph集群

## 1. 部署工具

1. ceph-deploy（**原生工具**）

   - ceph-deploy is a way to deploy Ceph relying on just SSH access to the servers, sudo,and some Python.
   - It runs fully on the workstation (Admin Host), requiring no servers, databases, oranything like that.
   - It is not a generic deployment system, it is only for Ceph, and is designed for users who，want to quickly get Ceph running with sensible initial settings without the overhead ofinstalling Chef, Puppet or Juju.
   - It does not handle client configuration beyond pushing the Ceph config file and users who want fine-control over security settings, partitions or directory locations should use a tool such as Chef or Puppet.

2. ceph-ansible(**建议**)

   • ceph-ansible: ansible playbooks for Ceph, https://github.com/ceph/ceph-ansible

3. ceph-chef

   • https://github.com/ceph/ceph-chef

4. puppet-ceph,....

## 2. 环境规划

| role                | ipaddr（public net + cluster） | hostname            | OS        | comment |
| ------------------- | :----------------------------- | ------------------- | --------- | ------- |
| ceph-admin          | 10.80.0.81                     | admin.ilinux.io     | centos7.9 | 2 OSD   |
| storage,mon,mgr,mds | 10.80.0.82                     | storage01.ilinux.io | centos7.9 | 2 OSD   |
| storage,mon,mgr     | 10.80.0.83                     | storage02.ilinux.io | centos7.9 | 2 OSD   |
| storage,mon,        | 10.80.0.84                     | storage03.ilinux.io | centos7.9 | 2 OSD   |

## 3. 环境准备

### 3.1 设置时钟同步

```shell
yum install chrony;systemctl start chrony.service;systemctl enable chrony.service
```

### 3.2 设置主机名解析

```shell
$ hostnamectl set-hostname ceph-admin.ilinux.io
$ cat /etc/hosts10.80.0.81  
10.80.0.81  ceph-admin.ilinux.io ceph-admin
10.80.0.82  stor01.ilinux.io stor01 mon01 mds01
10.80.0.83  stor02.ilinux.io stor02 mon02 mgr01
10.80.0.84  stor03.ilinux.io stor03 mon03 mgr02
```

### 3.3 关闭iptable或firewalld服务

```bash
$ systemctl stop firewalld.service
$ systemctl stop iptables.service
$ systemctl disable firewalld.service
$ systemctl disable iptables.service
```

### 3.4 关闭并禁用SELinux

```bash
$ setenforce 0
$ vim /etc/selinux/config 
SELINUX=disabled
```

## 4. 准备部署Ceph集群

### 4.1 准备yum仓库配置文件

Ceph官方仓库路径为 http://download.ceph.com，目前主流版本的程序包都在其中，包括kraken，luminous，mimic等等，生成yum仓库配置文件执行如下命令：

```bash
$ rpm -ivh http://download.ceph.com/rpm-mimic/el7/noarch/ceph-release-1-1.el7.noarch.rpm
```

### 4.2 创建部署Ceph的特定账号

部署工具ceph-deploy必须以普通用户登录到Ceph集群的各目标节点，且此用户需要拥有无密码使用sudo命令的权限，以便在安装软件及生成配置文件的过程中无需终端配置过程，`较新的版本也支持使用-username提供无密码使用sudo命令的用户名`

1. 在各Ceph各节点创建用户

   各个节点以root用户创建cephadmin账号，并设置密码为ilinux

   ```bash
   $ useradd cephadm
   $ echo 'ilinux' |passwd --stdin cephadm
   ```

   确保ceph-adm用户拥有可以在各个节点无密码运行sudo命令的权限

   ```bash
   $ echo "cephadm ALL =(root) NOPASSWD:ALL" |sudo tee /etc/sudoers.d/cephadm
   $ scp -rp /etc/sudoers.d/cephadm stor01:/etc/sudoers.d/
   $ scp -rp /etc/sudoers.d/cephadm stor02:/etc/sudoers.d/
   $ scp -rp /etc/sudoers.d/cephadm stor03:/etc/sudoers.d/
   ```

2. 配置SSH免密登录

   ```bash
   $ ssh-keygen -t rsa -P ''
   $ scp -rp .ssh/ cephadm@stor01:/home/cephadm
   $ scp -rp .ssh/ cephadm@stor02:/home/cephadm
   $ scp -rp .ssh/ cephadm@stor03:/home/cephadm
   ```

### 4.5 管理节点安装ceph-deploy

Ceph存储集群的部署过程可以通过ceph-deploy全程运行，首先在管理节点安装ceph-deploy及其依赖到的程序包

```bash
yum update
yum install -y ceph-deploy python-setuptools python2-subprocess32
```

## 5. 部署RADOS存储集群

### 5.1 初始化RADOS集群

1. 首先在管理节点以cephadm用户创建集群相关配置文件目录

```bash
$ mkdir ceph-cluster
$ cd ceph-cluster
```

2. 初始化MON节点，准备创建集群，本示例中stor01即为第一个MON节点名称，命令格式：

   usage: ceph-deploy new [-h] [--no-ssh-copykey] [--fsid FSID]
                          [--cluster-network CLUSTER_NETWORK]
                          [--public-network PUBLIC_NETWORK]
                          MON [MON ...]

   运行如下命令生成初始化配置：

```bash
$ ceph-deploy new --cluster-network=10.80.0.0/24 --public-network=10.80.0.0/24 stor01.ilinux.io
```

3. 编辑生成的ceph.conf配置文件，在[global]配置段中设置ceph集群面向客户通信时使用的IP地址，即公网网络地址

```
public network = 10.80.0.0/24
```

4. 安装集群

   ceph-deploy 命令能够以远程方式连入Ceph集群各节点完成程序包安装操作，命令格式如下：

   usage: ceph-deploy install [-h] [--stable [CODENAME] | --release [CODENAME] |
                              --testing | --dev [BRANCH_OR_TAG]]
                              [--dev-commit [COMMIT]] [--mon] [--mgr] [--mds]
                              [--rgw] [--osd] [--tests] [--cli] [--all]
                              [--adjust-repos | --no-adjust-repos | --repo]
                              [--local-mirror [LOCAL_MIRROR]]
                              [--repo-url [REPO_URL]] [--gpg-url [GPG_URL]]
                              [--nogpgcheck]
                              HOST [HOST ...]

   因此若要将stor01,stor02,stor03配置为集群节点，则执行如下命令即可：

```bash
$ ceph-deploy install --no-adjust-repos stor01 stor02 stor03
```

*提示：若要在各个节手动安装ceph程序包，其方法如下*

```bash
$ sudo yum -y install ceph ceph-radosgw
```

5. 配置初始MON节点，并收集所有密钥：

```bash
[cephadm@ceph-admin ceph-cluster]$ ceph-deploy mon create-initial
```

6. 部署客户端，并把配置文件和admin密钥拷贝Ceph集群各节点，以免得每次执行”ceph“命令行时不得不明确指定MON节点地址   和ceph.client.admin.keyring：

```bash
[cephadm@ceph-admin ceph-cluster]$ sudo yum install -y ceph-common
[cephadm@ceph-admin ceph-cluster]$ ceph-deploy admin stor01 stor02 stor03 ceph-admin
```

而后在Ceph集群中需要运行ceph命令的的节点上（或所有节点上）以root用户的身份设定用户cephadm能够读   取/etc/ceph/ceph.client.admin.keyring文件：

```bash
[cephadm@ceph-admin ceph-cluster]$ sudo setfacl -m u:cephadm:r /etc/ceph/ceph.client.admin.keyring
```

7. 配置Manager节点，启动ceph-mgr进程（仅Luminious+版本）：

```bash
[cephadm@ceph-admin ceph-cluster]$ ceph-deploy mgr create stor02
```

8. 在Ceph集群内的节点上以cephadm用户的身份运行如下命令，测试集群的健康状态：

```bash
[cephadm@ceph-admin ceph-cluster]$ ceph -s
  cluster:
    id:     c2350da1-35b5-449c-92c1-5777c58ba014  #集群ID ，自动生成也可以手动指定
    health: HEALTH_WARN
            OSD count 0 < osd_pool_default_size 3
 
  services:
    mon: 1 daemons, quorum stor01 # mon 有1个
    mgr: stor02(active) #mgr 在stor02
    osd: 0 osds: 0 up, 0 in # 0个osd，可用0个
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0  objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
```

### 5.2 向RADOS集群添加OSD

1. 列出并擦净磁盘

   “ceph-deploy disk”命令可以检查并列出OSD节点上所有可用的磁盘的相关信息：

   ```bash
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy disk list stor01 stor02 stor03
   ```

   而后，在管理节点上使用ceph-deploy命令擦除计划专用于OSD磁盘上的所有分区表和数据以便用于OSD，命令格式  为”ceph-deploy disk zap {osd-server-name} {disk-name}“，需要注意的是此步会清除目标设备上的所有数据。下面分别擦净stor01、stor02和stor03上用于OSD的一个磁盘设备sdb,sdc：

   ```bash
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy disk zap stor01 /dev/sdb
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy disk zap stor01 /dev/sdc
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy disk zap stor02 /dev/sdb
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy disk zap stor02 /dev/sdc
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy disk zap stor03 /dev/sdb
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy disk zap stor03 /dev/sdc
   ```

   *提示：若设备上此前有数据，则可能需要在相应节点上以*root*用户使用*“ceph-volume lvm zap --destroy {DEVICE}”*命令进行；*

2. 添加OSD

   早期版本的ceph-deploy命令支持在将添加OSD的过程分为两个步骤：准备OSD和激活OSD，但新版本中，此种操作 方式已经被废除，添加OSD的步骤只能由命令”ceph-deploy osd create {node} --data {data-disk}“一次完成，默认使用的存储引擎为bluestore。

   如下命令即可分别把stor01、stor02和stor03上的设备sdb添加为OSD：

   ```bash
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy osd create stor01 --data /dev/sdb
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy osd create stor02 --data /dev/sdb
   [cephadm@ceph-admin ceph-cluster]$ ceph-deploy osd create stor03 --data /dev/sdb
   ```

   而后可使用”ceph-deploy osd list”命令列出指定节点上的OSD：

   ```bash
   $ ceph-deploy osd list stor01 stor02 stor03
   ```

   事实上，管理员也可以使用ceph命令查看OSD的相关信息：

   ```bash
   $ ceph -s
   $ ceph osd stat
   $ ceph osd dump
   $ ceph osd ls
   ```

### 5.3 从RADOS集群移除OSD的方法

Ceph集群中的一个OSD通常对应于一个设备，且运行于专用的守护进程。在某OSD设备出现故障，或管理员出于管 理之需确实要移除特定的OSD设备时，需要先停止相关的守护进程，而后再进行移除操作。对于Luminous及其之后  的版本来说，停止和移除命令的格式分别如下所示：

1. 停用设备：ceph osd out {osd-num}    *示例 `[cephadm@ceph-admin ceph-cluster]$ ceph osd out 0`*

2. 停止进程：sudo systemctl stop ceph-osd@{osd-num} *示例`[cephadm@stor01 ~]$ sudo systemctl status ceph-osd@0`*

3. 移除设备：ceph osd purge {id} --yes-i-really-mean-it  *示例`[cephadm@ceph-admin ceph-cluster]$ ceph osd purge 0 --yes-i-really-mean-it`*

若类似如下的OSD的配置信息存在于ceph.conf配置文件中，管理员在删除OSD之后手动将其删除。

```bash
[osd.1] host = {hostname}
```

不过，对于Luminous之前的版本来说，管理员需要依次手动执行如下步骤删除OSD设备：

1. 于CRUSH运行图中移除设备：ceph osd crush remove {name}

2. 移除OSD的认证key：ceph auth del osd.{osd-num}

3. 最后移除OSD设备：ceph osd rm {osd-num}

### 5.4 测试上传/下载数据对象

存取数据时，客户端必须首先连接至RADOS集群上某存储池，而后根据对象名称由相关的CRUSH规则完成数据对象寻址。于是，为了测试集群的数据存取功能，这里首先创建一个用于测试的存储池mypool，并设定其PG数量为16   个。

```bash
[cephadm@ceph-admin ceph-cluster]$ ceph osd pool create mypool 16
```

而后即可将测试文件上传至存储池中，例如下面的“rados put”命令将/etc/issue文件上传至mypool存储池，对象名称依然保留为文件名issue，而“rados ls”命令则可以列出指定存储池中的数据对象。

```bash
[cephadm@ceph-admin ceph-cluster]$ rados put issue /etc/issue --pool=mypool
[cephadm@ceph-admin ceph-cluster]$ rados ls --pool=mypool
```

而“ceph osd map”命令可以获取到存储池中数据对象的具体位置信息：

```bash
[cephadm@ceph-admin ceph-cluster]$ ceph osd map mypool issue
osdmap e31 pool 'mypool' (1) object 'issue' -> pg 1.651f88da (1.a) -> up ([4,2,1], p4) acting ([4,2,1], p4)
```

删除数据对象，“rados  rm”命令是较为常用的一种方式：

```bash
[cephadm@ceph-admin ceph-cluster]$ rados rm issue --pool=mypool
```

删除存储池命令存在数据丢失的风险，Ceph于是默认禁止此类操作。管理员需要在ceph.conf配置文件中启用支持删  除存储池的操作后，方可使用类似如下命令删除存储池。

```bash
[cephadm@ceph-admin ceph-cluster]$ ceph osd pool rm mypool mypool --yes-i-really-really-mean-it
Error EPERM: pool deletion is disabled; you must first set the mon_allow_pool_delete config option to true before you can destroy a pool
```

## 6. 扩展Ceph集群

### 6.1 扩展监视器节点

Ceph存储集群需要至少运行一个Ceph  Monitor和一个Ceph  Manager，生产环境中，为了实现高可用性，Ceph存储集群通常运行多个监视器，以免单监视器整个存储集群崩溃。Ceph使用Paxos算法，该算法需要半数以上的监视器,（大于n/2，其中n为总监视器数量）才能形成法定人数。尽管此非必需，但奇数个监视器往往更好。“ceph-deploy mon add {ceph-nodes}”命令可以一次添加一个监视器节点到集群中。例如，下面的命令可以将集群中的stor02和stor03也运行为监视器节点：

```bash
$ ceph-deploy mon add stor02
$ ceph-deploy mon add stor03
```

设置完成后，可以在ceph客户端上查看监视器及法定人数的相关状态：

```bash
$ ceph quorum_status --format json-pretty
```

### 6.2 扩展manager节点

Ceph Manager守护进程以“Active/Standby”模式运行，部署其它ceph-mgr守护程序可确保在Active节点或其上的ceph-mgr守护进程故障时，其中的一个Standby实例可以在不中断服务的情况下接管其任务。“ceph-deploy mgr create {new-manager-nodes}”命令可以一次添加多个Manager节点。下面的命令可以将stor03节点作为备用的Manager运行

```bash
$ ceph-deploy mgr create stor03
```

添加完成后，“ceph -s”命令查看结果

```bash
$ ceph -s
  cluster:
    id:     c2350da1-35b5-449c-92c1-5777c58ba014
    health: HEALTH_WARN
            too few PGs per OSD (8 < min 30)
 
  services:
    mon: 3 daemons, quorum stor01,stor02,stor03
    mgr: stor02(active), standbys: stor03
    osd: 6 osds: 6 up, 6 in
 
  data:
    pools:   1 pools, 16 pgs
    objects: 0  objects, 0 B
    usage:   6.0 GiB used, 294 GiB / 300 GiB avail
    pgs:     16 active+clean
```

## 7. Ceph存储集群的访问接口

### 7.1 Ceph块设备接口（RBD）

Ceph块设备，也称为RADOS块设备（简称RBD），是一种基于RADOS存储系统支持超配（thin-provisioned）、可  伸缩的条带化数据存储系统，它通过librbd库与OSD进行交互。RBD为KVM等虚拟化技术和云OS（如OpenStack和CloudStack）提供高性能和无限可扩展性的存储后端，这些系统依赖于libvirt和QEMU实用程序与RBD进行集成。

客户端基于librbd库即可将RADOS存储集群用作块设备，不过，用于rbd的存储池需要事先启用rbd功能并进行初始   化。例如，下面的命令创建一个名为rbddata的存储池，在启用rbd功能后对其进行初始化：

```bash
$ ceph osd pool create rbddata 64
$ ceph osd pool application enable rbddata rbd
$ rbd pool init -p rbddata
```

不过，rbd存储池并不能直接用于块设备，而是需要事先在其中按需创建映像（image），并把映像文件作为块设备   使用。rbd命令可用于创建、查看及删除块设备相在的映像（image），以及克隆映像、创建快照、将映像回滚到快  照和查看快照等管理操作。例如，下面的命令能够创建一个名为img1的映像：

```bash
$ rbd create img1 --size 1024 --pool rbddata
```

映像的相关的信息则可以使用“rbd info”命令获取：

```bash
$ rbd --image img1 --pool rbddata info
```

在客户端主机上，用户通过内核级的rbd驱动识别相关的设备，即可对其进行分区、创建文件系统并挂载使用。

### 7.2 启用radosgw接口

RGW并非必须的接口，仅在需要用到与S3和Swift兼容的RESTful接口时才需要部署RGW实例，相关的命令为“ceph- deploy rgw create {gateway-node}”。例如，下面的命令用于把stor03部署为rgw主机：

```bash
$ ceph-deploy rgw create stor03
```

默认情况下，RGW实例监听于TCP协议的7480端口7480，需要算定时，可以通过在运行RGW的节点上编辑其主配置文件ceph.conf进行修改，相关参数如下所示：

```
[client]
rgw_frontends = "civetweb port=8080"
```

而后需要重启相关的服务，命令格式为“systemctl restart ceph-radosgw@rgw.{node-name}”，例如重启stor03上的RGW，可以以root用户运行如下命令：

```bash
$ sudo systemctl status ceph-radosgw@rgw.stor03
```

RGW会在rados集群上生成包括如下存储池的一系列存储池

```bash
$ ceph osd pool ls
mypool
rbddata
.rgw.root
default.rgw.control
default.rgw.meta
default.rgw.log
```

RGW提供的是REST接口，客户端通过http与其进行交互，完成数据的增删改查等管理操作。

### 7.3 启用文件系统（CephFS）接口

CephFS需要至少运行一个元数据服务器（MDS）守护进程（ceph-mds），此进程管理与CephFS上存储的文件相关 的元数据，并协调对Ceph存储集群的访问。因此，若要使用CephFS接口，需要在存储集群中至少部署一个MDS实  例。“ceph-deploy mds create {ceph-node}”命令可以完成此功能，例如，在stor01上启用MDS：

```bash
$ ceph-deploy mds create stor01
```

查看MDS的相关状态可以发现，刚添加的MDS处于Standby模式：

```bash
$ ceph mds stat
, 1 up:standby
```

使用CephFS之前需要事先于集群中创建一个文件系统，并为其分别指定元数据和数据相关的存储池。下面创建一个 名为cephfs的文件系统用于测试，它使用cephfs-metadata为元数据存储池，使用cephfs-data为数据存储池：

```bash
$ ceph osd pool create cephfs-metadata 64
$ ceph osd pool create cephfs-data 64
$ ceph fs new cephfs cephfs-metadata cephfs-data
```

而后即可使用如下命令“ceph fs status ”查看文件系统的相关状态，例如：

```bash
$ ceph fs status cephfs
```

此时，MDS的状态已经发生了改变

```bash
$ ceph mds stat
cephfs-1/1/1 up  {0=stor01=up:active}
```

随后，客户端通过内核中的cephfs文件系统接口即可挂载使用cephfs文件系统，或者通过FUSE接口与文件系统进行 交互。

