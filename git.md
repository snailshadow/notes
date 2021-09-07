# 1 版本管理的演变

## 1.1 VCS 出现前

- 目录拷贝区别不同的版本
- 公共文件容易被覆盖
- <font color=red>缺点</font>:沟通成本高，代码集成效率低

## 1.2 集中式VCS

- 集中版本管理的服务器
- 具备文件版本管理和分支管理能力,不同版本比较，集成效率明显提高
-  <font color=red>缺点</font> ：客户端必须时刻与服务器相连接，速度和性能存在瓶颈，客户端没有完整的版本。

## 1.3 分布式VCS

- 服务端和客户端都有完整的版本库
- 脱离服务端，客户端仍然可以做版本管理
- 查看历史，版本比较等多数操作，都不需要访问服务器，比集中式VCS更能提高版本管理的效率

# 2 Git

参考博客：https://www.cnblogs.com/jianguo221/category/1260861.html

## 2.1 安装

http://git-scm.com/book/zh/v2/%E8%B5%B7%E6%AD%A5-%E5%AE%89%E8%A3%85-Git

## 2.2 Git config

- config的三个作用域

```shell
$ git config --local 		# 只对本地某个仓库有效
$ git config --global      	 # golbal对当前用户所有仓库有效
$ git config --system     	 # system对系统所有登录的用户有效
$ git config --global --edit # 编辑配置信息
$ git config --global --unset user.name # 删除配置信息
$ git config --list --global # 查看配置信息
$ git config --global user.name # 查看指定配置信息
# 优先级： local>global
#查
git config --global --list
git config --global user.name
#增
git config  --global --add user.name jianan
#删
git config  --global --unset user.name
#改
git config --global user.name jianan
```

- 配置user信息

```shell
$ git config --global user.name 'collin'
$ git config --global user.email 'collin@163.com'
```

*<font color=yellow>配置user.name 和user.email，作用：每次变更与user捆绑，code review 评审后自动发送邮件</font>*

- 配置git帮助信息通过谷歌浏览器打开

```shell
$ git config --global web.browser 'chrome'
$ git config --global browser.chrome.path 'C:\Program Files\Google\Chrome\Application\chrome.exe'
```

## 2.3 建git仓库

**<font color=red> 两种场景</font>**

- 已有项目代码，纳入git管理

```shell
$ cd 项目文件夹
$ git init
```

- 新建项目，用git管理

```shell
$ cd 某个文件夹
$ git init project_name # 会在当前路径下创建项目名称的文件夹
$ cd project_name 
```

## 2.4 Git 管理命令

### 2.4.1 基础命令

$ git add filename # 将文件/目录 纳入git管理，添加文件/目录到暂存区
$ git rm filename # 删除文件(删除工作区和暂存区的文件)
$ git mv oldfilename newfilename # 重命名文件

$ git add -u # 将所有文件纳入git管理，提交到暂存区，等同于 git add .
$ git status # 查看git状态，包括分支信息，文件变更信息
$ git log # 查看版本历史
$ git reset HEAD #将暂存区(reset)的版本恢复到HEAD 场景：工作区的最新版本好于暂存区的版本。
$ git reset HEAD -- file01 file02 #将暂存区(reset)部分文件恢复到HEAD
$ git reset --hard #清空工作目录和暂存区的所有变更，版本回到HEAD
$ git reset --hard commitId # 版本回滚到某一个commit，且暂存区和工作目录都会到这个版本。后面的commit会丢失 
$ git push -f origin branchname # 强制将本地分支版本push到远端分支。会导致commit丢失，禁止使用。
$ git checkout --  file01 file02 # 将工作区(checkout)恢复成暂存区，场景：工作区的最新版本不如暂存区的版本好。

### 2.4.2 commit操作

$ git commit -m'add file' # 提交到本地仓库
$ git commit -am'add and commit file' # 添加文件到暂存区，并提交到本地仓库
$ git commit --amend # 对当前分支，最近一次commit的message做变更
$ git rebase -i 父commitId  #修改历史commit的message。r 修改message, p use commit
$ git rebase -i 父commitId  #连续的commit合并，s commit合并
$ git rebase -i 父commitId  #不连续的commit合并，1，调整顺序，将需要合并的放到一起 2，s commit合并
$ git rebase --continue # 继续rebase操作

### 2.4.3 远端仓库

$ git remote -v # 查看远端仓库列表
$ git remote add remotename file:///d/git_learn/backup/zhineng.gi # 添加远端仓库（本地智能）
$ git push --set-upstream remotename localname # 将本地仓库推送到远端仓库

