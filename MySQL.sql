-- --------------------------------------------------------
-- Хост:                         127.0.0.1
-- Версия сервера:               5.5.23 - MySQL Community Server (GPL)
-- ОС Сервера:                   Win64
-- HeidiSQL Версия:              9.1.0.4867
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Дамп структуры для таблица things.action_type
CREATE TABLE IF NOT EXISTS `action_type` (
  `action_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `action_type_name` varchar(100) DEFAULT NULL,
  `icon_code` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`action_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.action_type: ~2 rows (приблизительно)
DELETE FROM `action_type`;
/*!40000 ALTER TABLE `action_type` DISABLE KEYS */;
INSERT INTO `action_type` (`action_type_id`, `action_type_name`, `icon_code`) VALUES
	(1, 'Измерительное устройство', 'TACHOMETER'),
	(2, 'Исполнительное устройство', 'AUTOMATION');
/*!40000 ALTER TABLE `action_type` ENABLE KEYS */;


-- Дамп структуры для функция things.fIsLeafNameExists
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `fIsLeafNameExists`(eUserLog varchar(50)
,eLeafNewName varchar(30)
) RETURNS int(11)
begin
return(
select count(*)
from user_devices_tree udt
join users u on u.user_id=udt.user_id
where u.user_log = eUserLog
and udt.leaf_name = eLeafNewName
);
end//
DELIMITER ;


-- Дамп структуры для функция things.f_do_time_marks
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_do_time_marks`(
eUserDeviceId int
,eMinDate datetime
,ePeriodCode varchar(50)
) RETURNS varchar(1000) CHARSET utf8
begin
declare i_mark_min_date datetime;
declare i_mark_max_date datetime;
declare iMaxDate datetime;
declare iDateMarks varchar(1000);

select max(udm.measure_date) into iMaxDate
from user_device_measures udm
where udm.user_device_id = eUserDeviceId;

if (ePeriodCode = 'минута') then
set i_mark_min_date = eMinDate;
set i_mark_max_date = iMaxDate;
end if;


if (ePeriodCode = 'час') then
set i_mark_min_date = timestampadd(minute,-1,CONVERT(DATE_FORMAT(eMinDate,'%Y-%m-%d-%H:%i:00'),DATETIME));
set i_mark_max_date = timestampadd(minute,1,CONVERT(DATE_FORMAT(eMaxDate,'%Y-%m-%d-%H:%i:00'),DATETIME));

end if;

if (ePeriodCode = 'день') then
set i_mark_min_date = timestampadd(hour,-1,CONVERT(DATE_FORMAT(eMinDate,'%Y-%m-%d-%H:00:00'),DATETIME));
set i_mark_max_date = timestampadd(hour,1,CONVERT(DATE_FORMAT(eMaxDate,'%Y-%m-%d-%H:00:00'),DATETIME));
end if;

if (ePeriodCode = 'неделя') then
set i_mark_min_date = timestampadd(day,-1,CONVERT(DATE_FORMAT(eMinDate,'%Y-%m-%d-00:00:00'),DATETIME));
set i_mark_max_date = timestampadd(day,1,CONVERT(DATE_FORMAT(eMaxDate,'%Y-%m-%d-00:00:00'),DATETIME));
end if;

if (ePeriodCode = 'месяц') then
set i_mark_min_date = timestampadd(day,-1,CONVERT(DATE_FORMAT(eMinDate,'%Y-%m-%d-00:00:00'),DATETIME));
set i_mark_max_date = timestampadd(day,1,CONVERT(DATE_FORMAT(eMaxDate,'%Y-%m-%d-00:00:00'),DATETIME));
end if;

if (ePeriodCode = 'год') then
set i_mark_min_date = timestampadd(day,-1,CONVERT(DATE_FORMAT(eMinDate,'%Y-%m-%d-00:00:00'),DATETIME));
set i_mark_max_date = timestampadd(day,1,CONVERT(DATE_FORMAT(eMaxDate,'%Y-%m-%d-00:00:00'),DATETIME));
end if;

return iDateMarks;
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_button_data
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_button_data`(`eTreeId` int) RETURNS varchar(1000) CHARSET utf8
begin

return(
select concat(udt.leaf_id,'/'
,ifnull(udt.user_device_id,0),'/'
,usr.user_log,'/'
,ifnull(aty.icon_code,'FOLDER'),'/'
,udt.leaf_name,'/'
)
from user_devices_tree udt
join users usr on usr.user_id=udt.user_id
left join user_device ud on ud.user_device_id=udt.user_device_id
left join action_type aty on aty.action_type_id=ud.action_type_id
where udt.user_devices_tree_id=eTreeId
);

end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_closest_period
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_closest_period`(`eUserDeviceId` int
, `ePerCode` varchar(50)
) RETURNS varchar(1000) CHARSET utf8
begin
declare i_max_date datetime;
declare i_min_date datetime;
declare i_period_code varchar(50);
declare i_period_next int default 0;
declare i_period_curr int;

select max(udm.measure_date) into i_max_date
from user_device_measures udm
where udm.user_device_id=eUserDeviceId;

set i_min_date = f_get_graph_min_date(eUserDeviceId,ePerCode);

if (i_min_date is null) then

select grp.period_id into i_period_curr
from graph_period grp
where grp.period_code=ePerCode;

  WHILE i_period_next <= 6 DO
  
    SELECT min(g.period_id) into i_period_next
	 FROM graph_period g 
	 WHERE g.period_id>i_period_curr;
	 
	 if (i_period_next is null) then
		   set i_period_next = 7;
	 else
		   set i_period_code = f_get_period_code_by_id(i_period_next);
	      set i_min_date = f_get_graph_min_date(eUserDeviceId,i_period_code);
	      if (i_min_date is not null) then
	      set i_period_next = 7;
	      else
	      set i_period_curr = i_period_next;
			end if;
	 end if;

  END WHILE;
else
	set i_period_code = ePerCode;
end if;

return i_period_code;
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_date_marks
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_date_marks`(`eUserDeviceId` int
, `eMinDate` datetime
, `ePeriodCode` varchar(50)
, `eCountMarks` int
) RETURNS varchar(1000) CHARSET utf8
begin
declare i_max_date datetime;
declare i_count_marks int;
declare i_mark_list varchar(1000);
declare k int default 0;
declare i_interval int;
declare i_date_mark datetime;
declare ix int;

select max(udm.measure_date) into i_max_date
from user_device_measures udm
where udm.user_device_id=eUserDeviceId;

set ix = 0;

if (ePeriodCode = 'минута') then

	set i_interval = ceil(60/eCountMarks);
	
end if;



set i_date_mark = eMinDate;
set i_mark_list = concat(eMinDate,'#',ix);

while (i_date_mark < i_max_date)  do
	set i_date_mark = i_date_mark + interval i_interval second;
	set ix = ix + i_interval;
	set i_mark_list = concat(i_mark_list,'/',concat(i_date_mark,'#',ix));
	set k = k + 1;
	if (k>100) then
	set i_date_mark = eMinDate;
	end if;
end while;

set i_mark_list = concat(i_mark_list,'/');

return i_mark_list;
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_device_data
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_device_data`(`eUserDeviceId` int
) RETURNS varchar(1000) CHARSET utf8
begin
return(
select concat(d.device_name,'/'
,aty.action_type_name,'/'
)
from user_device ud
join action_type aty on aty.action_type_id=ud.action_type_id
where ud.user_device_id=eUserDeviceId
);
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_device_name
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_device_name`(`eLeafId` int, `eUserLog` varchar(100)) RETURNS varchar(1000) CHARSET utf8
begin

return (
select concat(ifnull(aty.icon_code,'FOLDER'),'/'
,udt.leaf_name,'/'
)
from user_devices_tree udt
join users usr on usr.user_id=udt.user_id
left join user_device ud on ud.user_device_id=udt.user_device_id
left join action_type aty on aty.action_type_id=ud.action_type_id
where udt.leaf_id=eLeafId
and usr.user_log=eUserLog
);

end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_graph_max_date
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_graph_max_date`(eUserDeviceId int) RETURNS datetime
begin
return(
select max(udm.measure_date)
from user_device_measures udm
where udm.user_device_id=eUserDeviceId
);
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_graph_min_date
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_graph_min_date`(`eUserDeviceId` int
, `ePeriodCode` varchar(50)
) RETURNS datetime
begin
declare i_pmin_date datetime;
declare i_max_date datetime;
declare i_min_date datetime;

select max(udm.measure_date) into i_max_date
from user_device_measures udm
where udm.user_device_id=eUserDeviceId;

if (ePeriodCode = 'минута') then
	select max(udm.measure_date) - interval 1 minute into i_pmin_date
	from user_device_measures udm
	where udm.user_device_id=eUserDeviceId;
end if;

if (ePeriodCode = 'час') then
	select max(udm.measure_date) - interval 1 hour into i_pmin_date
	from user_device_measures udm
	where udm.user_device_id=eUserDeviceId;
end if;

if (ePeriodCode = 'день') then
	select max(udm.measure_date) - interval 1 day into i_pmin_date
	from user_device_measures udm
	where udm.user_device_id=eUserDeviceId;
end if;

if (ePeriodCode = 'неделя') then
	select max(udm.measure_date) - interval 1 week into i_pmin_date
	from user_device_measures udm
	where udm.user_device_id=eUserDeviceId;
end if;

if (ePeriodCode = 'месяц') then
	select max(udm.measure_date) - interval 1 month into i_pmin_date
	from user_device_measures udm
	where udm.user_device_id=eUserDeviceId;
end if;

if (ePeriodCode = 'год') then
	select max(udm.measure_date) - interval 1 year into i_pmin_date
	from user_device_measures udm
	where udm.user_device_id=eUserDeviceId;
end if;

select min(udm.measure_date) into i_min_date
from user_device_measures udm
where udm.user_device_id=eUserDeviceId
and udm.measure_date>i_pmin_date
and udm.measure_date<i_max_date;

return i_min_date;

end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_graph_min_date_mark
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_graph_min_date_mark`(eUserDeviceId int
,ePeriodCode varchar(50)
) RETURNS datetime
begin

declare MinValDate datetime;
declare i_min_date_mark datetime;

set MinValDate = f_get_graph_min_date(eUserDeviceId,ePeriodCode);

if (ePeriodCode = 'минута') then
	
	set i_min_date_mark = CONVERT(DATE_FORMAT(MinValDate,'%Y-%m-%d-%H:%i:00'),DATETIME);
	
elseif (ePeriodCode = 'час') then
	
	set i_min_date_mark = CONVERT(DATE_FORMAT(MinValDate,'%Y-%m-%d-%H:00:00'),DATETIME);

elseif (ePeriodCode = 'день') then
	
	set i_min_date_mark = CONVERT(DATE_FORMAT(MinValDate,'%Y-%m-%d-00:00:00'),DATETIME);
	
else 
	
	set i_min_date_mark = CONVERT(DATE_FORMAT(MinValDate,'%Y-%m-%d-00:00:00'),DATETIME);
	
end if;

return i_min_date_mark;
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_last_device_measure
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_last_device_measure`(`eUserDeviceId` int
) RETURNS varchar(1000) CHARSET utf8
begin
return(
select concat(t.device_name,'/'
,t.action_type_name,'/'
,t.device_units,'/'
,udme.measure_value,'/'
,udme.measure_date,'/'
)
from (
select ud.user_device_id
,ud.device_user_name
,aty.action_type_name
,ud.device_units
,max(ume1.user_device_measure_id) max_measure_id
from user_device ud
join action_type aty on aty.action_type_id=ud.action_type_id
join user_device_measures ume1 on ume1.user_device_id=ud.user_device_id
where ud.user_device_id=eUserDeviceId
and ume1.measure_date = (
select max(ume.measure_date)
from user_device_measures ume
where ume.user_device_id=eUserDeviceId
)
group by ud.user_device_id
,ud.device_user_name
,aty.action_type_name
,ud.device_units
) t
join user_device_measures udme on udme.user_device_measure_id=t.max_measure_id
);
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_leaf_name
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_leaf_name`(`eLeafId` int, `eUserLog` varchar(50)) RETURNS varchar(50) CHARSET utf8
begin
return(
select udt.leaf_name
from user_devices_tree udt
join users usr on usr.user_id=udt.user_id
where udt.leaf_id=eLeafId
and usr.user_log=eUserLog
);
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_loginbymail
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_loginbymail`(e_MailVal varchar(50)) RETURNS varchar(50) CHARSET utf8
begin

return (select ifnull((select u.user_log
from users u
where u.user_mail=e_MailVal),''));

end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_period_code_by_id
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_period_code_by_id`(
ePeriodId int
) RETURNS varchar(50) CHARSET utf8
begin
return(
select g.period_code
from graph_period g
where g.period_id=ePeriodId
);
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_unit_sym
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_unit_sym`(`eUserDeviceId` int) RETURNS varchar(50) CHARSET utf8
begin
return(
select ud.device_units
from user_device ud
where ud.user_device_id=eUserDeviceId
);
end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_user_device
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_user_device`(`eLeafId` int
, `eUserLog` varchar(100)
) RETURNS varchar(1000) CHARSET utf8
begin

return (
select concat(udt.user_device_id,'/'
,aty.action_type_name,'/'
,udt.leaf_name,'/')
from user_devices_tree udt
join users usr on usr.user_id=udt.user_id
left join user_device ud on ud.user_device_id=udt.user_device_id
left join action_type aty on aty.action_type_id=ud.action_type_id
where udt.leaf_id=eLeafId
and usr.user_log=eUserLog
);

end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_user_password
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_user_password`(eUserLog varchar(50)) RETURNS varchar(150) CHARSET utf8
begin
return(
select u.user_pass
from users u
where u.user_log = eUserLog
);
end//
DELIMITER ;


-- Дамп структуры для функция things.f_is_user_exists
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_is_user_exists`(eUserLog varchar(50),ePassWord varchar(50)) RETURNS int(11)
begin
declare i_cnt_users int;
declare i_is_exists int;

select count(*) into i_cnt_users
from users u
where u.user_log = eUserLog
and u.user_pass = ePassWord;

if (i_cnt_users > 0) then
set i_is_exists = 1;
else
set i_is_exists = 0;
end if;

return i_is_exists;
end//
DELIMITER ;


-- Дамп структуры для функция things.f_make_date_marks
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_make_date_marks`(`eUserDeviceId` int
, `ePeriodCode` varchar(50)
, `eCountMarks` int
) RETURNS varchar(1000) CHARSET utf8
begin

declare i_min_date datetime;
declare i_max_date datetime;
declare i_min_mark_int int;
declare i_max_mark_int int;
declare i_min_mark_date datetime;
declare i_max_mark_date datetime;
declare i_interval_int int;
declare i_date_mark datetime;
declare k int default 0;
declare ix int;
declare i_mark_list varchar(1000);

set i_min_date = f_get_graph_min_date(eUserDeviceId,ePeriodCode);


select max(udm.measure_date) into i_max_date
from user_device_measures udm
where udm.user_device_id=eUserDeviceId;

call p_get_int_bounds_for_date(i_min_date,i_max_date
,eCountMarks,ePeriodCode
,i_min_mark_int,i_max_mark_int
,i_min_mark_date,i_max_mark_date,i_interval_int);


set ix = i_min_mark_int;
set i_date_mark = i_min_mark_date;
set i_mark_list = concat(i_min_mark_date,'#',ix);

while (k < eCountMarks)  do
	set i_date_mark = i_date_mark + interval i_interval_int second;
	set ix = ix + i_interval_int;
	set i_mark_list = concat(i_mark_list,'/',concat(i_date_mark,'#',ix));
	set k = k + 1;
end while;

set i_mark_list = concat(i_mark_list,'/');

return i_mark_list;
end//
DELIMITER ;


-- Дамп структуры для функция things.f_user_device_insert
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_user_device_insert`(`eDeviceName` varchar(30)
, `eUserId` int
, `eUserLog` varchar(50)
, `eActionTypeId` int
, `eMqttServerName` varchar(30)
) RETURNS int(11)
begin
declare i_server_id int;
declare i_user_device_id int;

select ms.server_id into i_server_id
from mqtt_servers ms
where concat(concat(ms.server_ip,':'),ms.server_port)=eMqttServerName;

insert into user_device(
user_id
,device_user_name
,user_device_date_from
,action_type_id
,mqqt_server_id
,device_units
,unit_id
,factor_id
,description
,user_device_measure_period
)
values(
eUserId
,eDeviceName
,sysdate()
,eActionTypeId
,i_server_id
,'Ед'
,96
,64
,eDeviceName
,'не задано'
);

select LAST_INSERT_ID() into i_user_device_id;

update user_device ud
set ud.mqtt_topic_write=concat(concat(concat(eUserLog,'/'),i_user_device_id),'/W/')
,ud.mqtt_topic_read=concat(concat(concat(eUserLog,'/'),i_user_device_id),'/R/')
where ud.user_device_id=i_user_device_id;

return i_user_device_id;

end//
DELIMITER ;


-- Дамп структуры для таблица things.graph_period
CREATE TABLE IF NOT EXISTS `graph_period` (
  `period_id` int(11) NOT NULL AUTO_INCREMENT,
  `period_code` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`period_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.graph_period: ~6 rows (приблизительно)
DELETE FROM `graph_period`;
/*!40000 ALTER TABLE `graph_period` DISABLE KEYS */;
INSERT INTO `graph_period` (`period_id`, `period_code`) VALUES
	(1, 'минута'),
	(2, 'час'),
	(3, 'день'),
	(4, 'неделя'),
	(5, 'месяц'),
	(6, 'год');
/*!40000 ALTER TABLE `graph_period` ENABLE KEYS */;


-- Дамп структуры для таблица things.mqtt_servers
CREATE TABLE IF NOT EXISTS `mqtt_servers` (
  `server_id` int(11) NOT NULL AUTO_INCREMENT,
  `server_ip` varchar(20) DEFAULT NULL,
  `server_port` varchar(8) DEFAULT NULL,
  `is_busy` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`server_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.mqtt_servers: ~3 rows (приблизительно)
DELETE FROM `mqtt_servers`;
/*!40000 ALTER TABLE `mqtt_servers` DISABLE KEYS */;
INSERT INTO `mqtt_servers` (`server_id`, `server_ip`, `server_port`, `is_busy`, `name`) VALUES
	(1, '192.168.1.64', '1883', 0, 'HOME'),
	(2, '172.16.98.95', '1883', 0, 'NOTEBOOK'),
	(3, 'localhost', '1883', 0, 'LOCALHOST');
/*!40000 ALTER TABLE `mqtt_servers` ENABLE KEYS */;


-- Дамп структуры для процедура things.p_add_subfolder
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_add_subfolder`(IN `eParentLeafId` int
, IN `eFolderName` varchar(30)
, IN `eUserLog` varchar(50)
, OUT `oTreeId` int
, OUT `oNewLeafId` int 
)
begin
declare i_user_id int;
declare i_leaf_id int;

select u.user_id
,max(udt.leaf_id) + 1
into i_user_id
,i_leaf_id
from user_devices_tree udt
join users u on u.user_id = udt.user_id
where u.user_log = eUserLog
group by u.user_id;

insert into user_devices_tree(
leaf_id
,parent_leaf_id
,user_device_id
,leaf_name
,user_id
)
values(
i_leaf_id
,eParentLeafId
,null
,eFolderName
,i_user_id
);

select LAST_INSERT_ID() into oTreeId;
set oNewLeafId = i_leaf_id;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_add_user_device
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_add_user_device`(
eParentLeafId int
,eDeviceName varchar(30)
,eUserLog varchar(50)
,eActionTypeName varchar(100)
,eMqttServerName varchar(30)
,out oTreeId int
,out oNewLeafId int
,out oIconCode varchar(100)
,out oUserDeviceId int
)
begin
declare i_action_type_id int;
declare i_user_id int;
declare i_leaf_id int;
declare i_user_device_id int;

select aty.action_type_id
,aty.icon_code
into i_action_type_id
,oIconCode
from action_type aty
where aty.action_type_name=eActionTypeName;

select u.user_id
,max(udt.leaf_id) + 1
into i_user_id
,i_leaf_id
from user_devices_tree udt
join users u on u.user_id = udt.user_id
where u.user_log = eUserLog
group by u.user_id;

set i_user_device_id = f_user_device_insert(
eDeviceName
,i_user_id
,eUserLog
,i_action_type_id
,eMqttServerName
);

insert into user_devices_tree(
leaf_id
,parent_leaf_id
,user_device_id
,leaf_name
,user_id
)
values(
i_leaf_id
,eParentLeafId
,i_user_device_id
,eDeviceName
,i_user_id
);

select LAST_INSERT_ID() into oTreeId;
set oNewLeafId = i_leaf_id;
set oUserDeviceId = i_user_device_id;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_delete_actuator_state
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_delete_actuator_state`(
eUserDeviceId int
,eActuatorCode varchar(20)
)
begin

delete from user_actuator_state
where user_device_id = eUserDeviceId
and actuator_message_code = eActuatorCode;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_delete_tree_leaf
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_delete_tree_leaf`(
eUserLog varchar(50)
,eLeafId int
)
begin
declare i_tree_id int;

select udt.user_devices_tree_id
into i_tree_id
from user_devices_tree udt
join users u on u.user_id=udt.user_id
where u.user_log = eUserLog
and udt.leaf_id = eLeafId;

delete from user_devices_tree
where user_devices_tree_id = i_tree_id;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_delete_user_device
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_delete_user_device`(IN `eUserLog` varchar(50)
, IN `eLeafId` int
)
begin

declare i_tree_id int;
declare i_user_device_id int;

select udt.user_devices_tree_id
,udt.user_device_id
into i_tree_id
,i_user_device_id
from user_devices_tree udt
join users u on u.user_id=udt.user_id
where u.user_log = eUserLog
and udt.leaf_id = eLeafId;

delete from user_devices_tree
where user_devices_tree_id = i_tree_id;

delete from user_device_measures
where user_device_id = i_user_device_id;

delete from user_device
where user_device_id = i_user_device_id;


end//
DELIMITER ;


-- Дамп структуры для процедура things.p_detector_params_update
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_detector_params_update`(
eUserDeviceId int
,ePeriodValue varchar(100)
)
begin

update user_device ud
set ud.user_device_measure_period = ePeriodValue
where ud.user_device_id = eUserDeviceId;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_detector_units_update
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_detector_units_update`(
eUserDeviceId int
,eUnitTextValue varchar(255)
,eFactorTextValue varchar(100)
)
begin
declare i_factor_id int;
declare i_unit_id int;
declare i_factor_value varchar(50);
declare i_unit_symbol varchar(50);
declare i_text_unit varchar(125);

select uf.factor_id 
,uf.factor_value
into i_factor_id
,i_factor_value
from unit_factor uf
where uf.factor_value=eFactorTextValue;

select un.unit_id
,un.unit_symbol 
into  i_unit_id
,i_unit_symbol
from unit un
where concat(un.unit_name,concat(' : ',un.unit_symbol)) = eUnitTextValue;

if (i_factor_value != '1') then
	set i_text_unit = concat(i_unit_symbol,concat(' x ',i_factor_value));
else 
	set i_text_unit = i_unit_symbol;
end if;

update user_device ud
set ud.unit_id = i_unit_id
,ud.factor_id = i_factor_id
,ud.device_units = i_text_unit
where ud.user_device_id = eUserDeviceId;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_device_description_update
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_device_description_update`(
eUserDeviceId int
,eDescriptionValue varchar(255)
)
begin

update user_device ud
set ud.description = eDescriptionValue
where ud.user_device_id = eUserDeviceId;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_device_measure_period
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_device_measure_period`(
eUserDeviceId int
,ePeriodValue varchar(100)
)
begin

update user_device ud
set ud.user_device_measure_period = ePeriodValue
where ud.user_device_id = eUserDeviceId;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_get_int_bounds_for_date
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_get_int_bounds_for_date`(IN `eMinValDate` datetime
, IN `eMaxValDate` datetime
, IN `eCountMarks` int
, IN `PeriodCode` varchar(50)
, OUT `eMinValIntMark` int
, OUT `eMaxValIntMark` int
, OUT `eMinValDateMark` datetime
, OUT `eMaxValDateMark` datetime
, OUT `eDelta` int
)
begin
declare i_min_date_mark datetime;
declare i_max_date_mark datetime;
declare i_min_val_int_mark int;
declare i_max_val_int_mark int;

if (PeriodCode = 'минута') then
	
	set i_min_date_mark = CONVERT(DATE_FORMAT(eMinValDate,'%Y-%m-%d-%H:%i:00'),DATETIME);
	set i_max_date_mark = CONVERT(DATE_FORMAT(eMaxValDate + interval 1 minute,'%Y-%m-%d-%H:%i:00'),DATETIME);
	
	set i_min_val_int_mark = 0;
	set eMinValDateMark = i_min_date_mark;

	set i_max_val_int_mark = TIMESTAMPDIFF(second,i_min_date_mark,i_max_date_mark);

	call p_get_int_bounds_for_double(i_min_val_int_mark,i_max_val_int_mark,eCountMarks,1,eMinValIntMark,eMaxValIntMark,eDelta);
	
	set eMaxValDateMark = eMinValDateMark + interval eMaxValIntMark second;
	
elseif (PeriodCode = 'час') then
	
	set i_min_date_mark = CONVERT(DATE_FORMAT(eMinValDate,'%Y-%m-%d-%H:00:00'),DATETIME);
	set i_max_date_mark = CONVERT(DATE_FORMAT(eMaxValDate + interval 1 hour,'%Y-%m-%d-%H:00:00'),DATETIME);

	set i_min_val_int_mark = 0;
	set eMinValDateMark = i_min_date_mark;

	set i_max_val_int_mark = TIMESTAMPDIFF(second,i_min_date_mark,i_max_date_mark);

	call p_get_int_bounds_for_double(i_min_val_int_mark,i_max_val_int_mark,eCountMarks,60,eMinValIntMark,eMaxValIntMark,eDelta);
	
	set eMaxValDateMark = eMinValDateMark + interval eMaxValIntMark second;

elseif (PeriodCode = 'день') then
	
	set i_min_date_mark = CONVERT(DATE_FORMAT(eMinValDate,'%Y-%m-%d-00:00:00'),DATETIME);
	set i_max_date_mark = CONVERT(DATE_FORMAT(eMaxValDate + interval 1 day,'%Y-%m-%d-00:00:00'),DATETIME);

	set i_min_val_int_mark = 0;
	set eMinValDateMark = i_min_date_mark;

	set i_max_val_int_mark = TIMESTAMPDIFF(second,i_min_date_mark,i_max_date_mark);

	call p_get_int_bounds_for_double(i_min_val_int_mark,i_max_val_int_mark,eCountMarks,3600,eMinValIntMark,eMaxValIntMark,eDelta);
	
	set eMaxValDateMark = eMinValDateMark + interval eMaxValIntMark second;
	
else 
	
	set i_min_date_mark = CONVERT(DATE_FORMAT(eMinValDate,'%Y-%m-%d-00:00:00'),DATETIME);
	set i_max_date_mark = CONVERT(DATE_FORMAT(eMaxValDate + interval 1 day,'%Y-%m-%d-00:00:00'),DATETIME);

	set i_min_val_int_mark = 0;
	set eMinValDateMark = i_min_date_mark;

	set i_max_val_int_mark = TIMESTAMPDIFF(second,i_min_date_mark,i_max_date_mark);

	call p_get_int_bounds_for_double(i_min_val_int_mark,i_max_val_int_mark,eCountMarks,86400,eMinValIntMark,eMaxValIntMark,eDelta);
	
	set eMaxValDateMark = eMinValDateMark + interval eMaxValIntMark second;
	
end if;



end//
DELIMITER ;


-- Дамп структуры для процедура things.p_get_int_bounds_for_double
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_get_int_bounds_for_double`(IN `eMinValFloor` INT, IN `eMaxValCeil` INT, IN `eCountMarks` int
, IN `eK` INT, OUT `eMinValInt` int
, OUT `eMaxValInt` int
, OUT `eDelta` INT)
begin
declare i_mi_bound int;
declare i_ma_bound int;
declare i_mod int;
declare k int default 0;
declare i_delta int;

set i_mi_bound = eMinValFloor;
set i_ma_bound = eMaxValCeil;

set i_mod = (i_ma_bound-i_mi_bound)%eCountMarks;

while (i_mod != 0) do
	set k = k + 1;
	set i_ma_bound = i_ma_bound + 1*eK;
	set i_mod = (i_ma_bound-i_mi_bound)%eCountMarks;
	if (k>100000) then
	set i_mod = 0;
	end if;
end while;

set eDelta = (i_ma_bound - i_mi_bound)/eCountMarks;

set eMinValInt = i_mi_bound;
set eMaxValInt = i_ma_bound;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_get_user_device_perfs
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_get_user_device_perfs`(
in eUserDeviceId int
,out eUserDeviceName varchar(100)
,out eUserDeviceMode varchar(100)
,out eUserDeviceMeasurePeriod varchar(100)
,out eUserDeviceDateFrom datetime
)
begin

select ud.device_user_name
,ud.user_device_mode
,ud.user_device_measure_period
,ud.user_device_date_from
into
eUserDeviceName
,eUserDeviceMode
,eUserDeviceMeasurePeriod
,eUserDeviceDateFrom
from user_device ud
where ud.user_device_id=eUserDeviceId;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_insert_actuator_state
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_insert_actuator_state`(
eUserDeviceId int
,eActuatorName varchar(30)
,eActuatorCode varchar(20)
)
begin

insert into user_actuator_state(
user_device_id
,actuator_state_name
,actuator_message_code
)
values(
eUserDeviceId
,eActuatorName
,eActuatorCode
);

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_make_date_marks
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_make_date_marks`(IN `eUserDeviceId` int
, IN `ePeriodCode` varchar(50)
, IN `eCountMarks` int
, OUT `i_mark_list` varchar(1000)
, OUT `i_delta` INT)
begin

declare i_min_date datetime;
declare i_max_date datetime;
declare i_min_mark_int int;
declare i_max_mark_int int;
declare i_min_mark_date datetime;
declare i_max_mark_date datetime;
declare i_interval_int int;
declare i_date_mark datetime;
declare k int default 0;
declare ix int;

set i_min_date = f_get_graph_min_date(eUserDeviceId,ePeriodCode);

if (i_min_date is not null) then

	select max(udm.measure_date) into i_max_date
	from user_device_measures udm
	where udm.user_device_id=eUserDeviceId;

else 

	if (ePeriodCode = 'год') then
		select now()
		,now()-interval 1 year into i_max_date,i_min_date;
	end if;
	
	if (ePeriodCode = 'месяц') then
		select now()
		,now()-interval 1 month into i_max_date,i_min_date;
	end if;
	
	if (ePeriodCode = 'неделя') then
		select now()
		,now()-interval 1 week into i_max_date,i_min_date;
	end if;
	
	if (ePeriodCode = 'день') then
		select now()
		,now()-interval 1 day into i_max_date,i_min_date;
	end if;
	
	if (ePeriodCode = 'час') then
		select now()
		,now()-interval 1 hour into i_max_date,i_min_date;
	end if;
	
	if (ePeriodCode = 'минута') then
		select now()
		,now()-interval 1 minute into i_max_date,i_min_date;
	end if;
	
	if (ePeriodCode = 'минута') then
		select now()
		,now()-interval 1 minute into i_max_date,i_min_date;
	end if;

end if;


call p_get_int_bounds_for_date(i_min_date,i_max_date
,eCountMarks,ePeriodCode
,i_min_mark_int,i_max_mark_int
,i_min_mark_date,i_max_mark_date,i_interval_int);


set i_date_mark = i_min_mark_date;
set ix = i_min_mark_int;
set i_mark_list = concat(i_min_mark_date,'#',ix);

while (k < eCountMarks)  do
	set i_date_mark = i_date_mark + interval i_interval_int second;
	set ix = ix + i_interval_int;
	set i_mark_list = concat(i_mark_list,'/',concat(i_date_mark,'#',ix));
	set k = k + 1;
end while;

set i_mark_list = concat(i_mark_list,'/');
set i_delta = i_interval_int;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_make_double_marks
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_make_double_marks`(IN `eUserDeviceId` int
, IN `ePeriodCode` varchar(50)
, IN `eCountMarks` int
, OUT `eMarkList` varchar(1000)
, OUT `iDelta` INT)
begin

declare i_min_date datetime;
declare i_max_date datetime;
declare i_min_double double(10,2);
declare i_max_double double(10,2);
declare i_min_int int;
declare i_max_int int;
declare eMinValIntMark int;
declare eMaxValIntMark int;
declare eDelta int;
declare i_int_mark int;
declare ix int;
declare i_mark_list varchar(1000);
declare k int default 0;

set i_min_date = f_get_graph_min_date(eUserDeviceId,ePeriodCode);

if (i_min_date is not null) then

	select max(udm.measure_date) into i_max_date
	from user_device_measures udm
	where udm.user_device_id=eUserDeviceId;
	
	
	select min(uu.measure_value) into i_min_double
	from user_device_measures uu
	where uu.user_device_id=eUserDeviceId
	and uu.measure_date>=i_min_date
	and uu.measure_date<=i_max_date;
	
	select max(uu.measure_value) into i_max_double
	from user_device_measures uu
	where uu.user_device_id=eUserDeviceId
	and uu.measure_date>=i_min_date
	and uu.measure_date<=i_max_date;

else 

set i_min_double = 0;
set i_max_double = 10;

end if;


set i_min_int = floor(i_min_double)-1;
set i_max_int = ceil(i_max_double)+1;

call p_get_int_bounds_for_double(i_min_int
,i_max_int
,eCountMarks
,1
,eMinValIntMark
,eMaxValIntMark
,eDelta);


set i_int_mark = eMinValIntMark;
set ix = 0;
set i_mark_list = concat(eMinValIntMark,'#',ix);

while (k < eCountMarks)  do
	set i_int_mark = i_int_mark + eDelta;
	set ix = ix + eDelta;
	set i_mark_list = concat(i_mark_list,'/',concat(i_int_mark,'#',ix));
	set k = k + 1;
end while;

set eMarkList = concat(i_mark_list,'/');
set iDelta = eDelta;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_refresh_user_tree
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_refresh_user_tree`(IN `eUserLog` varchar(50))
begin
declare i_user_id int;

select u.user_id into i_user_id
from users u
where u.user_log = eUserLog;

update user_devices_tree tin
join (

select utr.user_devices_tree_id
,utr.leaf_id
,utr.parent_leaf_id
,utr.leaf_name
,@num:=@num+1 t2_new_leaf_id
,(
select a.new_leaf_id
 from (
select @num1:=@num1+1 new_leaf_id
,udt.leaf_id old_leaf_id
from user_devices_tree udt
join (select @num1:=0) t1
where udt.user_id = i_user_id
order by udt.leaf_id
) a
where a.old_leaf_id = utr.parent_leaf_id
) new_parent_leaf_id
from user_devices_tree utr
join (select @num:=0) t2
where utr.user_id = i_user_id
order by utr.leaf_id
) tou
on tin.user_devices_tree_id=tou.user_devices_tree_id
set tin.leaf_id = tou.t2_new_leaf_id
,tin.parent_leaf_id = tou.new_parent_leaf_id
where tin.user_id = i_user_id;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_rename_leaf
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_rename_leaf`(IN `eUserLog` varchar(50)
, IN `eLeafId` int
, IN `eNewLeafName` varchar(30)
)
begin
declare i_user_devices_tree_id int;
declare i_user_device_id int;

select udt.user_devices_tree_id
,udt.user_device_id
into i_user_devices_tree_id
,i_user_device_id
from user_devices_tree udt
join users u on u.user_id=udt.user_id
where udt.leaf_id = eLeafId
and u.user_log = eUserLog;

if (i_user_device_id is not null) then
	update user_device ud
	set ud.device_user_name = eNewLeafName
	where ud.user_device_id = i_user_device_id;
end if;

update user_devices_tree udt
set udt.leaf_name = eNewLeafName
where udt.user_devices_tree_id = i_user_devices_tree_id;

end//
DELIMITER ;


-- Дамп структуры для процедура things.s_p_sensor_initial
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `s_p_sensor_initial`(IN `eUserLog` varchar(50)
, IN `eDeviceId` int
, OUT `oMqttTopicWrite` varchar(200)
, OUT `oMqttServerHost` varchar(100)
)
begin

select ud.mqtt_topic_write
,concat(ms.server_ip,concat(':',ms.server_port))
into oMqttTopicWrite
,oMqttServerHost
from user_device ud
join users u on u.user_id = ud.user_id
join mqtt_servers ms on ms.server_id=ud.mqqt_server_id
where ud.user_device_id = eDeviceId
and u.user_log = eUserLog;

end//
DELIMITER ;


-- Дамп структуры для процедура things.s_p_topic_data_log
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `s_p_topic_data_log`(IN `eDeviceId` int
, IN `eMessAge` varchar(255)
, IN `eDoubleValue` DOUBLE(10,2))
begin

insert into user_device_measures(
user_device_id
,measure_value
,measure_date
,measure_mess
)
values(
eDeviceId
,eDoubleValue
,sysdate()
,eMessAge
);

end//
DELIMITER ;


-- Дамп структуры для таблица things.unit
CREATE TABLE IF NOT EXISTS `unit` (
  `unit_id` int(11) NOT NULL AUTO_INCREMENT,
  `unit_symbol` varchar(25) DEFAULT NULL,
  `unit_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`unit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.unit: ~76 rows (приблизительно)
DELETE FROM `unit`;
/*!40000 ALTER TABLE `unit` DISABLE KEYS */;
INSERT INTO `unit` (`unit_id`, `unit_symbol`, `unit_name`) VALUES
	(2, 'м', 'метр'),
	(3, 'м2', 'квадратный метр'),
	(4, 'м3', 'кубический метр'),
	(6, 'рад', 'радиан'),
	(7, 'ср', 'стерадиан'),
	(9, 'м/с2', 'метр в секунду в квадрате'),
	(10, 'рад/с', 'радиан в секунду'),
	(11, 'рад/с2', 'радиан в секунду в квадрате'),
	(13, 'Гц', 'герц'),
	(15, 'с-1', 'секунда в минус первой степени'),
	(17, 'м-1', 'метр в минус первой степени'),
	(20, 'м3/кг', 'кубический метр на килограмм'),
	(21, 'кг/с', 'килограмм в секунду'),
	(23, 'кг ∙ м/с', 'килограмм-метр в секунду'),
	(24, 'кг ∙ м2/с', 'килограмм-метр в квадрате в секунду'),
	(25, 'кг ∙ м2', 'килограмм-метр в квадрате'),
	(26, 'Н', 'ньютон'),
	(27, 'Н ∙ м', 'ньютон-метр'),
	(28, 'Н ∙ с', 'ньютон-секунда'),
	(31, 'Вт', 'ватт'),
	(32, 'К', 'кельвин'),
	(33, 'К-1', 'кельвин в минус первой степени'),
	(34, 'К/м', 'кельвин на метр'),
	(36, 'Дж/кг', 'джоуль на килограмм'),
	(37, 'Дж/К', 'джоуль на кельвин'),
	(38, 'Дж/(кг ∙ К)', 'джоуль на килограмм-кельвин'),
	(40, 'моль', 'моль'),
	(41, 'кг/моль', 'килограмм на моль'),
	(42, 'Дж/моль', 'джоуль на моль'),
	(43, 'Дж/(моль ∙ К)', 'джоуль на моль-кельвин'),
	(44, 'м-3', 'метр в минус третьей степени'),
	(45, 'кг/м3', 'килограмм на кубический метр'),
	(46, 'моль/м3', 'моль на кубический метр'),
	(47, 'м2/(В ∙ с)', 'квадратный метр на вольт-секунду'),
	(48, 'А', 'ампер'),
	(49, 'А/м2', 'ампер на квадратный метр'),
	(50, 'Кл', 'кулон'),
	(51, 'Кл ∙ м', 'кулон-метр'),
	(52, 'Кл/м2', 'кулон на квадратный метр'),
	(53, 'В', 'вольт'),
	(54, 'В/м', 'вольт на метр'),
	(55, 'Ф', 'фарад'),
	(56, 'Ом', 'ом'),
	(57, 'Ом ∙ м', 'ом-метр'),
	(58, 'См', 'сименс'),
	(59, 'Тл', 'тесла'),
	(60, 'Вб', 'вебер'),
	(61, 'А/м', 'ампер на метр'),
	(62, 'А ∙ м2', 'ампер-квадратный метр'),
	(64, 'Гн', 'генри'),
	(66, 'Дж/м3', 'джоуль на кубический метр'),
	(68, 'вар', 'вар'),
	(69, 'Вт ∙ А', 'ватт-ампер'),
	(70, 'кд', 'кандела'),
	(71, 'лм', 'люмен'),
	(72, 'лм ∙ с', 'люмен-секунда'),
	(73, 'люкс', 'люкс'),
	(74, 'лм/м2', 'люмен на квадратный метр'),
	(75, 'кд/м2', 'кандела на квадратный метр'),
	(77, 'Па', 'паскаль'),
	(78, 'м3/с', 'кубический метр в секунду'),
	(79, 'м/с', 'метр в секунду'),
	(80, 'Вт/м2', 'ватт на квадратный метр'),
	(81, 'Па ∙ с/м3', 'паскаль-секунда на кубический метр'),
	(82, 'Н ∙ с/м', 'ньютон-секунда на метр'),
	(84, 'кг', 'килограмм'),
	(86, 'Дж', 'джоуль'),
	(87, 'с', 'секунда'),
	(89, 'Бк', 'беккерель'),
	(91, 'Гр', 'грей'),
	(92, 'Зв', 'зиверт'),
	(93, 'Кл/кг', 'кулон на килограмм'),
	(94, 'атм', 'атмосфера'),
	(95, '°С', 'градус Цельсия'),
	(96, 'Ед', 'Другая единица'),
	(97, '%', 'Процент');
/*!40000 ALTER TABLE `unit` ENABLE KEYS */;


-- Дамп структуры для таблица things.unit_factor
CREATE TABLE IF NOT EXISTS `unit_factor` (
  `factor_id` int(11) NOT NULL AUTO_INCREMENT,
  `factor_value` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`factor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.unit_factor: ~49 rows (приблизительно)
DELETE FROM `unit_factor`;
/*!40000 ALTER TABLE `unit_factor` DISABLE KEYS */;
INSERT INTO `unit_factor` (`factor_id`, `factor_value`) VALUES
	(64, '1'),
	(65, '10'),
	(66, '10e2'),
	(67, '10e3'),
	(68, '10e4'),
	(69, '10e5'),
	(70, '10e6'),
	(71, '10e7'),
	(72, '10e8'),
	(73, '10e9'),
	(74, '10e10'),
	(75, '10e11'),
	(76, '10e12'),
	(77, '10e13'),
	(78, '10e14'),
	(79, '10e15'),
	(80, '10e16'),
	(81, '10e17'),
	(82, '10e18'),
	(83, '10e19'),
	(84, '10e20'),
	(85, '10e21'),
	(86, '10e22'),
	(87, '10e23'),
	(88, '10e24'),
	(89, '10e-1'),
	(90, '10e-2'),
	(91, '10e-3'),
	(92, '10e-4'),
	(93, '10e-5'),
	(94, '10e-6'),
	(95, '10e-7'),
	(96, '10e-8'),
	(97, '10e-9'),
	(98, '10e-10'),
	(99, '10e-11'),
	(100, '10e-12'),
	(101, '10e-13'),
	(102, '10e-14'),
	(103, '10e-15'),
	(104, '10e-16'),
	(105, '10e-17'),
	(106, '10e-18'),
	(107, '10e-19'),
	(108, '10e-20'),
	(109, '10e-21'),
	(110, '10e-22'),
	(111, '10e-23'),
	(112, '10e-24');
/*!40000 ALTER TABLE `unit_factor` ENABLE KEYS */;


-- Дамп структуры для таблица things.users
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_log` varchar(50) NOT NULL,
  `user_pass` varchar(150) NOT NULL,
  `user_last_activity` datetime DEFAULT NULL,
  `user_mail` varchar(150) DEFAULT NULL,
  `user_phone` varchar(150) DEFAULT NULL,
  `user_name` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.users: ~2 rows (приблизительно)
DELETE FROM `users`;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`user_id`, `user_log`, `user_pass`, `user_last_activity`, `user_mail`, `user_phone`, `user_name`) VALUES
	(1, 'k', '7902699be42c8a8e46fbbb4501726517e86b22c56a189f7625a6da49081b2451', '2016-11-17 14:32:56', NULL, NULL, NULL),
	(2, 'Oleg', '2c624232cdd221771294dfbb310aca000a0df6ac8b66b696d90ef06fdefb64a3', '2017-01-12 18:02:48', 'akminfo@mail.ru', NULL, NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_actuator_state
CREATE TABLE IF NOT EXISTS `user_actuator_state` (
  `user_actuator_state_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_device_id` int(11) NOT NULL,
  `actuator_state_name` varchar(30) DEFAULT NULL,
  `actuator_message_code` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`user_actuator_state_id`),
  KEY `FK_user_actuator_state_user_device` (`user_device_id`),
  CONSTRAINT `FK_user_actuator_state_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_actuator_state: ~2 rows (приблизительно)
DELETE FROM `user_actuator_state`;
/*!40000 ALTER TABLE `user_actuator_state` DISABLE KEYS */;
INSERT INTO `user_actuator_state` (`user_actuator_state_id`, `user_device_id`, `actuator_state_name`, `actuator_message_code`) VALUES
	(15, 3, 'Включено', 'DeviceOn'),
	(19, 3, 'Выключено', 'DeviceOff'),
	(20, 4, 'Включено', 'On');
/*!40000 ALTER TABLE `user_actuator_state` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_actuator_state_condition
CREATE TABLE IF NOT EXISTS `user_actuator_state_condition` (
  `actuator_state_condition_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_actuator_state_id` int(11) NOT NULL DEFAULT '0',
  `left_part_expression` varchar(150) DEFAULT NULL,
  `sign_expression` varchar(2) DEFAULT NULL,
  `right_part_expression` varchar(150) DEFAULT NULL,
  `condition_num` int(11) DEFAULT NULL,
  `condition_interval` int(11) DEFAULT NULL,
  PRIMARY KEY (`actuator_state_condition_id`),
  KEY `FK_user_actuator_state_condition_user_actuator_state` (`user_actuator_state_id`),
  CONSTRAINT `FK_user_actuator_state_condition_user_actuator_state` FOREIGN KEY (`user_actuator_state_id`) REFERENCES `user_actuator_state` (`user_actuator_state_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_actuator_state_condition: ~0 rows (приблизительно)
DELETE FROM `user_actuator_state_condition`;
/*!40000 ALTER TABLE `user_actuator_state_condition` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_actuator_state_condition` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_device
CREATE TABLE IF NOT EXISTS `user_device` (
  `user_device_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `device_user_name` varchar(30) DEFAULT NULL,
  `user_device_mode` varchar(100) DEFAULT NULL,
  `user_device_measure_period` varchar(100) DEFAULT NULL,
  `user_device_date_from` datetime DEFAULT NULL,
  `action_type_id` int(11) DEFAULT NULL,
  `device_units` varchar(20) DEFAULT NULL,
  `mqtt_topic_write` varchar(200) DEFAULT NULL,
  `mqtt_topic_read` varchar(200) DEFAULT NULL,
  `mqqt_server_id` int(11) DEFAULT NULL,
  `unit_id` int(11) DEFAULT NULL,
  `factor_id` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`user_device_id`),
  KEY `USER_DEVICE_NAME_INDX` (`user_id`,`device_user_name`),
  KEY `FK_user_device_action_type` (`action_type_id`),
  KEY `FK_user_device_mqtt_servers` (`mqqt_server_id`),
  KEY `FK_user_device_users` (`unit_id`),
  KEY `FK_user_device_unit_factor` (`factor_id`),
  CONSTRAINT `FK_user_device_action_type` FOREIGN KEY (`action_type_id`) REFERENCES `action_type` (`action_type_id`),
  CONSTRAINT `FK_user_device_mqtt_servers` FOREIGN KEY (`mqqt_server_id`) REFERENCES `mqtt_servers` (`server_id`),
  CONSTRAINT `FK_user_device_unit` FOREIGN KEY (`unit_id`) REFERENCES `unit` (`unit_id`),
  CONSTRAINT `FK_user_device_unit_factor` FOREIGN KEY (`factor_id`) REFERENCES `unit_factor` (`factor_id`),
  CONSTRAINT `FK_user_device_users` FOREIGN KEY (`unit_id`) REFERENCES `unit` (`unit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_device: ~7 rows (приблизительно)
DELETE FROM `user_device`;
/*!40000 ALTER TABLE `user_device` DISABLE KEYS */;
INSERT INTO `user_device` (`user_device_id`, `user_id`, `device_user_name`, `user_device_mode`, `user_device_measure_period`, `user_device_date_from`, `action_type_id`, `device_units`, `mqtt_topic_write`, `mqtt_topic_read`, `mqqt_server_id`, `unit_id`, `factor_id`, `description`) VALUES
	(1, 1, 'UniPing RS-485', 'Однократное измерение', 'не задано', '2017-03-03 18:43:27', 1, '°С', 'k/1/W/', 'k/2/R/', 3, 96, 64, 'UniPing RS-485 xxxxx'),
	(2, 1, 'HWg-STE', 'Периодическое измерение', 'ежесекундно', '2017-02-28 18:32:52', 1, '°С x 10e2', 'k/2/W/', 'k/2/R/', 3, 95, 66, 'Это описание устройства HWg-STE. Максимальная длина 200 символов'),
	(3, 1, 'Logitech HD Webcam C270', NULL, NULL, NULL, 2, NULL, 'k/3/W/', 'k/3/R/', 3, NULL, NULL, 'Logitech HD Webcam C270 максимальная длина 200 символов'),
	(4, 1, 'Microsoft LifeCam HD-3000', NULL, NULL, NULL, 2, NULL, 'k/4/W/', 'k/4/R/', 3, NULL, NULL, NULL),
	(11, 1, 'барометр', NULL, 'не задано', '2017-05-19 13:50:38', 1, 'атм', 'k/11/W/', 'k/11/R/', 3, 94, 64, 'reger'),
	(16, 1, 'Датчик СО', NULL, 'не задано', '2017-05-19 16:31:42', 1, '%', 'k/16/W/', 'k/16/R/', 3, 97, 64, 'Датчик СО'),
	(17, 1, 'термометр-1', NULL, 'не задано', '2017-05-22 15:48:43', 1, 'Ед', 'k/17/W/', 'k/17/R/', 3, 96, 64, 'термометр-1');
/*!40000 ALTER TABLE `user_device` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_devices_tree
CREATE TABLE IF NOT EXISTS `user_devices_tree` (
  `user_devices_tree_id` int(11) NOT NULL AUTO_INCREMENT,
  `leaf_id` int(11) NOT NULL,
  `parent_leaf_id` int(11) DEFAULT NULL,
  `user_device_id` int(11) DEFAULT NULL,
  `leaf_name` varchar(30) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`user_devices_tree_id`),
  KEY `FK_user_devices_tree_user_device` (`user_device_id`),
  KEY `FK_user_devices_tree_users` (`user_id`),
  CONSTRAINT `FK_user_devices_tree_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `FK_user_devices_tree_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=147 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_devices_tree: ~14 rows (приблизительно)
DELETE FROM `user_devices_tree`;
/*!40000 ALTER TABLE `user_devices_tree` DISABLE KEYS */;
INSERT INTO `user_devices_tree` (`user_devices_tree_id`, `leaf_id`, `parent_leaf_id`, `user_device_id`, `leaf_name`, `user_id`) VALUES
	(1, 1, NULL, NULL, 'Устройства', 1),
	(5, 2, 1, NULL, 'Кухня', 1),
	(6, 3, 2, 3, 'Logitech HD Webcam C270', 1),
	(7, 4, 2, 2, 'HWg-STE', 1),
	(40, 5, 2, 4, 'Microsoft LifeCam HD-3000', 1),
	(41, 6, 2, 1, 'UniPing RS-485', 1),
	(107, 7, 1, NULL, 'Санитарный блок', 1),
	(125, 8, 7, 11, 'барометр', 1),
	(131, 9, 1, NULL, 'Гараж', 1),
	(132, 10, 9, 16, 'Датчик СО', 1),
	(133, 11, 1, NULL, 'Подсобка', 1),
	(134, 12, 1, NULL, 'Бассейн', 1),
	(135, 13, 7, 17, 'термометр-1', 1),
	(146, 1, NULL, NULL, 'Устройства', 2);
/*!40000 ALTER TABLE `user_devices_tree` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_device_measures
CREATE TABLE IF NOT EXISTS `user_device_measures` (
  `user_device_measure_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_device_id` int(11) NOT NULL,
  `measure_value` double(10,2) DEFAULT NULL,
  `measure_date` datetime DEFAULT NULL,
  `measure_mess` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`user_device_measure_id`),
  KEY `FK_user_device_measures_user_device` (`user_device_id`),
  CONSTRAINT `FK_user_device_measures_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_device_measures: ~108 rows (приблизительно)
DELETE FROM `user_device_measures`;
/*!40000 ALTER TABLE `user_device_measures` DISABLE KEYS */;
INSERT INTO `user_device_measures` (`user_device_measure_id`, `user_device_id`, `measure_value`, `measure_date`, `measure_mess`) VALUES
	(1, 2, 21.00, '2017-01-18 18:19:40', NULL),
	(2, 2, 25.00, '2017-01-19 18:20:13', NULL),
	(3, 2, 22.00, '2017-01-20 18:20:33', NULL),
	(4, 2, 27.00, '2017-01-21 18:20:49', NULL),
	(5, 2, 15.00, '2017-01-22 18:21:05', NULL),
	(6, 2, 24.00, '2017-01-23 18:21:21', NULL),
	(7, 1, 10.00, '2017-01-23 10:21:42', NULL),
	(8, 1, 7.00, '2017-01-23 12:21:54', NULL),
	(9, 1, 15.00, '2017-01-23 14:22:05', NULL),
	(10, 1, 17.00, '2017-01-23 16:22:15', NULL),
	(11, 1, 20.54, '2017-01-23 18:22:30', NULL),
	(12, 2, 34.00, '2017-01-26 19:22:47', NULL),
	(13, 2, 34.00, '2017-01-26 19:22:57', NULL),
	(14, 2, 56.00, '2017-01-26 19:23:06', NULL),
	(15, 2, 45.00, '2017-01-26 19:23:15', NULL),
	(16, 2, 34.00, '2017-01-26 19:23:23', NULL),
	(17, 2, 35.00, '2017-01-26 19:23:35', NULL),
	(18, 2, 44.21, '2017-01-26 19:23:46', NULL),
	(19, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(20, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(21, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(22, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(23, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(24, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(25, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(26, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(27, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(28, 1, 20.00, '2017-05-20 15:10:22', '20'),
	(29, 1, 25.00, '2017-05-20 15:11:58', '25'),
	(30, 1, 25.00, '2017-05-20 15:11:58', '25'),
	(31, 1, 25.00, '2017-05-20 15:11:58', '25'),
	(32, 1, 25.00, '2017-05-20 15:11:58', '25'),
	(33, 1, 25.00, '2017-05-20 15:11:58', '25'),
	(34, 1, 25.00, '2017-05-20 15:11:58', '25'),
	(35, 1, 25.00, '2017-05-20 15:11:58', '25'),
	(36, 1, 25.00, '2017-05-20 15:11:58', '25'),
	(37, 1, 25.00, '2017-05-20 15:11:58', '25'),
	(38, 1, 25.00, '2017-05-20 15:11:59', '25'),
	(39, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(40, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(41, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(42, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(43, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(44, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(45, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(46, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(47, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(48, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(49, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(50, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(51, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(52, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(53, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(54, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(55, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(56, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(57, 1, 25.00, '2017-05-20 15:14:57', '25'),
	(58, 2, 18.00, '2017-05-20 15:14:57', '18'),
	(59, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(60, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(61, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(62, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(63, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(64, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(65, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(66, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(67, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(68, 1, 25.00, '2017-05-20 15:17:36', '25'),
	(69, 1, 20.00, '2017-05-20 15:31:53', '20'),
	(70, 1, 20.00, '2017-05-20 15:31:53', '20'),
	(71, 1, 20.00, '2017-05-20 15:31:53', '20'),
	(72, 1, 20.00, '2017-05-20 15:31:53', '20'),
	(73, 1, 20.00, '2017-05-20 15:31:53', '20'),
	(74, 1, 20.00, '2017-05-20 15:31:53', '20'),
	(75, 1, 20.00, '2017-05-20 15:31:54', '20'),
	(76, 1, 20.00, '2017-05-20 15:31:54', '20'),
	(77, 1, 20.00, '2017-05-20 15:31:54', '20'),
	(78, 1, 20.00, '2017-05-20 15:31:54', '20'),
	(79, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(80, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(81, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(82, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(83, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(84, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(85, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(86, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(87, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(88, 1, 20.00, '2017-05-20 15:32:27', '20'),
	(89, 1, 11.00, '2017-05-20 19:05:13', '11'),
	(90, 2, 22.00, '2017-05-20 19:05:13', '22'),
	(91, 1, 11.00, '2017-05-20 19:05:13', '11'),
	(92, 2, 22.00, '2017-05-20 19:05:13', '22'),
	(93, 1, 11.00, '2017-05-20 19:05:13', '11'),
	(94, 2, 22.00, '2017-05-20 19:05:13', '22'),
	(95, 1, 11.00, '2017-05-20 19:05:13', '11'),
	(96, 2, 22.00, '2017-05-20 19:05:13', '22'),
	(97, 1, 11.00, '2017-05-20 19:05:13', '11'),
	(98, 2, 22.00, '2017-05-20 19:05:13', '22'),
	(99, 1, 11.00, '2017-05-20 19:05:13', '11'),
	(100, 2, 22.00, '2017-05-20 19:05:13', '22'),
	(101, 1, 11.00, '2017-05-20 19:05:13', '11'),
	(102, 2, 22.00, '2017-05-20 19:05:13', '22'),
	(103, 1, 11.00, '2017-05-20 19:05:13', '11'),
	(104, 2, 22.00, '2017-05-20 19:05:13', '22'),
	(105, 1, 11.00, '2017-05-20 19:05:13', '11'),
	(106, 2, 22.00, '2017-05-20 19:05:13', '22'),
	(107, 1, 11.00, '2017-05-20 19:05:14', '11'),
	(108, 2, 22.00, '2017-05-20 19:05:14', '22');
/*!40000 ALTER TABLE `user_device_measures` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_state_condition_vars
CREATE TABLE IF NOT EXISTS `user_state_condition_vars` (
  `state_condition_vars_id` int(11) NOT NULL,
  `actuator_state_condition_id` int(11) DEFAULT NULL,
  `var_code` varchar(20) DEFAULT NULL,
  `user_device_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`state_condition_vars_id`),
  KEY `FK_user_state_condition_vars_user_actuator_state_condition` (`actuator_state_condition_id`),
  KEY `FK_user_state_condition_vars_user_device` (`user_device_id`),
  CONSTRAINT `FK_user_state_condition_vars_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`),
  CONSTRAINT `FK_user_state_condition_vars_user_actuator_state_condition` FOREIGN KEY (`actuator_state_condition_id`) REFERENCES `user_actuator_state_condition` (`actuator_state_condition_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_state_condition_vars: ~0 rows (приблизительно)
DELETE FROM `user_state_condition_vars`;
/*!40000 ALTER TABLE `user_state_condition_vars` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_state_condition_vars` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
