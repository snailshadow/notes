
-- 查询用户下所有的表
select * from user_tables t
select t.table_name,t.num_rows from all_tables  t where table_name not like '%$%' and t.NUM_ROWS!=0 order by t.NUM_ROWS 
select * from all_tables  t where table_name not like '%$%' and t.NUM_ROWS!=0 and OWNER='APP_CAMPAIGN' order by t.NUM_ROWS 


-- 结合1,2的查询结果，通过plsql-->tools-->compare User Objects 对比UAT和生产 找到变更的表

-- 1，最近新创建的表 
select * from user_objects xx where xx.created > to_date('2021-03-04 00:00:00','yyyy-mm-dd hh24:mi:ss') and xx.OBJECT_TYPE='TABLE';
select * from user_objects where OBJECT_TYPE='TABLE' ORDER BY CREATED desc

-- 2.查看最近有过DDL的非分区表
select * from user_objects xx where xx.LAST_DDL_TIME > to_date('2021-01-05 00:00:00','yyyy-mm-dd hh24:mi:ss') and xx.OBJECT_TYPE='TABLE' and xx.OBJECT_NAME not in 
(select distinct xx.OBJECT_NAME from user_objects xx where xx.OBJECT_type='TABLE PARTITION')

-- 查看每张表的大小

select tb1.CREATED,tb2.* from user_objects tb1,
(select Segment_Name, Sum(bytes) / 1024 / 1024 / 1024 "size(DB)"
  From User_Extents
 Group By Segment_Name
) tb2 where tb1.OBJECT_NAME=tb2.Segment_Name and tb1.OBJECT_TYPE='TABLE'  order by tb1.CREATED desc

--
select Sum(bytes) / 1024 / 1024 / 1024 "size(DB)" From User_Extents


-- 表的数据变化

 select aa.TABLE_NAME,aa.NUM_ROWS,bb.inserts,bb.updates,bb.deletes,bb.timestamp,bb.TRUNCATED,bb.drop_segments
  from user_tables aa left join user_tab_modifications bb
 on aa.TABLE_NAME = bb.TABLE_NAME
 where 
   aa.NUM_ROWS != 0
   and bb.PARTITION_NAME is null
   and aa.table_name not like '%$%'
   and aa.TABLE_NAME not in (select distinct xx.OBJECT_NAME from user_objects xx where xx.OBJECT_type='TABLE PARTITION')
   and aa.table_name not like '%PART_20%'
   and aa.table_name not like '%ARCH%'
   and aa.table_name not like '%HIST%' 
   and aa.table_name not like '%HISTORY%' 
   and bb.timestamp > to_date('2021-01-05 00:00:00','yyyy-mm-dd hh24:mi:ss')
 order by aa.table_name,bb.timestamp desc
 
 
-- 查看所有schema和table
select t.owner||'.'||t.table_name as schematable, t.num_rows
  from all_tables t
 where owner not in ('SYS', 'SYSTEM')
   and table_name not like '%$%'
   --   and t.NUM_ROWS != 0
 order by t.OWNER, t.NUM_ROWS
 
 -- 查询DBA JOB运行情况
 SELECT * FROM dba_scheduler_job_run_details WHERE job_name LIKE 'gather*';

-- 查看参数
select * from parameters;

-- 查看ETL job运行情况
select *
from owner_hub.v_etl_remote_data_status a
/*join owner_hub.v_etl_remote_dataset_settings b
on b.process_group=a.process_group*/ 


-- 查看当前运行的sql
SET LINESIZE 200 PAGESIZE 1000 LONG 10000 TAB OFF;
COLUMN PID_SID_SN FORMAT A17 HEAD "PID,SID,SERIAL#";
COLUMN USERINFO FORMAT A30;
COLUMN EVENT FORMAT A20 WORD_WRAP;
COLUMN SQL_TEXT FORMAT A45 WORD_WRAP;
SELECT ps.spid || ',' || vs.sid || ',' || vs.serial# AS pid_sid_sn,
       'DB_USER: ' || vs.username || 
       DECODE(vs.osuser, NULL, NULL, chr(10) || 'OS_USER: ' || vs.osuser) ||
       chr(10) || 'MACHINE: ' || vs.machine || 
       chr(10) || 'PROGRAM: ' || 
          SUBSTR(vs.program, 1, DECODE(instr(vs.program, ' '), 0, 1000, INSTR(vs.program, ' '))) ||
       chr(10) || 'RUNNING: ' || 
          (CASE WHEN vs.last_call_et < 60        THEN vs.last_call_et || 's'
                WHEN vs.last_call_et < 3600      THEN ROUND(vs.last_call_et / 60, 1) || 'm'
                WHEN vs.last_call_et < 3600 * 24 THEN ROUND(vs.last_call_et / 3600, 1) || 'h'
                ELSE ROUND(vs.last_call_et / 3600 / 24, 1) || 'd'
           END) AS userinfo,
       vs.event,
       (SELECT 'SQL_ID: ' || sql_id || chr(10) || 'PLAN_HASH_VALUE: ' || plan_hash_value || chr(10) || 
               REPLACE(REPLACE(sql_text, chr(10), ' '), chr(13), ' ')
          FROM v$sql
         WHERE address = vs.sql_address
           AND hash_value = vs.sql_hash_value
           AND child_number = vs.sql_child_number) AS sql_text
  FROM v$session vs, v$process ps
 WHERE vs.status = 'ACTIVE'
   AND vs.username IS NOT NULL
   AND vs.sid NOT IN (SELECT sid FROM v$mystat WHERE rownum = 1)
   AND vs.paddr = ps.addr
 ORDER BY vs.username
/


-- 查看SQL的执行计划
select * from table(dbms_xplan.display_cursor('sqlid'));

配置表
CIE_INTM_ATTRIBUTE
CIE_INTM_SERVICE
CIE_INTM_SERVICE_SUBJECT
CIE_INTM_SIGNATUREITEM
CI_CHANNEL
CI_RESPONSE_CHANNEL_RESPONSE
CI_RESPONSE

表测试
select t1.*
  from user_tab_modifications t1 where t1.TABLE_NAME like 'collintest001'
select * from user_tables where TABLE_NAME='collintest001'


--收集统计信息
begin
  DBMS_STATS.GATHER_TABLE_STATS(ownname       => 'DM_CAMPAIGN',
                                tabname       => 'DCT_WECHAT_CLIENT',
                                no_invalidate => FALSE);
end;


begin
  dbms_stats.gather_schema_stats(ownname          => 'DM_CAMPAIGN',
                                 options          => 'GATHER AUTO',
                                 estimate_percent => dbms_stats.auto_sample_size,
                                 method_opt       => 'for all columns size repeat',
                                 degree           => 15);
end;

-- 查看表空间使用率

Select Tablespace_Name,
       Sum_m,
       Max_m,
       Count_Blocks Free_Blk_Cnt,
       Sum_Free_m,
       To_Char(100 * Sum_Free_m / Sum_m, '99.99') || '%' As Pct_Free
  From (Select Tablespace_Name, Sum(Bytes) / 1024 / 1024 As Sum_m
          From Dba_Data_Files
         Group By Tablespace_Name)
  Left Join (Select Tablespace_Name As Fs_Ts_Name,
                    Max(Bytes) / 1024 / 1024 As Max_m,
                    Count(Blocks) As Count_Blocks,
                    Sum(Bytes / 1024 / 1024) As Sum_Free_m
               From Dba_Free_Space
              Group By Tablespace_Name) On Tablespace_Name = Fs_Ts_Name;