### 2.4.4 object操作

$ git cat-file -t fc6143fe0bd # 查看对象类型 例如commit/tag/treea/blob
$ git cat-file -p fc6143fe0bd # 查看对象内容

## 2.5 版本历史比较

$ git diff commitid01 commitid02 [-- file01 ]# 比较2个commitId
$ git diff branch01 branch02 # 比较2个分支
$ git diff branch01 branch02 -- file01  # 比较2个分支的指定文件差异
$ git diff HEAD HEAD^ # 比较最新版本和上一个版本的差异 HEAD~1,HEAD~2 <==> HEAD^^
### 2.5.1 版本历史与暂存区比较

```shell
$ git diff --cached # 暂存区和HEAD(当前版本)比较
```

### 2.5.2 暂存区与工作区比较

```shell
$ git diff
$ git diff --  file01 file02 ......   # 比较指定文件的内容
```

### 2.5.3 查看版本历史

- 命令行查看版本历史

``` shell
$ git log # 查看版本历史
$ git log --oneline branchname # 简洁方式查看指定分支的版本历史
$ git log -n4 --oneline # 查看最近4此的变更历史
$ git log --all # 查看所有分支版本演进历史，不加--all 默认显示当前分支的历史
$ git log --all --graph # 图形化显示版本演进历史
$ git log --oneline --all -n3 --graph #所有分支最近四次版本历史
```

- 图形化界面查看版本历史

```shell
$ gitk
```

## 2.6 分支管理

```shell
$ git branch -v # 查看本地分支信息，且当前分支前面有“*”号标记
$ git branch -r # 查看远端分支信息
$ git branch -a # 查看本地和远端有多少个分支
$ git branch -d branchname/commitId # 删除本地分支
$ git branch -D branchname/commitId # 强制本地删除分支
$ git branch -d -r branchname # 删除远端分支，还需要执行push命令，才能真正删除：git push origin:branchname
$ git checkout branchname [commitid]  # 创建并切换到本地分支
$ git checkout  -b  mybranch origin/mybranch #去远程分支并分化一个新的分支到本地；且本地已经切换到了该新分支.
$ git checkout -b branchname commitid  # -b 创建并切换到分支
```

## 2.7 git的备份

 ***常用的传输协议***

| 常用协议              | 语法格式                                                     | 说明             |
| --------------------- | ------------------------------------------------------------ | ---------------- |
| 本地协议1             | /path/to/repo.git                                            | 哑协议           |
| 本地协议2             | file:///path/to/repo.git                                     | 智能协议         |
| http协议<br>https协议 | http://git-server.com:port/path/to/repo.git<br/>https://git-server.com:port/path/to/repo.git | 需要用户名和密码 |
| ssh协议               | user@git-server.com:path/to/repo.git                         | 需要公钥和私钥   |

***哑协议和智能协议***

- 哑协议传输进度不可见，智能协议传输可见
- 智能协议比哑协议传输速度快

***备份特点***

- 多点备份

```shell
# 本地备份
$ git clone --bare /d/git_learn/git/.git ../backup/ya.git   # 哑协议
$ git clone --bare file:///d/git_learn/git/.git ../backup/zhineng.git  #智能协议

# 本地远端备份
$ git remote add zhineng file:///d/git_learn/backup/zhineng.git  # 添加远端仓库
$ git push --set-upstream zhineng temp02

```

### 2.4.5 远端仓库管理

```shell
检出仓库：$ git clone git://github.com/jquery/jquery.git
查看远程仓库：$ git remote -v
添加远程仓库：$ git remote add [name] [url]
删除远程仓库：$ git remote rm [name]
修改远程仓库：$ git remote set-url --push[name][newUrl]
拉取远程仓库：$ git pull [remoteName] [localBranchName]
推送远程仓库：$ git push [remoteName] [localBranchName]:[remoteBranchName]
```

### 2.4.6 tag管理

```shell
查看版本：$ git tag
创建版本：$ git tag [name]
删除版本：$ git tag -d [name]
查看远程版本：$ git tag -r
创建远程版本(本地版本push到远程)：$ git push origin [name]
删除远程版本：$ git push origin :refs/tags/[name]
```

## 2.5 .git对象

### 2.5.1 git对象类型

