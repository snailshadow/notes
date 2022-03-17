# Linux 性能优化

## 1 内存

### 1.1 内存工作原理

1. linux内核给每个进程提供了一个独立的虚拟地址空间，并且这个空间是连续的。
2. 虚拟地址空间分为内核空间和用户空间。进程在用户态时只能访问用户空间内存，只有进入内核态后才能访问内核空间内存；虽然每个进程都有内核空间，但这些内核空间关联的是相同的物理内存。
3. 并不是所有的虚拟内存都会分配物理内存，只有实际使用的虚拟内存才分配物理内存；

 <img src="https://cdn.jsdelivr.net/gh/snailshadow/notes/img/20210316155255.png" alt="image-20210316155254320" style="zoom:52%;" />

 <img src="https://cdn.jsdelivr.net/gh/snailshadow/notes/img/20210316160051.png" alt="image-20210316160050393" style="zoom:50%;" />

### 1.2 内存回收的三种方式

1. 回收缓存，比如通过LRU算法回收最近很少使用的内存页面；
2. 回收不常访问的内存，把不常用的内存通过交换分区直接写到磁盘中；
   注意：此方法会用到swap分区。把进程暂时不用的数据放到磁盘（swap）上，不过会严重影响性能；
3. 通过oom杀死进程；
   - 一个进程消耗的内存越大，oom_score越大；
   - 一个进程运行占用的cpu越多，oom_score越小；
   - oom_score越大的进程，越容易被OOM杀死；
4. 可以通过调整/proc/${pidof sshd)/oom_adj来调整oom_score，值范围是[-17,15]，-17表示禁止被OOM；

### 1.3 内存分析工具

1. free
2. top
   - VIRT是进程申请的虚拟内存，比实际占用内存要大得多；
   - RES是常驻内存，是进程实际占用内存；
   - SHR是共享内存，比如与其他进程共同使用的共享内存、加载的动态链接库以及程序的代码段等。不过SHR也会有程序代码段，非共享动态链接库等，所以不能把多个进程的SHR相加得结果；
3. ps -u

### 其他

1. 查看OOM的进程 `dmesg |grep -E ‘kill|oom|out of memory`

![image-20210317224330792](https://cdn.jsdelivr.net/gh/snailshadow/notes/img/20210317224332.png)