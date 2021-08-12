# ORACLE

## 1 函数

### 1.1 oracle sys_context()函数

select sys_context('USERENV','CURRENT_SCHEMAID') from dual;--当前schema的id
select sys_context('USERENV','CURRENT_USER') from dual;--当前的登陆用户
select sys_context('USERENV','CURRENT_USERID') from dual;--当前登陆的用户的id
select sys_context('USERENV','DB_DOMAIN') from dual;--为数据库的域指定初始化参数
select sys_context('USERENV','DB_NAME') from dual;--数据库实例名
select sys_context('USERENV','ISDBA') from dual;--当前用户是否是以dba身份登录select sys_context('USERENV','SESSION_USER') from dual;--当前认证的数据库用户名
select sys_context('USERENV','SESSION_USERID') from dual;--当前认证的数据库用户名id
select sys_context('USERENV','SESSIONID') from dual;--当前会话id
select sys_context('USERENV','TERMINAL') from dual;--操作系统用户组
select sys_context('USERENV','IP_ADDRESS') from dual;--当前会话主机ip
select sys_context('USERENV','HOST') from dual;--当前会话主机操作系统名

## 2 不错的SQL

### 2.1 提取字符串，求时间差

```sql
SELECT MSG_ID,ERROR_DT,eventTime,ROUND (TO_NUMBER(ERROR_DT - to_date(eventTime,'yyyy-mm-dd hh24:mi:ss')) * 24 * 60 * 60) FROM 
(SELECT MSG_ID,ERROR_DT,REPLACE(REGEXP_SUBSTR(REQUEST_VARIABLES_STRING, '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'),'T',' ') eventTime
FROM APP_CAMPAIGN_CDM.CIE_RTDM_ERROR_LOG CREL
WHERE ERROR_DT > to_date('2021-08-11 00:00:00','yyyy-mm-dd hh24:mi:ss')
--AND RTDM_FLOW_NAME = 'LP_Monthlytask_Communication_FirstWave_EDGARQWI1VHAQASA'
ORDER BY ERROR_DT DESC) aa WHERE eventTime IS NOT NULL;
```

## 3 数据库管理SQL

### 3.1







