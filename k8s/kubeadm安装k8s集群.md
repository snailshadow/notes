## kubeadm安装k8s集群

### 1. 基础环境准备

1. IP地址规划

| IP地址     | 主机名       | 角色   |
| ---------- | ------------ | :----- |
| 10.80.0.71 | k8s-master01 | master |
| 10.80.0.73 | k8s-node01   | node   |
| 10.80.0.74 | k8s-node02   | node   |
| 10.80.0.75 | k8s-node03   | node   |

2. 版本信息

| 操作系统   | ubuntu18.04    |
| ---------- | -------------- |
| 容器运行时 | docker18.09.ce |
| kubernetes | v1.19.14       |

3. 基础环境设置

- 主机时间同步  `apt-get install chrony;systemctl start chrony.service;systemctl enable chrony.service`  
- 关闭防火墙 `ufw disable;ufw status`  
- 禁用swap设备 `swapoff -a;vim /etc/fstab #注释所有swap挂载点`  

4. 配置容器运行引擎

```shell
# 安装必要的程序包
$ apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
# 添加docker官网的GPG证书
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg |apt-key add - 
# 添加稳定版本的docker-ce仓库
$ add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
$ add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# 更新apt索引，安装docker-ce
$ apt update
$ apt-get -y install docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic
# 配置docker 加速
$ cat /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
       "max-size": "100m"
    },
    "storage-driver": "overlay2",
    "registry-mirrors":["https://docker.mirrors.ustc.edu.cn/"]
}
# 启动docker
$ systemctl daemon-reload ; systemctl start docker;systemctl enable docker
```

### 2. 安装kubeadm，kubelet，kubectl

```shell
# 添加kubernetes官方程序密钥
$ curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
# 修改配置deb配置文件
$ vim /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
$ apt update
# 更新程序包索引并安装程序包
$ apt install -y kubelet=1.19.14-00 kubeadm=1.19.14-00 kubectl=1.19.14-00
```

### 3. 部署单控制平面的k8s集群

1. 初始化控制平面

```shell
    $ kubeadm init \
        --image-repository registry.aliyuncs.com/google_containers \
        --kubernetes-version v1.19.0 \
        --control-plane-endpoint k8s-api.ilinux.io \
        --apiserver-advertise-address 10.80.0.71 \
        --pod-network-cidr 10.244.0.0/16 \
        --token-ttl 0
```

初始化后结果

```shell
# 配置kubectl
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 部署pod网络组件
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

# 添加其它控制节点
You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

	kubeadm join k8s-api.ilinux.io:6443 --token p4xxgq.4laig907o0mnmut0 \
    --discovery-token-ca-cert-hash sha256:a8089d9719f7ef3f70c067324fe2cf19ebb28afc8cedba3763e290b8c3da4f27 \
    --control-plane
# 添加node节点
Then you can join any number of worker nodes by running the following on each as root:

	kubeadm join k8s-api.ilinux.io:6443 --token p4xxgq.4laig907o0mnmut0 \
    --discovery-token-ca-cert-hash sha256:a8089d9719f7ef3f70c067324fe2cf19ebb28afc8cedba3763e290b8c3da4f27
```

2. 配置kubectl

```shell
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

3. 部署pod网络插件（flannel）

```shell
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

### 4.开启http代理

```shell
$ kubectl proxy --port=8080
```

### 5.kubectl 自动补齐

```shell
# kubectl命令自动补全
$ yum install bash-completion 
$ echo "source /usr/share/bash-completion/bash_completion" >>  ~/.bashrc
$ echo 'source <(kubectl completion bash)' >>~/.bashrc
$ source ~/.bashrc
$ type _init_completion         #检查是否有正常内容输出
```

### 6.安装kubens

```shell
# 安装kubens工具
$ yum install -y git
$ git clone https://github.com/ahmetb/kubectx /opt/kubectx
$ ln -s /opt/kubectx/kubens /usr/local/bin/kubens
```















