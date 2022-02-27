---

# 1. kubernetes系统基础

## 1.1 容器与容器编排技术

### 1.1.1 Docker 容器技术

1. 核心概念：容器，镜像，镜像仓库
2. Docker存储驱动：aufs，devicemapper，overlay2，使用可堆叠镜像层和写时复制（CoW）策略
3. Docker网络模型：桥接模式，主机模式，容器模式，无网络
4. 跨主机通信：overlay network 和 routing network

### 1.1.2 OCI与容器运行时

1. OCI （open container initiative，开发工业标准）：定义了容器运行状态的描述，以及运行时需要提供的容器管理功能，例如：创建，删除，查看等操作。
2. Docker 1.11版本将docker 引擎由单一组件，拆分为 4个独立的项目 Docker engine，containerd，containerd-shim和runC，并把containerd捐给了CNCF

### 1.1.3 为什么需要容器编排系统

容器编排系统为用户提供的关键能力：

1. 集群管理和基础设施抽象
2. 资源分配和优化
3. 应用部署
4. 应用伸缩
5. 服务可用性

## 1.2 kubernetes 基础

### 1.2.1 kubernetes 集群概述

### 1.2.2 kubernetes集群架构

1. Master组件
   - API server
   - 集群状态存储
   - 控制管理器
   - 调度器
2. Node组件
   - kubelet
   - 容器运行时环境
   - kube-proxy
3. 核心附件
   - CoreDNS
   - Dashboard
   - 监控系统
   - 日志系统
   - Ingress Controller

## 1.3 应用的运行与互联互通

### 1.3.1 Pod与service

CoreDNS 为每个service生成一个唯一的DNS名称，以及相应额DNS资源记录，标准是：svcName.namespace.svc.cluster-domain

kubelet在创建POD时会自动在/etc/resolv.conf配置集群中CoreDNS的服务的ClusterIP作为DNS服务器。

### 1.3.2 Pod控制器

POD控制器是用来跨工作节点管理POD生命周期，使用POD具备自动恢复。

控制器就是一个控制循环程序，确保对象的状态符合期望状态。

deployment  -- 无状态应用

statefulSet -- 有状态应用

### 1.3.3 kubernetes 网络基础

4种网络类型

- 同一POD内容器间通信： 同一network空间，通过lo直接通信
- POD间通信：处于同一网络平面，不需要NAT ，使用pod地址直接通信
- POD与service间通信： service是虚拟网络，不会被添加到任何网络接口，通过iptable/ipvs规则完成报文转发
- 集群外与service的通信： NodePort，LoadBlancer和Ingress

POD和service分别使用了专用网络，其中service的网络由k8s集群管理，但是集群并没有实现POD网络，需要借助于符合CNI规范的网络插件实现。

### 1.3.4 部署并访问应用

部署：用户只需要向API server请求创建一个POD对象，控制器根据配置的POD模板向API server请求创建出一定数量的POD实例。

外部客户访问集群应用： 通过NodePort，LB以及ingress，将外部流量引入集群内部，然后进行内部的服务请求和响应。

service -- TCP层完成调度

ingress -- HTTP/HTTPS层完成调度

## 1.4 简析kubernetes生态系统

kubernetes整合并抽象了底层的硬件和系统环境等基础设施，对外提供了一个统一的资源池供用户通过API进行调用。几个重要特性：

1. 自动装箱   -- 基于容器，一次开发，到处运行
2. 自我修复   -- 自动重启，节点故障自动重新调度到其它节点，健康状态检查失败自动关闭并重建  等等自愈机制
3. 水平扩展   -- 通过命令或UI 手动水平扩展，或者 基于CPU等资源负载自动水平扩展
4. 服务发现   -- kubeDNS/CoreDNS 内置服务发现功能，为每个service配置DNS名称，并允许集群内的客户端直接使用此名称访问。
5. 负载均衡   -- service通过iptable和ipvs内置了负载均衡策略
6. 自动发布和回滚   -- 支持"灰度" 更新应用程序或配置信息，确保不会在同一时刻杀掉所有实例，遇到故障可以快速回滚操作。
7. 密钥和配置管理   -- configmap 存储配置数据，secret存储敏感数据
8. 存储编排   -- POD对象可以按需自动挂载不同类型的存储系统，包括本地存储，公有云存储和网络存储等
9. 批量处理执行   -- 除了服务型应用，k8s还支持批处理作业

