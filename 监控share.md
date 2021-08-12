# 监控方法论

## Netflix 的USE方法

用于分析系统性能问题，指导用户快速识别系统资源瓶颈，适用于主机指标监控：

- 使用率(utilization)
- 饱和度(saturation)
- 错误(errors) 

## Google的四个黄金指标

常用来衡量用户体验，服务中断，业务影响问题，适用于应用及服务监控。

- **延迟(Latency)：服务请求所需时间**
  - http请求平均延迟
  - 要区分失败请求和正常请求
- **流量(traffic)：监控当前系统的流量，用于衡量服务的容量需求**
  - 每秒处理的请求数或者数据库的事务数量
- **错误(errors)监控当前系统所有发生的错误请求，衡量当前系统错误发生的速率**
  - 请求失败的速率
  - 显示失败（http 500），隐士失败（返回内容不合符要求），策略原因失败（相应超过xx 毫秒）
- **饱和度(saturation)：衡量当前服务的饱和度**
  - 主要强调最能影响服务状态的受限制的资源。：例如CPU,MEMORY,IO,NETWORK等等

## Weave Cloud的RED方法

基于Google的四个环境指标原则，结合prometheus以及k8s容器实践，细化和总结的方法论，适用于云原生和微服务框架的监控和度量。

- (Request)Rate：每秒的请求数
- (Request)Errors：每秒失败的请求
- (Request)Duration：每个请求花费的时长

# 监控系统基础概念

## 监控系统组件

- 指标数据采集
- 指标数据存储
- 指标数据趋势分析和可视化
- 告警

## 监控体系

### 系统层监控

- OS监控：`CPU，Load，Memory，Swap，Disk IO，DISK USE，kernel parameter message...`

- 网络监控：`流入/流出流量，网络时延和丢包`

### 中间件层监控

- 消息中间件：`MQ,kafka...`
- WEB服务监控：`Tomcat,Jetty,Jboss...`
- 数据库监控：`oracle,mysql,pgsql`
- 存储系统监控：`ceph`

### 应用层监控

   用于衡量应用状态和性能，`request rate,request  errors,request duration`

### 业务层监控

   用于衡量应用程序的价值

- PV，UV，IP，DAU，转化率
- 业务接口：登录数，注册数，订单量，搜索量，支付量

# prometheus简介

Prometheus优势:

1. **高性能:内置时序存储系统**
2. **PromQL:提供非常灵活和强大的查询接口**
3. **动态服务发现，与k8s完美结果.**
4. 结合grafana:提供美观的监控页面
5. alterManager:自定义，多路由报警功能

## prometheus架构

- Prometheus 是一个开源的服务监控系统和时间序列数据库，但它的功能并非止步于TSDB，而是一款设计用于进行tagert监控的关键组件。
- 结合生态系统内的其它组件，例如Pushgateway，Aler Manager 和Grafana等，构成了一套完整的IT监控系统

![image-20210415103922478](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415103923.png)

![image-20210415110224114](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415110224.png)

## prometheus时间序列

![image-20210415111127621](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415111128.png)

## prometheus 数据模型

![image-20210415105948926](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415105949.png)

样本数据

![image-20210415111731353](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415111732.png)

## PromQL

### 基本用法

![image-20210415110054998](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415110055.png)

- 时间序列选择器

![image-20210415112355264](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415112355.png)

- 即时向量选择器

![image-20210415112337386](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415112338.png)

- 匹配器

![image-20210415112324166](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415112324.png)

- 范围向量选择器

![image-20210415112205769](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415112206.png)

- 偏移量修改器

![image-20210415112150073](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415112150.png)

### 高级用法

![image-20210415130126504](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415130127.png)

# 监控情况

## 已完成监控项

路径：organization（IT CEE HCI&Vendor）-- folder （SASCN）

### 系统层监控

http://monitoring.uat.homecreditcfc.cn/d/YeO_W0OGx/sascn_linux_server?orgId=4&refresh=30s

1. System overview
2. Process status
3. CPU&LOAD status
4. Memary Status
5. Disk I/O
6. Network Status

![image-20210415124508708](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415124509.png)

### 应用状态监控

http://monitoring.uat.homecreditcfc.cn/d/iP2rjIXGk/sas-application-monitoring?orgId=4&refresh=30s

1. 监控MA和RTDM各个组件的状态
2. 监控MA和RTDM每天备份情况

![image-20210415125138523](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415125139.png)

### 业务监控（待完善）

![image-20210415130231187](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415130231.png)

## 即将上线监控项

1. rtdm request rate
2. rtdm request duration
3. rtdm request  errors

![image-20210415131109365](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415131110.png)

![image-20210415132715455](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210415132716.png)

## 未完成监控

1. CDM synchronization status
2. ETL job status（HDW）
3. Contact History monitor
4. Response History monitor
5. 业务监控：比如转换率
6. ......



























ETL监控

ETL  LOG运行监控

select * from app_campaign_cdm.CIE_ETL_LOG 

判断逻辑：每个任务最后一次运行时间距离当前时间超过n小时，发送邮件告警。

目的：防止任务长时间被阻塞，而运维人员不知道。

ETL JOB for DWH OR Hadoop监控

select *
from owner_hub.v_etl_remote_data_status a
join owner_hub.v_etl_remote_dataset_settings b
on b.process_group=a.process_group where a.actual='YES'

判断逻辑：last_batch_status='COMPLETED'  and LAST_BATCH_START_TIME=trunc(sysdata) -1