```shell
-rw-r--r-- 1 tiany 197617  30 Feb 16 12:13 COMMIT_EDITMSG
-rw-r--r-- 1 tiany 197617  23 Feb 16 12:14 HEAD			# 指向当前工作的分支
-rw-r--r-- 1 tiany 197617 189 Feb 16 12:34 config		# git config配置的内容
-rw-r--r-- 1 tiany 197617  73 Feb 16 11:33 description
-rw-r--r-- 1 tiany 197617 132 Feb 16 14:18 gitk.cache
drwxr-xr-x 1 tiany 197617   0 Feb 16 11:33 hooks/
-rw-r--r-- 1 tiany 197617 174 Feb 16 12:14 index
drwxr-xr-x 1 tiany 197617   0 Feb 16 11:33 info/
drwxr-xr-x 1 tiany 197617   0 Feb 16 11:36 logs/
drwxr-xr-x 1 tiany 197617   0 Feb 16 12:13 objects/		# 核心目录，存储git所有对象信息tree/blob/commit  以及tag
drwxr-xr-x 1 tiany 197617   0 Feb 16 11:33 refs/		# heads 存放分支信息，tags存放tag信息
```

### 2.5.2 git对象彼此关系

![image-20210216144534684](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210216144534684.png)

- 一个commit 对应一棵树，可以理解为一个版本快照
- tree可以理解为文件夹
- blob可以理解为文件，文件内容相同 blob就项目，与文件名无关

![image-20210216150916326](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210216150916326.png)

- <font color=red>***Tips1：通过`git cat-file -t/p` 查看对象类型和内容* **</font>
- <font color=red>***Tips2：`git add` 添加缓存区后，会生成1个object，blob就会生成* **</font>
- <font color=red>***Tips3：`git commit` 提交到本地仓库后，会生成4个object，1个commit，2个tree，1个blob* **</font>

## 2.6 detached HEAD分离头指针

HEAD --> commitid，没有指向branch，即，工作在没有分支的状态下。

缺点：commit需要和branch关联在一起，否则在切换分支后，这些变更会被git认为时垃圾而清理掉。 如果希望保留需要为该commitid创建分支`git checkout branchname commitid`

优点：临时的开发实验，随时丢弃，只需切换到master分支即可。

```shell
$ git checkout commitid # 基于某个commit 生成一个分离头指针的版本
$ git log
commit fc6bd100c3e3405234b453710ae14b8ce36dbc21 (HEAD)     #HEAD 没有执行任何分支
Author: collin <tianyu29792569@163.com>
Date:   Tue Feb 16 15:20:28 2021 +0800

    add file
```

## 2.7 场景

### 2.7.1 场景1

工作区部分修改已提交，部分还在修改中。此时又报了新的BUG，需要先修改BUG再开发新版本。

解决方案：

- 先将手头工作放到某区域，保存起来
- 修改BUG，commit提交
- 切换回以前的状态

```shell
$ git stash # 当前工作区的内容保存起来，此时工作区的内容回到了HEAD
$ git stash list # 查看stash列表
$ git stash apply # 将stash信息，应用到工作区，但stash列表中信息还在,可以反复使用
$ git stash pop # 将stash信息恢复到工作区，同时删除stash
```

### 2.7.2 场景2

哪些文件不需要列入git管理 <font color=red>***.gitignore***</font>, 参考链接：https://github.com/github/gitignore

### 2.7.3 场景3

- 多人同时开发同一个分支，修改的不同文件
- 多人开发同一个分支，修改同一个文件，不同区域

解决方法：git fatch + git merge  或者 git pull 

```shell
$ git clone git@github.com:snailshadow2019/test.git test_local # 克隆远端仓库，并修改名称为test_local
$ git config --add --local user.name 'snailshadow'
$ git config --add --local user.email 'git201901xdx@163.com'
$ git checkout -b featuer/add_git_commands origin/featuer/add_git_commands # 基于远端分支，创建本地分支.默认会建立本地和远端的对应关系
$ git push # 将本地分支push到远端分支
#等价于
$ git push origin 本地分支:[远端分支]
```

fast-forwards 解决方法1：merge

```shell
$ git fatch github # 将远端分支拉取下来
$ git merge github/feature/add_git_commands # 将本地分支和远端分支进行merge
```

### 2.7.4 场景4

多人同时开发同一个分支，修改的是相同文件，相同的区域

用git fatch + git merge  或者 git pull  会报错

![image-20210217001713568](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210217001713568.png)

解决方法：

```shell
$ vi index.html #人工排查冲突内容，编辑并保存内容
$ git commit -am'reslove conflict'
```

### 2.7.5 场景5

多人同时开发同一个分支，用户A修改了某文件的名子，用户B基于原来的文件名在修改。

无论谁先提交到远端仓库，后面一个人再push时都会报错（***Note about fast-forwards***）。

解决方法：

报错的人执行：git pull   此时git会自动fatch+merge，并自动识别哪个文件名称发生了改变，最终文件名称以远端仓库的文件名为准。

