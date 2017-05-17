-- --------------------------------------------------------
-- Хост:                         127.0.0.1
-- Версия сервера:               5.5.23 - MySQL Community Server (GPL)
-- ОС Сервера:                   Win32
-- HeidiSQL Версия:              9.3.0.4984
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
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_user_device_insert`(
eDeviceName varchar(30)
,eUserId int
,eUserLog varchar(50)
,eActionTypeId int
,eMqttServerName varchar(30)
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
)
values(
eUserId
,eDeviceName
,sysdate()
,eActionTypeId
,i_server_id
);

select LAST_INSERT_ID() into i_user_device_id;

update user_device ud
set ud.mqtt_topic_write=concat(concat(concat(eUserLog,'/'),i_user_device_id),'W')
,ud.mqtt_topic_read=concat(concat(concat(eUserLog,'/'),i_user_device_id),'R')
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
  PRIMARY KEY (`server_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.mqtt_servers: ~1 rows (приблизительно)
DELETE FROM `mqtt_servers`;
/*!40000 ALTER TABLE `mqtt_servers` DISABLE KEYS */;
INSERT INTO `mqtt_servers` (`server_id`, `server_ip`, `server_port`, `is_busy`) VALUES
	(1, '192.168.1.64', '8383', 0);
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
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_delete_user_device`(
eUserLog varchar(50)
,eLeafId int
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

delete from user_device
where user_device_id = i_user_device_id;

delete from user_devices_tree
where user_devices_tree_id = i_tree_id;

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


-- Дамп структуры для таблица things.users
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_log` varchar(50) NOT NULL,
  `user_pass` varchar(50) NOT NULL,
  `user_last_activity` datetime DEFAULT NULL,
  `user_mail` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.users: ~2 rows (приблизительно)
DELETE FROM `users`;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`user_id`, `user_log`, `user_pass`, `user_last_activity`, `user_mail`) VALUES
	(1, 'k', '7', '2016-11-17 14:32:56', NULL),
	(2, 'Niko', '7', '2017-01-12 18:02:48', 'akminfo@mail.ru');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;


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
  PRIMARY KEY (`user_device_id`),
  KEY `USER_DEVICE_NAME_INDX` (`user_id`,`device_user_name`),
  KEY `FK_user_device_action_type` (`action_type_id`),
  KEY `FK_user_device_mqtt_servers` (`mqqt_server_id`),
  CONSTRAINT `FK_user_device_mqtt_servers` FOREIGN KEY (`mqqt_server_id`) REFERENCES `mqtt_servers` (`server_id`),
  CONSTRAINT `FK_user_device_action_type` FOREIGN KEY (`action_type_id`) REFERENCES `action_type` (`action_type_id`),
  CONSTRAINT `FK_user_device_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_device: ~4 rows (приблизительно)
DELETE FROM `user_device`;
/*!40000 ALTER TABLE `user_device` DISABLE KEYS */;
INSERT INTO `user_device` (`user_device_id`, `user_id`, `device_user_name`, `user_device_mode`, `user_device_measure_period`, `user_device_date_from`, `action_type_id`, `device_units`, `mqtt_topic_write`, `mqtt_topic_read`, `mqqt_server_id`) VALUES
	(1, 1, 'UniPing RS-485', 'Однократное измерение', 'ежесекундно', '2017-03-03 18:43:27', 1, '°С', 'k/1W', '', 1),
	(2, 1, 'HWg-STE', 'Периодическое измерение', 'ежечасно', '2017-02-28 18:32:52', 1, '°С', 'k/2W', NULL, 1),
	(3, 1, 'Logitech HD Webcam C270', NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL),
	(4, 1, 'Microsoft LifeCam HD-3000', NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL),
	(5, 1, 'Насос', NULL, NULL, '2017-05-17 19:31:38', 2, NULL, 'k/5W', 'k/5R', 1),
	(6, 1, 'Датчик давления-1', NULL, NULL, '2017-05-17 19:33:38', 1, NULL, 'k/6W', 'k/6R', 1);
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
) ENGINE=InnoDB AUTO_INCREMENT=112 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_devices_tree: ~13 rows (приблизительно)
DELETE FROM `user_devices_tree`;
/*!40000 ALTER TABLE `user_devices_tree` DISABLE KEYS */;
INSERT INTO `user_devices_tree` (`user_devices_tree_id`, `leaf_id`, `parent_leaf_id`, `user_device_id`, `leaf_name`, `user_id`) VALUES
	(1, 1, NULL, NULL, 'Устройства', 1),
	(5, 2, 1, NULL, 'Кухня', 1),
	(6, 3, 2, 3, 'Logitech HD Webcam C270', 1),
	(7, 4, 2, 2, 'HWg-STE', 1),
	(39, 5, 1, NULL, 'Комната', 1),
	(40, 6, 5, 4, 'Microsoft LifeCam HD-3000', 1),
	(41, 7, 5, 1, 'UniPing RS-485', 1),
	(76, 8, 1, NULL, '1-я уборная', 1),
	(105, 9, 1, NULL, 'Гаражное отделение', 1),
	(106, 10, 1, NULL, 'Подсобное помещение', 1),
	(107, 11, 1, NULL, 'Санитарный блок', 1),
	(108, 12, 11, NULL, 'Ванная комната', 1),
	(109, 13, 11, NULL, 'Туалет', 1),
	(110, 14, 8, 5, 'Насос', 1),
	(111, 15, 8, 6, 'Датчик давления-1', 1);
/*!40000 ALTER TABLE `user_devices_tree` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_device_measures
CREATE TABLE IF NOT EXISTS `user_device_measures` (
  `user_device_measure_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_device_id` int(11) NOT NULL,
  `measure_value` double(10,2) DEFAULT NULL,
  `measure_date` datetime DEFAULT NULL,
  PRIMARY KEY (`user_device_measure_id`),
  KEY `FK_user_device_measures_user_device` (`user_device_id`),
  CONSTRAINT `FK_user_device_measures_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_device_measures: ~18 rows (приблизительно)
DELETE FROM `user_device_measures`;
/*!40000 ALTER TABLE `user_device_measures` DISABLE KEYS */;
INSERT INTO `user_device_measures` (`user_device_measure_id`, `user_device_id`, `measure_value`, `measure_date`) VALUES
	(1, 2, 21.00, '2017-01-18 18:19:40'),
	(2, 2, 25.00, '2017-01-19 18:20:13'),
	(3, 2, 22.00, '2017-01-20 18:20:33'),
	(4, 2, 27.00, '2017-01-21 18:20:49'),
	(5, 2, 15.00, '2017-01-22 18:21:05'),
	(6, 2, 24.00, '2017-01-23 18:21:21'),
	(7, 1, 10.00, '2017-01-23 10:21:42'),
	(8, 1, 7.00, '2017-01-23 12:21:54'),
	(9, 1, 15.00, '2017-01-23 14:22:05'),
	(10, 1, 17.00, '2017-01-23 16:22:15'),
	(11, 1, 20.00, '2017-01-23 18:22:30'),
	(12, 2, 34.00, '2017-01-26 19:22:47'),
	(13, 2, 34.00, '2017-01-26 19:22:57'),
	(14, 2, 56.00, '2017-01-26 19:23:06'),
	(15, 2, 45.00, '2017-01-26 19:23:15'),
	(16, 2, 34.00, '2017-01-26 19:23:23'),
	(17, 2, 35.00, '2017-01-26 19:23:35'),
	(18, 2, 44.00, '2017-01-26 19:23:46');
/*!40000 ALTER TABLE `user_device_measures` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