生产场景中kubernetes生态

1. Docker Registry和工件仓库： 通过Harbor工件仓库和Docker Registry等项目实现
2. 网络：借助Flannel，Calico 或者WeaveNet等项目实现
3. 遥测：借助Prometheus 和EFK/PLG(Promtail，Loki，Grafna)等项目实现
4. 容器化负载; opertor，应用打包：Helm或kustomize
5. 基于容器编排系统的CI/CD： 借助jenkins，Tekton，Flagger或者Kepton等项目

---

# 2. kubernetes快速入门

## 2.1 利用kubeadm部署kubernetes集群

### 2.1.1 kubeadm部署工具

kubeadm init 创建新的控制平面

kubeadm join 将节点加入指定的控制平面

kubeadm reset 重置回初始状态

kubeadm token 管理集群构建后节点加入集群时使用的认证令牌

### 2.1.2 集群组件的运行模式

1. 独立组件模式 : Master各组件和Node各组件直接以守护进程的方式运行于节点之上，eg. 二进制部署
2. 静态POD模式：控制平面各组件以静态POD对象形式运行在Master主机之上，Node主机的kubelet和Docker为系统守护进程，kube-proxy托管于集群的DaemonSet控制器
3. 自托管（self-hosted）模式：类似第二种模式，但控制平面的各组件运行为POD对象（非静态），并且这些POD对象同样托管运行在集群之上，受控于DaemonSet类型的控制器

kubeadm部署时默认时第二种，可以通过 --features-gates=selfHosting 改为自托管模式

### 2.1.3 kubeadm init工作流程

1. preflight -- 引导前检查
2. kubelet-start  -- 生成kubelet配置，启动/重启kubelet程序，以便静态POD运行各组件
3. certs  -- 生成私钥以及数字证书
4. kubeconfig  -- 生成控制平面的kubeconfig文件
5. control-plane  -- 生成控制平面组件的manifest文件
6. etcd  -- 为本地etcd生成静态pod清单
7. upload-config -- 将kubeadm和kubelet的配置文件存储为集群上的configmap资源对象
8. upload-certs  -- 上传证书为kubeadm-certs
9. mark-control-plane  -- 设定Master标志
10. bootstrap-token  -- 进行基于TLS的安全引导相关的配置
11. addon  -- 安装DNS和kube-porxy核心附件

### 2.1.4 kubeadm join工作流程

加入的节点可以是master节点也可以是work节点，如果加入的是master节点：

1. 环境预检查
2. 从集群控制平面数字证书
3. 更新配置信息闭并完成TLS Bootstrap
4. 为本地运行的etcd生成配置清单，由kubelet启动静态pod
5. 将节点信息上传kube-system namespace中的configmap对象的kubeadm-config中
6. 为该节点添加控制平面专用标签和污点

### 2.1.5 kubeadm配置文件

kubeadm可以通过--config接收自定义配置，主要有4中配置类型：

1. InitConfiguration 提供运行时配置  --强制要求
2. ClusterConfiguration 定义集群配置  --强制要求
3. KubeProxyConfiguration 定义要传递给kube-proxy的自定义配置
4. KubeletConfiguration 指定要传递给kubelet的自定义配置

kubeadm config print init-defaults 命令可以打印默认使用的配置

## 2.2 部署分布式kubernetes集群

-- 略，详见"kubeadm安装k8s集群.md"

## 2.3 kubectl命令和资源管理

### 2.3.1 资源管理操作

kubernetes API 资源管理操作分为：增，删，改，查这4种，kubectl可以读取.yaml,.yml,.json为后缀的文件

配置清单中多个资源彼此使用"---" 符号作为分隔符

### 2.3.2 kubectl 命令格式

kubect [command] [TYPE] [NAME] [flags]

command: 子命令，例如get，create，apply，delete，run等

TYPE： 资源类型，例如pods，services等；大小写敏感，但支持单复数 或者简写

NAME: 资源名称，大小写敏感，省略时，表示指定TYPE下的所有资源；多个资源 逗号分隔；

flags：命令行选项，例如 -s 指定apiserver的地址，-o <format> ，-n namespace，-l key=value，-W 监视资源变动信息等

