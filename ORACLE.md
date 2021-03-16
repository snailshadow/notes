# ORACLE

## 标题1

## 标题2

set serveroutpu on：使oracle能够使用自带的输出方法。例如：dbms_output.put_line(‘XX’);

### oracle sys_context()函数

select sys_context('USERENV','CURRENT_SCHEMAID') from dual;--当前schema的id
select sys_context('USERENV','CURRENT_USER') from dual;--当前的登陆用户select sys_context('USERENV','CURRENT_USERID') from dual;--当前登陆的用户的id
select sys_context('USERENV','DB_DOMAIN') from dual;--为数据库的域指定初始化参数
**select sys_context('USERENV','DB_NAME') from dual;--数据库实例名**

select sys_context('USERENV','ISDBA') from dual;--当前用户是否是以dba身份登录select sys_context('USERENV','SESSION_USER') from dual;--当前认证的数据库用户名
select sys_context('USERENV','SESSION_USERID') from dual;--当前认证的数据库用户名id
select sys_context('USERENV','SESSIONID') from dual;--当前会话id
select sys_context('USERENV','TERMINAL') from dual;--操作系统用户组
select sys_context('USERENV','IP_ADDRESS') from dual;--当前会话主机ip
select sys_context('USERENV','HOST') from dual;--当前会话主机操作系统名
原文链接：https://blog.csdn.net/kadwf123/article/details/8065673



### 动态SQL (EXECUTE IMMEDIATE)

EXECUTE IMMEDIATE 'ALTER SESSION SET WORKAREA_SIZE_POLICY = MANUAL'; 
EXECUTE IMMEDIATE 'ALTER SESSION SET SORT_AREA_SIZE = '|| v_size; -- 设置排序内存大小

EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DDL'; -- 开启session并行度
EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL QUERY';

### Oracle SET 命令总结

- set echo on        //设置运行命令是是否显示语句
- set timing on     //设置显示“已用时间：XXXX”
- set verify off       //设置是否显示替代变量被替代前后的语句
- set define off     // 开启或者禁用替代变量

### 分区表

enable row_movement

​	一般用于分区表，某一行更新时，如果更新的是分区列，并且更新后的列值不属于原来的这个分区，如果开启了这个选项，就会把这行从这个分区中delete掉，并加到更新后所属的分区。相当于一个隐式的delete+insert，但是不会触发insert/delete触发器。如果没有开启这个选项，就会在更新时报错。



### 判断一个分区表是不是分区表

如果查询结果中TABLESPACE_NAME为空，则这个表是分区表。

select * from user_tables where table_name LIKE 'CHNL%'





