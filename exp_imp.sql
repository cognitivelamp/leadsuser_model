---firewall
--sudo firewall-cmd --zone=public --add-service=http --permanent
--sudo firewall-cmd --zone=public --add-port=1521/tcp
--sudo firewall-cmd --zone=public --add-port=8080/tcp
--sudo firewall-cmd --zone=public --add-port=8081/tcp
--sudo firewall-cmd --reload
--Set secure Linux to permissive by editing the "/etc/selinux/config" file, making sure the SELINUX flag is set as follows.
--SELINUX=permissive

---Once the change is complete, restart the server or run the following command.

--# setenforce Permissive

---operating system
--The "/etc/hosts" file must contain a fully qualified name for the server.
--For example.
--127.0.0.1       localhost localhost.localdomain localhost4 localhost4.localdomain4
--192.168.56.107  ol8-23.localdomain  ol8-23

--Set the correct hostname in the "/etc/hostname" file.
--ol8-23.localdomain

---oracle
---# dnf install -y oracle-database-preinstall-21c
--If you have the Linux firewall enabled, you will need to disable or configure it, as shown here. To disable it, do the following.

--# systemctl stop firewalld
--# systemctl disable firewalld


---create user
show con_name;
select * from v$containers;

---
alter session set container=xepdb1;

--
create user leadsuser identified by bangalore1 account unlock;

--
drop user leadsuser cascade;

---
grant all privileges to leadsuser;
GRANT CREATE SESSION to leadsuser;
GRANT CREATE table, create VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE TRIGGER, create materialized view, create job to leadsuser;
GRANT ALTER ANY TABLE to leadsuser;
GRANT ALTER ANY PROCEDURE to leadsuser;
GRANT ALTER ANY TRIGGER to leadsuser;
GRANT DELETE ANY TABLE to leadsuser;
GRANT DROP ANY PROCEDURE to leadsuser;
GRANT DROP ANY TRIGGER to leadsuser;
GRANT DROP ANY VIEW to leadsuser;
grant drop any materialized view to leadsuser;

---
--
impdp system/TompoK123@localhost/xepdb1 full=Y remap_tablespace=tbs_perm_test_01:users REMAP_DIRECTORY='/u01/app/oracle/oradata/XE/':'/opt/oracle/oradata/XE/XEPDB1' directory=DATA_PUMP_DIR dumpfile=attendancedb20221010.dmp logfile = attendancedb20221010.log;

impdp system/TompoK123@localhost/xepdb1 full=Y remap_tablespace=tbs_perm_test_01:users REMAP_DIRECTORY='/u01/app/oracle/oradata/XE/':'/opt/oracle/oradata/XE/XEPDB1' directory=DATA_PUMP_DIR dumpfile=attendancedb20221010.dmp logfile = attendancedb20221010.log;

---leadsuser
expdp leadsuser/bangalore1@localhost:1521/xepdb1 schemas=leadsuser directory=data_pump_dir dumpfile=leadsuser20221014.dmp logfile=leadsuser20221014.log
impdp system/TompoK123@localhost/xepdb1 full=Y directory=DATA_PUMP_DIR dumpfile=leadsuser20221012.dmp logfile = leadsuser20221012.log;


---attendance
expdp system/TompoK123@localhost:1521/xepdb1 schemas=attendancedb directory=data_pump_dir dumpfile=attendancedb20221012.dmp logfile=attendancedb20221012.log
impdp system/TompoK123@localhost/xepdb1 full=Y directory=DATA_PUMP_DIR dumpfile=attendancedb20221012.dmp logfile = attendancedb20221012.log;

---example
expdp leadsuser/bangalore1@localhost:1521/xepdb1 schemas=leadsuser tables=(std_subject) directory=data_pump_dir dumpfile=leadsuser_std_subject.dmp logfile=leadsuser_std_subject.log
impdp leadsuser/bangalore1@localhost/xepdb1 tables=std_subject TABLE_EXISTS_ACTION=REPLACE directory=DATA_PUMP_DIR dumpfile=leadsuser20221012.dmp logfile = leadsuser_std_subject.log;

---exporting two schemas
expdp system/TompoK123@localhost:1521/xepdb1 schemas=leadsuser,attendancedb directory=data_pump_dir dumpfile=leadsuser20221106.dmp logfile=leadsuser20221106.log

expdp system/TompoK123@localhost:1521/xepdb1 schemas=leadsuser,attendancedb directory=data_pump_dir dumpfile=leadsuser20230127.dmp logfile=leadsuser20230127.log

impdp system/TompoK123@localhost:1521/xepdb1 full=Y directory=DATA_PUMP_DIR dumpfile=leadsuser20230303.dmp logfile = leadsuser20230303.log
--
impdp system/TompoK123@localhost:1521/freepdb1 schemas=leadsuser, attendancedb directory=DATA_PUMP_DIR dumpfile=leadsuser20241019.dmp logfile = leadsuser20241019.log
expdp system/TompoK123@localhost:1521/freepdb1 schemas=leadsuser,attendancedb directory=data_pump_dir dumpfile=leadsuser20260429.dmp logfile=leadsuser20260429.log
--
scp $DATA_PUMP_DIR/leadsuser20231126.dmp leads@192.168.1.41:/Users/leads/data_pump/
scp $DATA_PUMP_DIR/leadsuser20231201.dmp leads@192.168.1.41:/Users/leads/data_pump/

CREATE DATABASE LINK leadsuser_dblink
    CONNECT TO leadsuser IDENTIFIED BY bangalore1
USING '(DESCRIPTION=
                (ADDRESS=(PROTOCOL=TCP)(HOST=192.168.1.47)(PORT=1521))
                (CONNECT_DATA=(SERVICE_NAME=xepdb1))
            )';
/