### 2.3.3 kubectl命令常用操作示例

1. 创建资源   kubectl create ，kubectl run，kubectl apply -f
2. 查看资源   kubectl get -l -n -o
3. 打印资源详细信息 kubectl get -o yaml ，kubectl describe
4. 打印容器日志信息 kubectl logs -f podname -n namespace
5. 容器中执行命令 kubectl exec pod -- command
6. 删除资源对象 kubectl delete  -l key=value，--all -n namespace,--force --grace-period=0

### 2.3.4 kubectl 插件

插件管理器 - Krew，它能够帮助用户打包，分发，查找，安装和管理kubectl插件，项目地址https://krew.sigs.k8s.io

## 2.4 命令式应用编排

### 2.4.1 应用编排   kubectl create deployment

### 2.4.2 部署service对象 kubectl create service

### 2.4.3 扩容与缩容 kubectl scale

### 2.4.4 修改和删除对象 kubectl edit ，kubectl scale，kubectl set image ，kubectl delete

---

# 3. kubernetes 资源管理

## 3.1 资源对象和API群组

### 3.1.1 kubernetes资源对象

以资源的主要功能分类，API对象大体分为4类

1. 工作负载
   - pod
   - ReplicationController  --旧的POD副本控制器，只支持等值选择器
   - ReplicaSet  --新的POD副本控制器，既支持等值选择器，又支持集合选择器
   - Deployment   --管理无状态应用，构建在RS之上，更为高级得控制器。支持滚动升级，事件和状态查看，回滚，版本记录，暂停和启动。
   - StatefulSet  --管理有状态应用，会为每个POD创建一个独有得持久性标识，并会确保POD间得顺序性
   - DaemonSet  -- 用于确保每个节点都运行一个POD
   - Job  --用户管理运行完成后即可终止的应用，job会创建1个或多个POD
2. 发现与负载均衡
   - service
3. 配置与存储
   - volume
   - configmap
   - secret
4. 集群类型资源
   - Namespace
   - Node
   - Role
   - ClusterRole
   - RoleBinding
   - ClusterRoleBinding
5. 元数据类型资源
   - HPA
   - LimitRange

### 3.1.2 资源及在API的组织形式

1. 资源类型是指在URL中使用的名称，例如pods，namespace，service等，其URL格式为 GROUP/VERSION/RESOURCE，例如apps/v1/deployments
2. 每个资源类型都有一个对应的json表示格式；
3. Kind表示资源对象所属的类型
   - 对象类  eg. pod service
   - 列表类  eg.  podlists，nodelists
   - 简单类  eg.  binding

kubernetes把API分隔为多个逻辑组合 以便扩展和管理，每个组合称为一个API群组，支持单独启用和禁用，并能够再次分解。不同的群组使用不同的版本，同一个集群可以存在不同的版本。当前集群API server支持的API群组和版本信息可以通过 kubectl api-version命令查看。

每个api群组表现为以/apis为根路径的RESTful路径，例如 /apis/apps/v1，不过名称为core的核心群组有一个专用的简化路径：/api/v1，目前常用的api群组有两类：

1. 核心群组
   - RESTful路径： /api/v1
   - 资源配置apiVersion： 可以不指定路径，仅给出版本 例如： apiVersion: v1
2. 命名的群组
   - RESTful路径： /apis/$GROUP_NAME/$VERSION，例如： /apis/apps/v1
   - 资源配置apiVersion：移除前缀apis，例如： apiVersion: apps/v1
3. 名称空间级 的资源类型在API的URL表示为： /apis/$GROUP_NAME/$VERSION/namespaces/$namespace/$kind-plural，例如：查询default命名空间下面的所有deployment，/apis/apps/v1/namespaces/default/deploymnets

### 3.1.3 访问kubernetes RESTful API

默认API server仅支持双向SSL/TLS认证的HTTPS通信，客户端需要现在服务端认证才能与之建立通信。临时测试可以使用kubectl proxy在本地主机为API server启动一个代理网关，以支持HTTP协议。

```shell
$ kubectl proxy --port=8080
```

## 3.2 对象类资源配置规范

创建对象时，必须提供： 期望状态，以及相关的基本信息，例如对象名称，标签和注解等元数据。

1. 类型元数据： kind，apiVersion
2. 对象元数据： metadata，spec，status