### 2.7.6 场景5

多人同时开发同一个分支，用户A和用户B 都修改了同一个文件的名子。

无论谁先提交到远端仓库，后面一个人再push时都会报错（***Note about fast-forwards***）。

此时使用git pull 不能解决问题，汇报如下错误：

![image-20210217003405475](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210217003405475.png)

解决方法：

```shell
$ git status 
```

![image-20210217003607836](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210217003607836.png)

协商解决：例如index-->index1按照提示信息操作

```shell
$ git rm index.htm
$ git add index1.htm
$ git rm index2.htm
$ git commit -am'decide mv index to index1'
$ git push
```



## 2.8 ssh协议链接github

### 2.8.1 生成ssh key

```shell
$ ssh-keygen -t ed25519 -C "git201901xdx@163.com"
```

### 2.8.2 github用户添加公钥

```shell
$ cat ~/.ssh id_ed25519.pub
```

将公钥内容粘贴到github用户setting页面的 [SSH and GPG keys]中：

![image-20210216205119657](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210216205119657.png)

### 



## 2.9 本地仓库推送到github

- 添加github的remote仓库

```shell
$ git remote add github git@github.com:snailshadow2019/test.git
```

- 将本地所有分支push到github

```shell
$ git push github --all		# 将本地所有分支推送到远端
$ git fatch github master # 拉取远端master分支到本地
$ git merge github/master --allow-unrelated-histories  # merge 远端master和本地master
修改远程仓库：$ git remote set-url --push[name][newUrl]
拉取远程仓库：$ git pull [remoteName] [localBranchName]
推送远程仓库：$ git push [remoteName] [localBranchName]:[remoteBranchName]
```

<font color=red>注意：git pull <==> git fatch + git merge</font>

## 2.10 注意事项

- 禁止push -f
- 公共集成分支不要做rebase

# 3 github



## 3.1 高效搜索

https://docs.github.com/en/github/searching-for-information-on-github/searching-for-repositories

示例：

`git最好学习资料 in:readme stars:>5000`

# 4 FAQ

## 4.1 remote: Support for password authentication was removed on August 13, 2021

​     密码凭证从2021年8月13日开始不能用了，必须使用个人访问令牌（personal access token），就是把你的`密码`替换成`token`

1. 生成自己的token

- 个人页面，找到setting

- 选择developer setting

- 选择personal access tokens，然后点击 generate new token

- 设置token的权限，点击generate token

  ![image-20210907141444782](https://cdn.jsdelivr.net/gh/snailshadow/img/img/20210907141445.png)

2. 将token添加到远程仓库配置

   ```shell
   git remote set-url origin https://<your_token>@github.com/<USERNAME>/<REPO>.git
   #<your_token>：换成你自己得到的token
   #<USERNAME>：是你自己github的用户名
   #<REPO>：是你的仓库名称
   #示例：
   git remote set-url origin https://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@github.com/snailshadow/notes.git
   ```

## 4.2 There is no tracking information for the current branch

- 一种是直接指定远程master  

  ```shell
  git pull origin main
  ```

- 另外一种方法就是先指定本地master到远程的master，然后再去pull

  ```shell
  git branch --set-upstream-to=origin/main main
  git pull
  ```

## 4.3 git设置代理

- 设置SSH协议代理

  ```shell
  #SSH协议连接的远程仓库。因为git依赖ssh去连接，所以，我们需要配置ssh的socks5代理实现git的代理。在ssh的配置文件~/.ssh/config（没有则新建）使用ProxyCommand配置：
  #Linux
  Host github.com
    User git
    Port 22
    Hostname github.com
    ProxyCommand nc -x 127.0.0.1:10808 %h %p
  #windows
  Host github.com
    User git
    Port 22
    Hostname github.com
    ProxyCommand connect -S 127.0.0.1:10808 %h %p
  ```

- 设置https协议代理

  ```shell
  #http/https协议，所以可以使用git配套的CMSSW支持的代理协议：SOCKS4、SOCKS5和HTTPS/HTTPS。可通过配置http.proxy配置：
  # 全局设置
  git config --global http.proxy socks5://localhost:10808
  # 本次设置
  git clone https://github.com/example/example.git --config "http.proxy=127.0.0.1:1080"
  ```

- 设置git协议代理

  ```shell
  #使用git协议连接。所以，需要使用CMSSW提供的简单脚本去通过socks5代理访问：git-proxy。配置如下：
  git config --global core.gitproxy "git-proxy"
  git config --global socks.proxy "localhost:1080"
  ```

  



















