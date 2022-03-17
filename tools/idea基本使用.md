## 配置文件

```
D:\program files\IntelliJ IDEA 2020.3.2\bin\idea.properties
D:\program files\IntelliJ IDEA 2020.3.2\bin\idea64.exe.vmoptions
```

## 快捷键

| 类型         | 快捷键          | 功能                                       |
| ------------ | --------------- | ------------------------------------------ |
| 代码自动生成 | psvm            | 创建main方法                               |
|              | sout            | 输出信息                                   |
|              | ctrl+空格       | 代码自动生成，与输入法切换冲去需要手工修改 |
|              | alt + insert    | 生成代码，例如getter，to string等等        |
|              | ctrl+shift+回车 | 自动补全结尾                               |
|              | ctrl+j          | 自动代码生成模板。例如sout，psvm，fori等等 |
|              | list.for        | 列表自动循环                               |
|              | alt+回车        | 导包或者修正导包                           |
| 代码优化     | ctrl+alt+L      | 格式化代码（与QQ快捷键冲突）               |
|              | ctrl+alt+i      | 自动缩进                                   |
|              | ctrl+p          | 方法参数提示                               |
|              | ctrl+alt+t      | 把选中代码放到循环中，例如if               |
| 代码编辑     | ctrl+y          | 删除行                                     |
|              | ctrl+d          | 复制行                                     |
|              | ctrl+w          | 自动选中代码，按多次，逐步放大选择范围     |
|              | ctrl+shift+w    | 逐步缩小选择范围                           |
|              | ctrl+g          | 跳转到指定行                               |
|              | ctrl+shift+u    | 转换大小写                                 |
|              | alt+上/下方向键 | 移动光标到上/下一个方法                    |
| Debug调试    | F7              | 下一步                                     |
|              | alt+F9          |                                            |
| 查询         | ctrl+n          | 查找类                                     |
|              | ctrl+shift+n    | 查找文件                                   |
|              | ctrl+f          | 查找文本内容                               |
|              | ctrl+r          | 替换文本内容                               |
|              | ctrl+e          | 查找最近修改的代码文件                     |
| 其他         | ctrl+/          | 单行注释                                   |
|              | ctrl+shift+/    | 多行注释                                   |

## java项目打包

- 打包路径

  file-->Project Stucture-->Artifacts--> "+" JAR   --> apply-->ok

  build-->build artifacts

- 测试打包是否成功

```
D:\Java Project\out\artifacts\demo_jar>java -cp demo.jar com.demo.java.HelloWorld
```

## 基本配置

1. ctrl+鼠标  调整字体大小    file--setting--editor -- general--> "Change font size with......"
2. 鼠标悬浮 代码提示			file--setting--editor -- code editing--> "show quick documentation on mouse move"
3. 自动导包							file--setting--editor -- general--Auto Import 
4. 设置显示行号                    file--setting--editor -- general--appearance--> "show line numbers"
5. 方法间的分隔符                  file--setting--editor -- general--appearance--> "show method separators"
6. 设置忽略大小写提示          file--setting--editor -- general--Code Completion --> "Match case"(取消)
7. 设置文件多行显示tabs       file--setting--editor -- general-  editor tabs --> "show tab in one row"(取消)

## 安装maven

1. 下载maven https://archive.apache.org/dist/maven/maven-3/

2. 解压到本地

3. 配置MAVEN_HOME,JAVA_HOME,PATH

4. 修改MAVEN配置文件

   https://maven.aliyun.com/mvn/guide

## idea配置maven

![image-20210218152003408](C:\Users\tiany\AppData\Roaming\Typora\typora-user-images\image-20210218152003408.png)