### 3.2.1 定义资源对象

简单方式 通过kubect get TYPE/NAME -o yaml 快速获取资源对象的配置清单示例。

### 3.2.2 对象元数据

metadata字段内嵌多个字段以定义对象元数据，分为必要字段和可选字段

1. 必选字段
   - namespace
   - name
   - uid
2. 可选字段
   - labels
   - annotations
   - resource Version
   - generation
   - CreationTimestamp
   - deletionTimestamp

在配置清单里面未定义的字段由一系列的finalizer组件自动填充，另不同的资源也会有一些专用的嵌套字段，例如：configmap的 clusterName

### 3.2.3 资源的期望状态

spec： 声明的期望状态，用户负责定义

status：实际观测到的状态，由kubernetes系统负责更新，不支持用户手动操作

### 3.2.4 获取资源配置清单文档

1. kubectl explain pod   /   kubectl explain pod.spec
2. kubect get TYPE/NAME -o yaml --export，其中`--export` 用于省略系统生成的信息，但在v1.18本版后正式废弃

### 3.2.5 资源对象管理方式

1. 命令式命令

   - 创建 run ,expose,autoscale,create  <对象类型> <子类型> <实例>
   - 更新 scale，annotate，label，set，edit，patch
   - 删除 delete
   - 查看 get，describe，logs

2. 命令时对象配置

   与命令式命令不同，它通过配置清单读取要管理的目标资源对象  kubectl create|delete|replace|get -f <file/url>

3. 声明式对象配置

   kubectl apply -f <file/url>

## 3.3 名称空间

### 3.3.1 名称空间的作用

kubernetes的namespace不能实现pod间通信隔离，仅用于限制资源对象的名称（不同ns的名称可以重复）的作用域。默认情况下kubernetes有4个名称空间：

1. default   创建资源对象时，未指定ns时，默认使用的命名空间
2. kube-public  用于集群上所用用户（包括匿名用户）提供一个公共可用的名称空间
3. kube-system  用于部署kubernetes系统相关的组件，不建议部署其它非系统相关的组件
4. kube-node-lease 专用于放置kubelete lease对象的名称空间，不建议部署其它非系统相关的组件

### 3.3.2 管理namespace

1. 命令式命令

   - kubectl create ，get，describe，edit和delete

   - 删除namespace时会删除namespace和下面的所有资源，常用删除命令

     ```shell
     $ kubectl delete TYPE RESOURCE -n NS  #删除指定空间的指定资源
     $ kubectl delte TYPE --all -n NS   #删除指定空间的指定类型的资源
     $ kubectl delete all --all -n NS   #删除指定空间内的所有资源
     ```

2. 命令式对象配置

   kubectl get ns NSNAME -o yaml

   > 注意： spec.finalizers 称为垃圾收集器，当ns指定了不存在的终结器时并不会影响创建，但删除该namespace时会被”卡住“，删除操作会一直停留在Terminating状态，解决方法
   >
   > - kubectl get ns NSNAME -o json > xxx.json
   >
   > - 编辑json文件，将其中spec.finalizers修改为空
   > - kubectl replace --raw "/api/v1/namespaces/demo/finalize" -f xxx.json

3. 生命是对象配置  kubectl apply -f xxx.yaml

## 3.3 节点资源

### 3.4.1 节点心跳和节点租约

kubelet负责向master上报自身运行状态（心跳信息）以维持集群正常运行。

- v1.13版本之前，节点心跳通过NodeStatus 10s发送一次，如果在node-monitor-grace-period 指定的时长（默认40s）没有收到心跳，节点控制器把节点标记为NotReady状态，而在pod-eviction-timeout指定的时长仍然没有收到心跳信息，则节点控制器将从该节点驱逐Pod对象
- v1.13版本后引入了节点租约`kubectl get leases -n kube-node-lease`,节点租约与NodeStatus协同工作逻辑如下
  1. kubelet定期更新自己的lease对象，默认为10s
  2. kubelet定期（默认为10s）计算一次NodeStatus，但并不直接上报给Master
  3. 仅NodeStatus变动时，或者已经超过node-status-update-period指定的时长（默认5分钟）时，kubelet将发送NodeStatus心跳给Master

### 3.4.2 节点状态

kubectl describe nodes NODENAME，包括

