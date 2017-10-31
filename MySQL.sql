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
  `action_type_code` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`action_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.action_type: ~2 rows (приблизительно)
DELETE FROM `action_type`;
/*!40000 ALTER TABLE `action_type` DISABLE KEYS */;
INSERT INTO `action_type` (`action_type_id`, `action_type_name`, `icon_code`, `action_type_code`) VALUES
	(1, 'Измерительное устройство', 'TACHOMETER', 'SENSOR'),
	(2, 'Исполнительное устройство', 'AUTOMATION', 'ACTUATOR');
/*!40000 ALTER TABLE `action_type` ENABLE KEYS */;


-- Дамп структуры для функция things.fGetSyncIntervalDays
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `fGetSyncIntervalDays`(`eUserDeviceId` int) RETURNS int(11)
begin
return(
select utre.sync_interval
from user_devices_tree utre
where (utre.leaf_id,utre.user_id) = ( 
select udt.parent_leaf_id
,ud.user_id
from user_device ud
join user_devices_tree udt on udt.user_device_id=ud.user_device_id
where ud.user_device_id = eUserDeviceId
)
);
end//
DELIMITER ;


-- Дамп структуры для функция things.fIsExistsContLogin
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `fIsExistsContLogin`(
eContLog varchar(50)
) RETURNS int(11)
begin

return(
select case when count(*)>0 then 1 else 0 end
from user_devices_tree udt
where udt.control_log=eContLog
);

end//
DELIMITER ;


-- Дамп структуры для функция things.fIsExistsTopicName
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `fIsExistsTopicName`(`eTopicName` varchar(200)
) RETURNS int(11)
begin

return(
select case when count(*)>0 then 1 else 0 end
from user_device ud
where ud.mqtt_topic_write = eTopicName
);

end//
DELIMITER ;


-- Дамп структуры для функция things.fisExistsUserLogin
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `fisExistsUserLogin`(
eLogin varchar(150)
) RETURNS int(11)
begin

return(
select case when count(*)>0 then 1 else 0 end
from users u
where u.user_log = eLogin
);

end//
DELIMITER ;


-- Дамп структуры для функция things.fisExistsUserMail
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `fisExistsUserMail`(
eMail varchar(150)
) RETURNS int(11)
begin

return(
select case when count(*)>0 then 1 else 0 end
from users u
where u.user_mail = eMail
);

end//
DELIMITER ;


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


-- Дамп структуры для функция things.f_get_actuator_state_id
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_actuator_state_id`(`eUserDeviceId` int
, `eStateName` varchar(30)
) RETURNS int(11)
begin

return(
select uas.user_actuator_state_id
from user_actuator_state uas
where uas.user_device_id = eUserDeviceId
and uas.actuator_state_name = eStateName
);

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


-- Дамп структуры для функция things.f_get_min_period_date1
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_min_period_date1`(
ePeriodCode varchar(50)
) RETURNS datetime
begin

declare i_min_date datetime;

if (ePeriodCode = 'год') then
	select now()-interval 1 year into i_min_date;
end if;

if (ePeriodCode = 'месяц') then
	select now()-interval 1 month into i_min_date;
end if;

if (ePeriodCode = 'неделя') then
	select now()-interval 1 week into i_min_date;
end if;

if (ePeriodCode = 'день') then
	select now()-interval 1 day into i_min_date;
end if;

if (ePeriodCode = 'час') then
	select now()-interval 1 hour into i_min_date;
end if;

if (ePeriodCode = 'минута') then
	select now()-interval 1 minute into i_min_date;
end if;

return i_min_date;

end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_next_condition_num
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_next_condition_num`(
eUserDeviceId int
,eUserStateName varchar(30)
) RETURNS int(11)
begin

return(
select count(*) + 1 
from user_actuator_state uas
join user_actuator_state_condition uasc on uasc.user_actuator_state_id=uas.user_actuator_state_id
where uas.user_device_id = eUserDeviceId
and uas.actuator_state_name = eUserStateName
);

end//
DELIMITER ;


-- Дамп структуры для функция things.f_get_parent_leaf_id
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_parent_leaf_id`(
eUserDeviceId int
) RETURNS int(11)
begin

return(
select udt.parent_leaf_id
from user_device ud
join user_devices_tree udt on udt.user_device_id=ud.user_device_id
where ud.user_device_id = eUserDeviceId
);

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


-- Дамп структуры для функция things.f_get_server_link
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_server_link`(`eServType` varchar(50)
, `eUserLog` VARCHAR(50)) RETURNS varchar(50) CHARSET utf8
begin
return(
select ms.vserver_ip
from mqtt_servers ms
join users u on u.user_id=ms.user_id
where ms.server_type=eServType
and u.user_log=eUserLog
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


-- Дамп структуры для функция things.f_get_user_account_type
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_get_user_account_type`(
eUserLog varchar(50)
) RETURNS varchar(50) CHARSET utf8
begin
return(
select 
ifnull((
select min(uac.account_type)
from user_accounts uac
where uac.user_id=u.user_id
and uac.date_from<=sysdate()
and uac.date_till>=sysdate()
),'REGULAR') account_type
from users u
where u.user_log = eUserLog
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


-- Дамп структуры для функция things.f_insert_actuator_state_condition
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_insert_actuator_state_condition`(
eUserActuatorStateId int
,eLeftPartExpression VARCHAR(150)
,eSignExpression VARCHAR(2)
,eRightPartExpression VARCHAR(150)
,eConditionNum int
,eConditionInterval int
) RETURNS int(11)
begin
declare i_state_condition_id int;

insert into user_actuator_state_condition(
user_actuator_state_id
,left_part_expression
,sign_expression
,right_part_expression
,condition_num
,condition_interval
)
values(
eUserActuatorStateId
,eLeftPartExpression
,eSignExpression
,eRightPartExpression
,eConditionNum
,eConditionInterval
);

select LAST_INSERT_ID() into i_state_condition_id;

return i_state_condition_id;

end//
DELIMITER ;


-- Дамп структуры для функция things.f_is_exists_period_measures
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `f_is_exists_period_measures`(`ePeriodCode` varchar(50)
, `eUserDeviceId` INT) RETURNS int(11)
begin
return (
select case when count(*)>0 then 1 else 0 end
from user_device_measures udm
where udm.measure_date <= (
select now()
)
and udm.measure_date >= (f_get_min_period_date1(ePeriodCode))
and udm.user_device_id=eUserDeviceId
and udm.measure_value is not null
order by udm.measure_date
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
, `eMqttServerId` INT, `eDeviceLog` VARCHAR(50), `eDevicePass` VARCHAR(50), `eInTopicName` VARCHAR(150)) RETURNS int(11)
begin
declare i_user_device_id int;

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
,device_log
,device_pass
,measure_data_type
)
values(
eUserId
,eDeviceName
,sysdate()
,eActionTypeId
,eMqttServerId
,'Ед'
,96
,64
,eDeviceName
,'не задано'
,eDeviceLog
,eDevicePass
,'текст'
);

select LAST_INSERT_ID() into i_user_device_id;

update user_device ud
set ud.mqtt_topic_write=eInTopicName
,ud.mqtt_topic_read=i_user_device_id
where ud.user_device_id=i_user_device_id;

return i_user_device_id;

end//
DELIMITER ;


-- Дамп структуры для процедура things.get_max_vals
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `get_max_vals`()
begin
declare row_cnt int;
declare i int default 0;

declare i_TABLE_NAME varchar(100);
declare i_COLUMN_NAME varchar(100);
declare i_COLUMN_TYPE varchar(100);
declare i_QUERY_VAL varchar(500);


declare cur1 cursor for
select col.TABLE_NAME
,col.COLUMN_NAME
,col.COLUMN_TYPE
,concat(concat(concat('select max(',col.COLUMN_NAME),') into @a from '),col.TABLE_NAME) query_val
from information_schema.`COLUMNS` col
join information_schema.`TABLES` tab on tab.TABLE_NAME=col.TABLE_NAME
where tab.TABLE_SCHEMA='things';

select count(*) into row_cnt
from information_schema.`COLUMNS` col
join information_schema.`TABLES` tab on tab.TABLE_NAME=col.TABLE_NAME
where tab.TABLE_SCHEMA='things';

open cur1;

	while i<row_cnt do
	
		fetch cur1 into i_TABLE_NAME,i_COLUMN_NAME,i_COLUMN_TYPE,i_QUERY_VAL;
		set @s = i_QUERY_VAL;
		PREPARE stmt FROM @s;
		EXECUTE stmt;
		DEALLOCATE prepare stmt;
		
		insert into tab_meta_data
		select i_TABLE_NAME,i_COLUMN_NAME,i_COLUMN_TYPE,@a;
			
		set i = i + 1;
	
	end while;

close cur1;

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


-- Дамп структуры для функция things.IsNumeric
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `IsNumeric`(sIn varchar(1024)) RETURNS tinyint(4)
RETURN sIn REGEXP '^(-|\\+){0,1}([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)$'//
DELIMITER ;


-- Дамп структуры для таблица things.mqtt_servers
CREATE TABLE IF NOT EXISTS `mqtt_servers` (
  `server_id` int(11) NOT NULL AUTO_INCREMENT,
  `server_ip` varchar(20) DEFAULT NULL,
  `server_port` int(11) DEFAULT NULL,
  `is_busy` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `server_type` varchar(50) DEFAULT NULL,
  `vserver_ip` varchar(50) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`server_id`),
  KEY `FK_mqtt_servers_users` (`user_id`),
  CONSTRAINT `FK_mqtt_servers_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.mqtt_servers: ~12 rows (приблизительно)
DELETE FROM `mqtt_servers`;
/*!40000 ALTER TABLE `mqtt_servers` DISABLE KEYS */;
INSERT INTO `mqtt_servers` (`server_id`, `server_ip`, `server_port`, `is_busy`, `name`, `server_type`, `vserver_ip`, `user_id`) VALUES
	(3, 'tcp://0.0.0.0:9001', 9001, 0, 'LOCALHOST', 'regular', 'tcp://snslog.ru:9001', 1),
	(4, 'ssl://0.0.0.0:9002', 9002, 0, 'LOCALHOST', 'ssl', 'ssl://snslog.ru:9002', 1),
	(5, 'tcp://0.0.0.0:9003', 9003, 0, 'LOCALHOST', 'regular', 'tcp://snslog.ru:9003', 2),
	(6, 'ssl://0.0.0.0:9004', 9004, 0, 'LOCALHOST', 'ssl', 'ssl://snslog.ru:9004', 2),
	(8, 'tcp://0.0.0.0:9005', 9005, 0, 'LOCALHOST', 'regular', 'tcp://snslog.ru:9005', 5),
	(9, 'ssl://0.0.0.0:9006', 9006, 0, 'LOCALHOST', 'ssl', 'ssl://snslog.ru:9006', 5),
	(10, 'tcp://0.0.0.0:9007', 9007, 0, 'LOCALHOST', 'regular', 'tcp://snslog.ru:9007', 6),
	(11, 'ssl://0.0.0.0:9008', 9008, 0, 'LOCALHOST', 'ssl', 'ssl://snslog.ru:9008', 6),
	(15, 'tcp://0.0.0.0:9009', 9009, 0, 'LOCALHOST', 'regular', 'tcp://snslog.ru:9009', 4),
	(16, 'ssl://0.0.0.0:9010', 9010, 0, 'LOCALHOST', 'ssl', 'ssl://snslog.ru:9010', 4),
	(17, 'tcp://0.0.0.0:9011', 9011, 0, 'LOCALHOST', 'regular', 'tcp://snslog.ru:9011', 7),
	(18, 'ssl://0.0.0.0:9012', 9012, 0, 'LOCALHOST', 'ssl', 'ssl://snslog.ru:9012', 7);
/*!40000 ALTER TABLE `mqtt_servers` ENABLE KEYS */;


-- Дамп структуры для таблица things.notification_type
CREATE TABLE IF NOT EXISTS `notification_type` (
  `notification_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_code` varchar(50) DEFAULT NULL,
  `notification_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`notification_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.notification_type: ~3 rows (приблизительно)
DELETE FROM `notification_type`;
/*!40000 ALTER TABLE `notification_type` DISABLE KEYS */;
INSERT INTO `notification_type` (`notification_type_id`, `notification_code`, `notification_name`) VALUES
	(1, 'MAIL', 'оповещение по эл.почте'),
	(2, 'WHATSUP', 'оповещение по What\'s Up'),
	(3, 'SMS', 'оповещение по SMS');
/*!40000 ALTER TABLE `notification_type` ENABLE KEYS */;


-- Дамп структуры для процедура things.pNewUserAdd
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `pNewUserAdd`(IN `eLog` varchar(50)
, IN `ePswdSha` varchar(150)
, IN `ePhone` varchar(150)
, IN `eMail` varchar(150)
, IN `ePost` varchar(50)
, IN `eSubjType` varchar(50)
, IN `eSubjName` varchar(150)
, IN `eSubjAddr` varchar(150)
, IN `eSubjInn` varchar(50)
, IN `eSubjKpp` varchar(50)
, IN `eFirName` varchar(50)
, IN `eSecName` varchar(50)
, IN `eMidName` varchar(50)
, IN `edBirthdate` Date

)
begin
declare i_user_id int;
declare i_server_port int;

if (eSubjType = 'физическое лицо') then

	insert into users(
	user_log
	,user_pass
	,user_mail
	,user_phone
	,first_name
	,second_name
	,middle_name
	,birth_date
	,subject_type
	,post_index
	) values(
	eLog
	,ePswdSha
	,eMail
	,ePhone
	,eFirName
	,eSecName
	,eMidName
	,edBirthdate
	,eSubjType
	,ePost
	);

else 

	insert into users(
	user_log
	,user_pass
	,user_mail
	,user_phone
	,subject_type
	,subject_name
	,subject_address
	,subject_inn
	,subject_kpp
	,post_index
	) values(
	eLog
	,ePswdSha
	,eMail
	,ePhone
	,eSubjType
	,eSubjName
	,eSubjAddr
	,eSubjInn
	,eSubjKpp
	,ePost
	);
	
end if;

select LAST_INSERT_ID() into i_user_id;

insert into user_devices_tree(
leaf_id
,leaf_name
,user_id
) values (
1
,'Устройства'
,i_user_id
);

select max(server_port) into i_server_port
from mqtt_servers;

insert into mqtt_servers(
server_ip
,server_port
,is_busy
,name
,server_type
,vserver_ip
,user_id
) values (
concat('tcp://0.0.0.0:',i_server_port+1)
,i_server_port+1
,0
,'LOCALHOST'
,'regular'
,concat('tcp://snslog.ru:',i_server_port+1)
,i_user_id
);


insert into mqtt_servers(
server_ip
,server_port
,is_busy
,name
,server_type
,vserver_ip
,user_id
) values (
concat('ssl://0.0.0.0:',i_server_port+2)
,i_server_port+2
,0
,'LOCALHOST'
,'ssl'
,concat('ssl://snslog.ru:',i_server_port+2)
,i_user_id
);

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_add_subfolder
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_add_subfolder`(
	IN `eParentLeafId` int
,
	IN `eFolderName` varchar(30)
,
	IN `eUserLog` varchar(50)
,
	OUT `oTreeId` int
,
	OUT `oNewLeafId` int 
,
	IN `eContLog` VARCHAR(50),
	IN `eContPass` VARCHAR(50),
	IN `eContPassSha` VARCHAR(255),
	IN `eServerLink` VARCHAR(255)
,
	IN `eTimeSyncInterval` INT
,
	IN `eTimeSyncTopic` VARCHAR(150)


,
	IN `eTimeZone` VARCHAR(50)




)
begin
declare i_user_id int;
declare i_leaf_id int;
declare i_server_id int;
declare i_timezone_id int;

select u.user_id
,max(udt.leaf_id) + 1
into i_user_id
,i_leaf_id
from user_devices_tree udt
join users u on u.user_id = udt.user_id
where u.user_log = eUserLog
group by u.user_id;


select min(ms.server_id) into i_server_id
from mqtt_servers ms
where ms.vserver_ip = eServerLink;

select tm.timezone_id into i_timezone_id
from timezones tm
where tm.timezone_value = eTimeZone;

insert into user_devices_tree(
leaf_id
,parent_leaf_id
,user_device_id
,leaf_name
,user_id
,timezone_id
,mqtt_server_id
,time_topic
,sync_interval
,control_log
,control_pass
,control_pass_sha
)
values(
i_leaf_id
,eParentLeafId
,null
,eFolderName
,i_user_id
,i_timezone_id
,i_server_id
,eTimeSyncTopic
,eTimeSyncInterval
,eContLog
,eContPass
,eContPassSha
);

select LAST_INSERT_ID() into oTreeId;
set oNewLeafId = i_leaf_id;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_add_task
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_add_task`(IN `eUserDeviceId` int
, IN `eTaskTypeName` VARCHAR(20)
, IN `eTaskInterval` int
, IN `eIntervalType` varchar(20)
, OUT `oTaskId` INT)
begin
declare i_task_type_id int;

select tt.task_type_id into i_task_type_id
from task_type tt
where tt.task_type_name='SYNCTIME';

insert into user_device_task(
user_device_id
,task_type_id
,task_interval
,interval_type
) values(
eUserDeviceId
,i_task_type_id
,eTaskInterval
,eIntervalType
);

select LAST_INSERT_ID() into oTaskId;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_add_user_device
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_add_user_device`(IN `eParentLeafId` int
, IN `eDeviceName` varchar(30)
, IN `eUserLog` varchar(50)
, IN `eActionTypeName` varchar(100)
, OUT `oTreeId` int
, OUT `oNewLeafId` int
, OUT `oIconCode` varchar(100)
, OUT `oUserDeviceId` int
, IN `eInTopicName` VARCHAR(150))
begin
declare i_action_type_id int;
declare i_user_id int;
declare i_leaf_id int;
declare i_user_device_id int;

declare i_timezone_id int;
declare i_mqtt_server_id int;
declare i_time_topic varchar(150);
declare i_sync_interval int;
declare i_control_log varchar(50);
declare i_control_pass varchar(50);
declare i_control_pass_sha varchar(255);

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


select udt.timezone_id
,udt.mqtt_server_id
,udt.time_topic
,udt.sync_interval
,udt.control_log
,udt.control_pass
,udt.control_pass_sha
into i_timezone_id
,i_mqtt_server_id
,i_time_topic
,i_sync_interval
,i_control_log
,i_control_pass
,i_control_pass_sha
from user_devices_tree udt
where udt.user_id = i_user_id
and udt.leaf_id = eParentLeafId;

set i_user_device_id = f_user_device_insert(
eDeviceName
,i_user_id
,eUserLog
,i_action_type_id
,i_mqtt_server_id
,i_control_log
,i_control_pass
,eInTopicName
);

insert into user_devices_tree(
leaf_id
,parent_leaf_id
,user_device_id
,leaf_name
,user_id

,timezone_id
,mqtt_server_id
,time_topic
,sync_interval
,control_log
,control_pass
,control_pass_sha
)
values(
i_leaf_id
,eParentLeafId
,i_user_device_id
,eDeviceName
,i_user_id

,i_timezone_id
,i_mqtt_server_id
,i_time_topic
,i_sync_interval
,i_control_log
,i_control_pass
,i_control_pass_sha
);

select LAST_INSERT_ID() into oTreeId;
set oNewLeafId = i_leaf_id;
set oUserDeviceId = i_user_device_id;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_delete_actuator_data
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_delete_actuator_data`(IN `eUserDeviceId` int
)
begin
declare i_user_device_id int;
declare i_actuator_state_name varchar(30);
declare i int default 0;
declare row_cnt int;

declare cur1 cursor for 
select uas.user_device_id
,uas.actuator_state_name
from user_actuator_state uas
where uas.user_device_id = eUserDeviceId;

select count(*) into row_cnt
from user_actuator_state uas
where uas.user_device_id = eUserDeviceId;

open cur1;

	while i<row_cnt do
	
		fetch cur1 into i_user_device_id,i_actuator_state_name;
		call p_delete_actuator_state(i_user_device_id,i_actuator_state_name);
		set i = i + 1;
	
	end while;

close cur1;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_delete_actuator_state
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_delete_actuator_state`(IN `eUserDeviceId` int
, IN `eActuatorName` VARCHAR(30)
, OUT `eRemStateId` INT)
begin
declare i_condition_id int;
declare i_actuator_state_id int;
declare row_cnt int;
declare i int default 0;

declare cur1 cursor for 
select uasc.actuator_state_condition_id
from user_actuator_state uas
join user_actuator_state_condition uasc on uasc.user_actuator_state_id = uas.user_actuator_state_id
where uas.user_device_id = eUserDeviceId
and uas.actuator_state_name = eActuatorName; 

select uas.user_actuator_state_id
into i_actuator_state_id
from user_actuator_state uas
where uas.user_device_id = eUserDeviceId
and uas.actuator_state_name = eActuatorName;

select count(*) into row_cnt
from user_actuator_state_condition uasc
where uasc.user_actuator_state_id = i_actuator_state_id;

open cur1;

	while i<row_cnt do
	
		fetch cur1 into i_condition_id;
		
			delete from user_state_condition_vars
			where actuator_state_condition_id = i_condition_id;
		
			delete from user_actuator_state_condition
			where actuator_state_condition_id = i_condition_id;
			
		set i = i + 1;
	
	end while;

close cur1;

set eRemStateId := i_actuator_state_id;

delete from user_actuator_state
where user_actuator_state_id = i_actuator_state_id;


end//
DELIMITER ;


-- Дамп структуры для процедура things.p_delete_state_condition
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_delete_state_condition`(
eUserDeviceId int
,eStateName varchar(30)
,eConditionNum int
)
begin
declare i_condition_id int;

select uasc.actuator_state_condition_id into i_condition_id
from user_device ud
join user_actuator_state uas on uas.user_device_id=ud.user_device_id
join user_actuator_state_condition uasc on uasc.user_actuator_state_id=uas.user_actuator_state_id
where ud.user_device_id = eUserDeviceId
and uas.actuator_state_name = eStateName
and uasc.condition_num = eConditionNum;

delete from user_state_condition_vars
where actuator_state_condition_id = i_condition_id;

delete from user_actuator_state_condition
where actuator_state_condition_id = i_condition_id;

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

delete from user_device_task
where user_device_id = i_user_device_id;


call p_delete_actuator_data(i_user_device_id);

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


-- Дамп структуры для процедура things.p_device_login_update
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_device_login_update`(
eUserDeviceId int
,eDeviceLogin varchar(30)
,eDevicePassWord varchar(30)
)
begin

update user_device ud
set ud.device_log = eDeviceLogin
,ud.device_pass = eDevicePassWord
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
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_insert_actuator_state`(IN `eUserDeviceId` int
, IN `eActuatorName` varchar(30)
, IN `eActuatorCode` varchar(20)
, OUT `oNewStateId` INT)
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

select LAST_INSERT_ID() into oNewStateId;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_insert_actuator_state_condition
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_insert_actuator_state_condition`(
eUserActuatorStateId int
,eLeftPartExpression VARCHAR(150)
,eSignExpression VARCHAR(2)
,eRightPartExpression VARCHAR(150)
,eConditionNum int
,eConditionInterval int
)
begin

insert into user_actuator_state_condition(
user_actuator_state_id
,left_part_expression
,sign_expression
,right_part_expression
,condition_num
,condition_interval
)
values(
eUserActuatorStateId
,eLeftPartExpression
,eSignExpression
,eRightPartExpression
,eConditionNum
,eConditionInterval
);

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_insert_condition_vars
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_insert_condition_vars`(
eActuatorStateConditionId int
,eVarCode VARCHAR(20)
,eUserDeviceId int
)
begin

insert into user_state_condition_vars(
actuator_state_condition_id
,var_code
,user_device_id
)
values(
eActuatorStateConditionId
,eVarCode
,eUserDeviceId
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


-- Дамп структуры для процедура things.p_make_date_marks1
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_make_date_marks1`(IN eUserDeviceId int
, IN ePeriodCode varchar(50)
, IN eCountMarks int
, OUT i_mark_list varchar(1000)
, OUT i_delta INT)
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


-- Дамп структуры для процедура things.p_make_double_marks1
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_make_double_marks1`(IN `eUserDeviceId` int
, IN `ePeriodCode` varchar(50)
, IN `eCountMarks` int
, OUT `eMarkList` varchar(1000)
, OUT `iDelta` INT
)
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

if (f_is_exists_period_measures(ePeriodCode,eUserDeviceId)!=0) then

	select now() into i_max_date;
   set i_min_date = f_get_min_period_date1(ePeriodCode);
   
   select concat('i_max_date : ',i_max_date);
   select concat('i_min_date : ',i_min_date);
	
	select min(uu.measure_value) into i_min_double
	from user_device_measures uu
	where uu.user_device_id=eUserDeviceId
	and uu.measure_value is not null
	and uu.measure_date>=i_min_date
	and uu.measure_date<=i_max_date;
	
	select concat('i_min_double : ',i_min_double);
	
	select max(uu.measure_value) into i_max_double
	from user_device_measures uu
	where uu.user_device_id=eUserDeviceId
	and uu.measure_value is not null
	and uu.measure_date>=i_min_date
	and uu.measure_date<=i_max_date;
	
	select concat('i_max_double : ',i_max_double);

else 

set i_min_double = 0;
set i_max_double = 10;
 
 #select ePeriodCode;

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


-- Дамп структуры для процедура things.p_updateDetectorFormData
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_updateDetectorFormData`(
eUserDeviceId int
,ePeriodMeasureValue varchar(100)
,eMeasureDataTypeValue varchar(50)
)
begin

update user_device ud
set ud.user_device_measure_period = ePeriodMeasureValue
,ud.measure_data_type = eMeasureDataTypeValue
where ud.user_device_id = eUserDeviceId;

end//
DELIMITER ;


-- Дамп структуры для процедура things.p_updateFolderPrefsFormData
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `p_updateFolderPrefsFormData`(IN `eLeafId` int
, IN `eUserLog` varchar(50)
, IN `eDeviceLog` varchar(50)
, IN `eDevicePass` varchar(50)
, IN `eDevicePassSha` varchar(255)
, IN `eTimeZone` varchar(15)
, IN `eTimeSyncInt` int
)
begin
declare i_time_zone_id int;
declare i_tree_id int;

select tm.timezone_id into i_time_zone_id
from timezones tm
where tm.timezone_value=eTimeZone;

select udtr.user_devices_tree_id into i_tree_id
from user_devices_tree udtr
join users u on u.user_id=udtr.user_id
where u.user_log = eUserLog
and udtr.leaf_id = eLeafId;

update user_devices_tree udt
set udt.control_log = eDeviceLog
,udt.control_pass = eDevicePass
,udt.control_pass_sha = eDevicePassSha
,udt.timezone_id = i_time_zone_id
,udt.sync_interval = eTimeSyncInt
where udt.user_devices_tree_id = i_tree_id;


update user_device ude
set ude.device_log = eDeviceLog
,ude.device_pass = eDevicePass
where ude.user_device_id in (
select chl.user_device_id
from user_devices_tree pl
join user_devices_tree chl on chl.parent_leaf_id=pl.leaf_id and chl.user_id=pl.user_id
where pl.user_devices_tree_id=i_tree_id
);


end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_condition_data
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_condition_data`(`eConditionId` int
) RETURNS text CHARSET utf8
begin

return(
select concat('<condition_rule>',
'<mqtt_topic_write>',ud.mqtt_topic_write,'</mqtt_topic_write>',
'<server_ip>',ms.server_ip,'</server_ip>',
'<left_part_expression>',uasc.left_part_expression,'</left_part_expression>',
'<right_part_expression>',uasc.right_part_expression,'</right_part_expression>',
'<sign_expression>',replace(replace(uasc.sign_expression,'>','&gt;'),'<','&lt;'),'</sign_expression>',
'<condition_interval>',uasc.condition_interval,'</condition_interval>',
'</condition_rule>'
)
from user_actuator_state_condition uasc
join user_actuator_state uas on uas.user_actuator_state_id=uasc.user_actuator_state_id
join user_device ud on ud.user_device_id=uas.user_device_id
join mqtt_servers ms on ms.server_id=ud.mqqt_server_id
where uasc.actuator_state_condition_id = eConditionId
);
end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_folder_data
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_folder_data`(
	`eUserLog` varchar(50)

) RETURNS text CHARSET utf8
begin
return(
select ifnull(concat('<folder_list>'
,group_concat(concat(
'<folder_data>'
,'<folder_login>',udt.control_log,'</folder_login>'
,'<folder_password>',udt.control_pass_sha,'</folder_password>'
,'</folder_data>'
) separator '')
,'</folder_list>'
),'<folder_list/>')
from user_devices_tree udt 
join users u on u.user_id=udt.user_id
where u.user_log = eUserLog
and ifnull(udt.user_device_id,0) = 0
and ifnull(udt.parent_leaf_id,0) != 0
);
end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_server_data
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_server_data`(eUserLog varchar(50)) RETURNS blob
begin
return(
select concat('<server_list>'
,group_concat(concat(
'<server_data>'
,'<server_id>',ms.server_id,'</server_id>'
,'<server_port>',ms.server_port,'</server_port>'
,'<server_type>',ms.server_type,'</server_type>'
,'</server_data>'
) separator '')
,'</server_list>'
)
from mqtt_servers ms
join users u on u.user_id=ms.user_id
where u.user_log = eUserLog
);
end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_state_condition_list
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_state_condition_list`(
	`eStateId` int

) RETURNS text CHARSET utf8
begin
return(
select ifnull(concat('<condition_list>'
,group_concat(
concat('<condition_data>'
,'<actuator_state_condition_id>',uasc.actuator_state_condition_id,'</actuator_state_condition_id>'
,'<user_actuator_state_id>',uasc.user_actuator_state_id,'</user_actuator_state_id>'
,'<left_part_expression>',uasc.left_part_expression,'</left_part_expression>'
,'<sign_expression>',replace(replace(uasc.sign_expression,'>','&gt;'),'<','&lt;'),'</sign_expression>'
,'<right_part_expression>',uasc.right_part_expression,'</right_part_expression>'
,'<condition_num>',uasc.condition_num,'</condition_num>'
,'<condition_interval>',uasc.condition_interval,'</condition_interval>'
,'</condition_data>'
) separator '')
,'</condition_list>'
),'<condition_list/>'
)
from user_actuator_state_condition uasc
where uasc.user_actuator_state_id=eStateId
);
end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_state_data
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_state_data`(`eStateId` int) RETURNS text CHARSET utf8
begin
declare i_state_data_str text;
declare i_state_notif_str text;

select ifnull(concat('<state_data>'
,'<actuator_message_code>',uas.actuator_message_code,'</actuator_message_code>'
,'<transition_time>',uas.transition_time,'</transition_time>'
,'<control_log>',udt.control_log,'</control_log>'
,'<control_pass>',udt.control_pass,'</control_pass>'
,'<server_ip>',ms.server_ip,'</server_ip>'
,'<mqtt_topic_write>',ud.mqtt_topic_write,'</mqtt_topic_write>'
,'<action_type_code>',aty.action_type_code,'</action_type_code>'
,'<user_mail>',u.user_mail,'</user_mail>'
,'<user_phone>',u.user_phone,'</user_phone>'
,'<notification_list>','#notification_list_value#','</notification_list>'
,'</state_data>'
),'<state_data/>') into i_state_data_str
from user_actuator_state uas
join user_device ud on ud.user_device_id=uas.user_device_id
join user_devices_tree udt on udt.user_device_id=ud.user_device_id
join mqtt_servers ms on ms.server_id=udt.mqtt_server_id
join action_type aty on aty.action_type_id=ud.action_type_id
join users u on u.user_id=ud.user_id
where uas.user_actuator_state_id=eStateId;

select ifnull(concat('<notification_list>'
,group_concat('<notification_data>'
,'<notification_code>',nty.notification_code,'</notification_code>'
,'</notification_data>'
separator ''
)
,'</notification_list>')
,'<notification_list/>') into i_state_notif_str
from user_device_state_notification un
join notification_type nty on nty.notification_type_id=un.notification_type_id
join user_actuator_state uas on uas.user_actuator_state_id=un.user_actuator_state_id
where uas.user_actuator_state_id=eStateId;

set i_state_data_str := replace(i_state_data_str,'<notification_list>#notification_list_value#</notification_list>',i_state_notif_str);

return i_state_data_str;
end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_state_message_data
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_state_message_data`(`eActuatorStateId` int) RETURNS text CHARSET utf8
begin
return(
select concat('<device_message_data>'
,'<control_log>',udt.control_log,'</control_log>'
,'<control_pass>',udt.control_pass,'</control_pass>'
,'<mqtt_topic_write>',ud.mqtt_topic_write,'</mqtt_topic_write>'
,'<server_ip>',ms.server_ip,'</server_ip>'
,'<actuator_message_code>',uas.actuator_message_code,'</actuator_message_code>'
,'</device_message_data>'
)
from user_actuator_state uas
join user_device ud on uas.user_device_id=ud.user_device_id
join user_devices_tree udt on udt.user_device_id=ud.user_device_id
join mqtt_servers ms on ms.server_id=ud.mqqt_server_id
where uas.user_actuator_state_id = eActuatorStateId
);
end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_task_data
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_task_data`(eTaskId int) RETURNS text CHARSET utf8
begin
return(
select concat(
'<task_data>'
,'<task_type_name>',t.task_type_name,'</task_type_name>'
,'<task_interval>',t.task_interval,'</task_interval>'
,'<interval_type>',t.interval_type,'</interval_type>'
,'<write_topic_name>',t.write_topic_name,'</write_topic_name>'
,'<server_ip>',t.server_ip,'</server_ip>'
,'<control_log>',t.control_log,'</control_log>'
,'<control_pass>',t.control_pass,'</control_pass>'
,'<message_value>',t.message_value,'</message_value>'
,'</task_data>'
)
from (
select tt.task_type_name
,tas.task_interval
,tas.interval_type
,case when tt.task_type_name = 'SYNCTIME' then udtr.time_topic
else null end write_topic_name
,ms.server_ip
,udtr.control_log
,udtr.control_pass
,case when tt.task_type_name = 'SYNCTIME' then tz.timezone_value
else null end message_value
from user_device_task tas
join task_type tt on tt.task_type_id=tas.task_type_id
left join user_devices_tree udtr on udtr.user_device_id=tas.user_device_id
left join mqtt_servers ms on ms.server_id=udtr.mqtt_server_id
left join timezones tz on tz.timezone_id=udtr.timezone_id
where tas.user_device_task_id = eTaskId
) t
);
end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_user_list
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_user_list`() RETURNS text CHARSET utf8
begin
return(
select concat('<user_list>'
,group_concat(t.xmlUsers separator '')
,'</user_list>'
)
from (
select concat('<user_data>'
,'<user_id>',u.user_id,'</user_id>'
,'<user_log>',u.user_log,'</user_log>'
,'</user_data>'
) xmlUsers
from users u
join mqtt_servers ms on ms.user_id=u.user_id
group by u.user_id
,u.user_log
) t
);
end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_user_state_list
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_user_state_list`(eUserLog varchar(50)) RETURNS text CHARSET utf8
begin
return(
select concat('<actuator_state_list>'
,group_concat(
concat(
'<user_actuator_state_id>',uas.user_actuator_state_id,'</user_actuator_state_id>'
) separator '')
,'</actuator_state_list>'
)
from user_actuator_state uas
join user_device ud on ud.user_device_id=uas.user_device_id
join users u on u.user_id=ud.user_id
where u.user_log = eUserLog
);
end//
DELIMITER ;


-- Дамп структуры для функция things.s_get_user_task_list
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `s_get_user_task_list`(eUserLog varchar(50)) RETURNS text CHARSET utf8
begin
return(
select concat('<user_device_task_list>'
,group_concat(
concat(
'<user_device_task_id>',tas.user_device_task_id,'</user_device_task_id>'
) separator '')
,'</user_device_task_list>'
)
from user_device_task tas
join user_device ud on ud.user_device_id=tas.user_device_id
join users u on u.user_id=ud.user_id
where u.user_log = eUserLog
);
end//
DELIMITER ;


-- Дамп структуры для процедура things.s_message_recerve
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `s_message_recerve`(IN `eTopic` varchar(200)
, IN `eMessage` varchar(200)
, IN `eUserLog` varchar(100)
)
begin

declare i_sep_pos int;
declare i_topic_exists int;
declare i_mess_unix_time varchar(200);
declare i_mess_date_time datetime;
declare i_mess_date_serv datetime;
declare i_message_value varchar(500);
declare i_user_device_id int;
declare i_data_type varchar(50);

declare i_date_value datetime;
declare i_num_value double(10,2);

select count(*) into i_topic_exists
from user_device ud
join users u on u.user_id=ud.user_id
where ud.mqtt_topic_write = eTopic
and u.user_log = eUserLog;

if (i_topic_exists = 1) then

	select ud.user_device_id
	,ud.measure_data_type
	,case when instr(replace(tm.timezone_value,'UTC',''),'+') 
	then date_add(now(),interval cast(replace(tm.timezone_value,'UTC+','') as unsigned)-3 hour)
	else date_sub(now(),interval cast(replace(tm.timezone_value,'UTC-','') as unsigned)+3 hour) 
	end utc_datetime 
	into i_user_device_id
	,i_data_type
	,i_mess_date_serv
	from user_device ud
	join user_devices_tree udt on udt.user_device_id=ud.user_device_id
	join timezones tm on tm.timezone_id=udt.timezone_id
	join users u on u.user_id=ud.user_id
	where ud.mqtt_topic_write = eTopic
	and u.user_log = eUserLog;
	
	select instr(eMessage,':') into i_sep_pos;
	
	if (i_sep_pos>0) then
	
		select substring(eMessage,1,instr(eMessage,':')-1) into i_mess_unix_time;
		if (IsNumeric(i_mess_unix_time)=1) then
		SELECT FROM_UNIXTIME(round((CAST(replace(i_mess_unix_time,' ','') AS UNSIGNED))/1000)) into i_mess_date_time;
		else 
		set i_mess_date_time = i_mess_date_serv;
		end if;
		select substring(eMessage,instr(eMessage,':')+1,length(eMessage)) into i_message_value;
	
	else
	
		set i_mess_date_time = i_mess_date_serv;
		select replace(eMessage,' ','') into i_message_value;
	
	end if;
		
	if (i_data_type='дата' and IsNumeric(i_message_value)=1) then
			SELECT FROM_UNIXTIME(round((CAST(replace(i_message_value,' ','') AS UNSIGNED))/1000)) into i_date_value;
			
			#select concat('Дата:',i_message_value);
			
			if (i_date_value is not null) then
			
			insert into user_device_measures(
			user_device_id
			,measure_value
			,measure_date
			,measure_mess
			,measure_date_value
			)
			values(
			i_user_device_id
			,null
			,i_mess_date_time
			,null
			,i_date_value
			);
			
			end if;
			
	elseif (i_data_type='число' and IsNumeric(i_message_value)=1) then
	
	#select concat('Число:',i_message_value);
	
			SELECT CAST(replace(i_message_value,' ','') AS decimal(10,2)) + 0E0 into i_num_value;
			insert into user_device_measures(
			user_device_id
			,measure_value
			,measure_date
			,measure_mess
			,measure_date_value
			)
			values(
			i_user_device_id
			,i_num_value
			,i_mess_date_time
			,null
			,null
			);
			
	else
	
	#select concat('Прочее:',i_message_value);
	
			insert into user_device_measures(
			user_device_id
			,measure_value
			,measure_date
			,measure_mess
			,measure_date_value
			)
			values(
			i_user_device_id
			,null
			,i_mess_date_time
			,i_message_value
			,null
			);
			
	end if;

end if;

end//
DELIMITER ;


-- Дамп структуры для процедура things.s_p_sensor_initial
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `s_p_sensor_initial`(IN `eUserLog` varchar(50)
, IN `eDeviceId` int
, OUT `oMqttTopicWrite` varchar(200)
, OUT `oMqttServerHost` varchar(100)
, OUT `oDevLog` VARCHAR(50), OUT `oDevPass` VARCHAR(50), OUT `oMesDataType` VARCHAR(50))
begin

select ud.mqtt_topic_write
,ms.server_ip
,ud.device_log
,ud.device_pass
,ud.measure_data_type
into oMqttTopicWrite
,oMqttServerHost
,oDevLog
,oDevPass
,oMesDataType
from user_device ud
join users u on u.user_id = ud.user_id
join mqtt_servers ms on ms.server_id=ud.mqqt_server_id
where ud.user_device_id = eDeviceId
and u.user_log = eUserLog;

end//
DELIMITER ;


-- Дамп структуры для процедура things.s_p_topic_data_log
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` PROCEDURE `s_p_topic_data_log`(IN `eTopicName` VARCHAR(255), IN `eMessDate` DATETIME, IN `eStringValue` VARCHAR(255), IN `eDoubleValue` DECIMAL(10,2), IN `eTimeStampValue` DATETIME)
begin
declare i_user_device_id int;

select ud.user_device_id into i_user_device_id
from user_device ud
where ud.mqtt_topic_write = eTopicName;

insert into user_device_measures(
user_device_id
,measure_value
,measure_date
,measure_mess
,measure_date_value
)
values(
i_user_device_id
,eDoubleValue
,eMessDate
,eStringValue
,eTimeStampValue
);

end//
DELIMITER ;


-- Дамп структуры для таблица things.tab_meta_data
CREATE TABLE IF NOT EXISTS `tab_meta_data` (
  `TABLE_NAME` varchar(100) DEFAULT NULL,
  `COLUMN_NAME` varchar(100) DEFAULT NULL,
  `COLUMN_TYPE` varchar(100) DEFAULT NULL,
  `MAX_VAL` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.tab_meta_data: ~102 rows (приблизительно)
DELETE FROM `tab_meta_data`;
/*!40000 ALTER TABLE `tab_meta_data` DISABLE KEYS */;
INSERT INTO `tab_meta_data` (`TABLE_NAME`, `COLUMN_NAME`, `COLUMN_TYPE`, `MAX_VAL`) VALUES
	('action_type', 'action_type_id', 'int(11)', '2'),
	('action_type', 'action_type_name', 'varchar(100)', 'Исполнительное устройство'),
	('action_type', 'icon_code', 'varchar(100)', 'TACHOMETER'),
	('graph_period', 'period_id', 'int(11)', '6'),
	('graph_period', 'period_code', 'varchar(50)', 'час'),
	('mqtt_servers', 'server_id', 'int(11)', '4'),
	('mqtt_servers', 'server_ip', 'varchar(20)', 'tcp://0.0.0.0:1883'),
	('mqtt_servers', 'server_port', 'varchar(8)', '1884'),
	('mqtt_servers', 'is_busy', 'int(11)', '0'),
	('mqtt_servers', 'name', 'varchar(50)', 'LOCALHOST'),
	('mqtt_servers', 'server_type', 'varchar(50)', 'ssl'),
	('mqtt_servers', 'vserver_ip', 'varchar(50)', 'tcp://snslog.ru:1883'),
	('tab_meta_data', 'TABLE_NAME', 'varchar(100)', 'mqtt_servers'),
	('tab_meta_data', 'COLUMN_NAME', 'varchar(100)', 'vserver_ip'),
	('tab_meta_data', 'COLUMN_TYPE', 'varchar(100)', 'varchar(8)'),
	('tab_meta_data', 'MAX_VAL', 'varchar(500)', 'час'),
	('task_type', 'task_type_id', 'int(11)', '2'),
	('task_type', 'task_type_name', 'varchar(20)', 'SYNCTIME'),
	('timezones', 'timezone_id', 'int(11)', '38'),
	('timezones', 'timezone_value', 'varchar(15)', 'UTC-9'),
	('unit', 'unit_id', 'int(11)', '97'),
	('unit', 'unit_symbol', 'varchar(25)', 'Ф'),
	('unit', 'unit_name', 'varchar(100)', 'фарад'),
	('unit_factor', 'factor_id', 'int(11)', '112'),
	('unit_factor', 'factor_value', 'varchar(25)', '10e9'),
	('user_accounts', 'account_id', 'int(11)', '1'),
	('user_accounts', 'user_id', 'int(11)', '1'),
	('user_accounts', 'account_type', 'varchar(50)', 'PRIVILEGED'),
	('user_accounts', 'date_from', 'datetime', '2017-01-05 17:36:23'),
	('user_accounts', 'date_till', 'datetime', '2019-06-05 17:36:29'),
	('user_actuator_state', 'user_actuator_state_id', 'int(11)', '34'),
	('user_actuator_state', 'user_device_id', 'int(11)', '4'),
	('user_actuator_state', 'actuator_state_name', 'varchar(30)', 'Выключено'),
	('user_actuator_state', 'actuator_message_code', 'varchar(20)', 'On50'),
	('user_actuator_state_condition', 'actuator_state_condition_id', 'int(11)', '5'),
	('user_actuator_state_condition', 'user_actuator_state_id', 'int(11)', '23'),
	('user_actuator_state_condition', 'left_part_expression', 'varchar(150)', 'm/(4+m)^2'),
	('user_actuator_state_condition', 'sign_expression', 'varchar(2)', '>'),
	('user_actuator_state_condition', 'right_part_expression', 'varchar(150)', 'n'),
	('user_actuator_state_condition', 'condition_num', 'int(11)', '2'),
	('user_actuator_state_condition', 'condition_interval', 'int(11)', '15'),
	('user_device', 'user_device_id', 'int(11)', '43'),
	('user_device', 'user_id', 'int(11)', '1'),
	('user_device', 'device_user_name', 'varchar(30)', 'термометр-1'),
	('user_device', 'user_device_mode', 'varchar(100)', 'Периодическое измерение'),
	('user_device', 'user_device_measure_period', 'varchar(100)', 'не задано'),
	('user_device', 'user_device_date_from', 'datetime', '2017-07-19 16:59:57'),
	('user_device', 'action_type_id', 'int(11)', '2'),
	('user_device', 'device_units', 'varchar(20)', 'Ед'),
	('user_device', 'mqtt_topic_write', 'varchar(200)', '/kalistrat1/wer1'),
	('user_device', 'mqtt_topic_read', 'varchar(200)', '43'),
	('user_device', 'mqqt_server_id', 'int(11)', '3'),
	('user_device', 'unit_id', 'int(11)', '96'),
	('user_device', 'factor_id', 'int(11)', '66'),
	('user_device', 'description', 'varchar(255)', 'Это описание устройства HWg-STE. Максимальная длина 200 символов fdfdf'),
	('user_device', 'device_log', 'varchar(50)', 'kalistrat1'),
	('user_device', 'device_pass', 'varchar(50)', '7345345'),
	('user_device', 'measure_data_type', 'varchar(50)', 'число'),
	('user_device_measures', 'user_device_measure_id', 'int(11)', '9992'),
	('user_device_measures', 'user_device_id', 'int(11)', '43'),
	('user_device_measures', 'measure_value', 'double(10,2)', '777'),
	('user_device_measures', 'measure_date', 'datetime', '2017-09-20 17:49:30'),
	('user_device_measures', 'measure_mess', 'varchar(255)', 'cleorus'),
	('user_device_measures', 'measure_date_value', 'datetime', '2017-07-19 15:29:11'),
	('user_device_task', 'user_device_task_id', 'int(11)', '3'),
	('user_device_task', 'user_device_id', 'int(11)', '43'),
	('user_device_task', 'task_type_id', 'int(11)', '1'),
	('user_device_task', 'task_interval', 'int(11)', '1'),
	('user_device_task', 'interval_type', 'varchar(15)', 'DAYS'),
	('user_devices_tree', 'user_devices_tree_id', 'int(11)', '184'),
	('user_devices_tree', 'leaf_id', 'int(11)', '11'),
	('user_devices_tree', 'parent_leaf_id', 'int(11)', '7'),
	('user_devices_tree', 'user_device_id', 'int(11)', '43'),
	('user_devices_tree', 'leaf_name', 'varchar(30)', 'Устройства'),
	('user_devices_tree', 'user_id', 'int(11)', '7'),
	('user_devices_tree', 'timezone_id', 'int(11)', '19'),
	('user_devices_tree', 'mqtt_server_id', 'int(11)', '3'),
	('user_devices_tree', 'time_topic', 'varchar(150)', '/qwe123/synctime'),
	('user_devices_tree', 'sync_interval', 'int(11)', '5'),
	('user_devices_tree', 'control_log', 'varchar(50)', 'qwe123'),
	('user_devices_tree', 'control_pass', 'varchar(50)', '7345345'),
	('user_devices_tree', 'control_pass_sha', 'varchar(255)', '96cae35ce8a9b0244178bf28e4966c2ce1b8385723a96a6b838858cdd6ca0a1e'),
	('user_state_condition_vars', 'state_condition_vars_id', 'int(11)', '9'),
	('user_state_condition_vars', 'actuator_state_condition_id', 'int(11)', '5'),
	('user_state_condition_vars', 'var_code', 'varchar(20)', 'n'),
	('user_state_condition_vars', 'user_device_id', 'int(11)', '2'),
	('users', 'user_id', 'int(11)', '7'),
	('users', 'user_log', 'varchar(50)', 'qweqweqwe123'),
	('users', 'user_pass', 'varchar(150)', '7902699be42c8a8e46fbbb4501726517e86b22c56a189f7625a6da49081b2451'),
	('users', 'user_last_activity', 'datetime', '2017-01-12 18:02:48'),
	('users', 'user_mail', 'varchar(150)', 'sexpost@bk.ru'),
	('users', 'user_phone', 'varchar(150)', '12312312312'),
	('users', 'first_name', 'varchar(50)', 'qwe'),
	('users', 'second_name', 'varchar(50)', 'qwe'),
	('users', 'middle_name', 'varchar(50)', 'qwe'),
	('users', 'birth_date', 'date', '1987-07-13'),
	('users', 'subject_type', 'varchar(50)', 'юридическое лицо'),
	('users', 'subject_name', 'varchar(150)', 'snslog'),
	('users', 'subject_address', 'varchar(150)', 'anywhere'),
	('users', 'subject_inn', 'varchar(50)', '1231231231'),
	('users', 'subject_kpp', 'varchar(50)', '123123123'),
	('users', 'post_index', 'varchar(50)', '123123');
/*!40000 ALTER TABLE `tab_meta_data` ENABLE KEYS */;


-- Дамп структуры для таблица things.task_type
CREATE TABLE IF NOT EXISTS `task_type` (
  `task_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `task_type_name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`task_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.task_type: ~2 rows (приблизительно)
DELETE FROM `task_type`;
/*!40000 ALTER TABLE `task_type` DISABLE KEYS */;
INSERT INTO `task_type` (`task_type_id`, `task_type_name`) VALUES
	(1, 'SYNCTIME'),
	(2, 'MAIL');
/*!40000 ALTER TABLE `task_type` ENABLE KEYS */;


-- Дамп структуры для таблица things.timezones
CREATE TABLE IF NOT EXISTS `timezones` (
  `timezone_id` int(11) NOT NULL AUTO_INCREMENT,
  `timezone_value` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`timezone_id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.timezones: ~38 rows (приблизительно)
DELETE FROM `timezones`;
/*!40000 ALTER TABLE `timezones` DISABLE KEYS */;
INSERT INTO `timezones` (`timezone_id`, `timezone_value`) VALUES
	(1, 'UTC-12'),
	(2, 'UTC-11'),
	(3, 'UTC-10'),
	(4, 'UTC-9'),
	(5, 'UTC-8'),
	(6, 'UTC-7'),
	(7, 'UTC-6'),
	(8, 'UTC-5'),
	(9, 'UTC-4'),
	(10, 'UTC-3:30'),
	(11, 'UTC-3'),
	(12, 'UTC-2'),
	(13, 'UTC-1'),
	(14, 'UTC+0'),
	(15, 'UTC+1'),
	(16, 'UTC+2'),
	(17, 'UTC+3'),
	(18, 'UTC+3:30'),
	(19, 'UTC+4'),
	(20, 'UTC+4:30'),
	(21, 'UTC+5'),
	(22, 'UTC+5:30'),
	(23, 'UTC+5:45'),
	(24, 'UTC+6'),
	(25, 'UTC+6:30'),
	(26, 'UTC+7'),
	(27, 'UTC+8'),
	(28, 'UTC+8:30'),
	(29, 'UTC+8:45'),
	(30, 'UTC+9'),
	(31, 'UTC+9:30'),
	(32, 'UTC+10'),
	(33, 'UTC+10:30'),
	(34, 'UTC+11'),
	(35, 'UTC+12'),
	(36, 'UTC+12:45'),
	(37, 'UTC+13'),
	(38, 'UTC+14');
/*!40000 ALTER TABLE `timezones` ENABLE KEYS */;


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
  `first_name` varchar(50) DEFAULT NULL,
  `second_name` varchar(50) DEFAULT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `subject_type` varchar(50) DEFAULT NULL,
  `subject_name` varchar(150) DEFAULT NULL,
  `subject_address` varchar(150) DEFAULT NULL,
  `subject_inn` varchar(50) DEFAULT NULL,
  `subject_kpp` varchar(50) DEFAULT NULL,
  `post_index` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.users: ~6 rows (приблизительно)
DELETE FROM `users`;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`user_id`, `user_log`, `user_pass`, `user_last_activity`, `user_mail`, `user_phone`, `first_name`, `second_name`, `middle_name`, `birth_date`, `subject_type`, `subject_name`, `subject_address`, `subject_inn`, `subject_kpp`, `post_index`) VALUES
	(1, 'k', '7902699be42c8a8e46fbbb4501726517e86b22c56a189f7625a6da49081b2451', '2016-11-17 14:32:56', 'olegGuru7897@mail.ru', '34346346346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(2, 'Oleg', '2c624232cdd221771294dfbb310aca000a0df6ac8b66b696d90ef06fdefb64a3', '2017-01-12 18:02:48', 'akminfo@mail.ru', '34634634634', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(4, 'qweqweqwe', '0d1ea4c256cd50a2a7ccbfd22b3d9959f6fd30bd840b9ff3c7c65ee4e21df06d', NULL, 'sexpost@bk.ru', '12312312312', 'qwe', 'qwe', 'qwe', '1987-07-13', 'физическое лицо', NULL, NULL, NULL, NULL, '123123'),
	(5, 'qweqwe123', '0d1ea4c256cd50a2a7ccbfd22b3d9959f6fd30bd840b9ff3c7c65ee4e21df06d', NULL, 'koldybovich@yandex.ru', '12312312312', 'qwe', 'qwe', 'qwe', '1987-07-13', 'физическое лицо', NULL, NULL, NULL, NULL, '123123'),
	(6, 'qweqwe456', '0d1ea4c256cd50a2a7ccbfd22b3d9959f6fd30bd840b9ff3c7c65ee4e21df06d', NULL, 'kalique@bk.ru', '12312312312', 'qwe', 'qwe', 'qwe', '1985-07-20', 'физическое лицо', NULL, NULL, NULL, NULL, '123123'),
	(7, 'qweqweqwe123', '4cf8c576d4914a2a2a58cf230c63d0a84b91c1bcb6dec0c95377550b76965844', NULL, 'kauredinas@mail.ru', '12312312312', NULL, NULL, NULL, NULL, 'юридическое лицо', 'snslog', 'anywhere', '1231231231', '123123123', '123123');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_accounts
CREATE TABLE IF NOT EXISTS `user_accounts` (
  `account_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `account_type` varchar(50) DEFAULT NULL,
  `date_from` datetime DEFAULT NULL,
  `date_till` datetime DEFAULT NULL,
  PRIMARY KEY (`account_id`),
  KEY `FK_user_accounts_users` (`user_id`),
  CONSTRAINT `FK_user_accounts_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_accounts: ~1 rows (приблизительно)
DELETE FROM `user_accounts`;
/*!40000 ALTER TABLE `user_accounts` DISABLE KEYS */;
INSERT INTO `user_accounts` (`account_id`, `user_id`, `account_type`, `date_from`, `date_till`) VALUES
	(1, 1, 'PRIVILEGED', '2017-01-05 17:36:23', '2019-06-05 17:36:29');
/*!40000 ALTER TABLE `user_accounts` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_actuator_state
CREATE TABLE IF NOT EXISTS `user_actuator_state` (
  `user_actuator_state_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_device_id` int(11) NOT NULL,
  `actuator_state_name` varchar(30) DEFAULT NULL,
  `actuator_message_code` varchar(20) DEFAULT NULL,
  `transition_time` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_actuator_state_id`),
  KEY `FK_user_actuator_state_user_device` (`user_device_id`),
  KEY `INDX_DEVICEID_STATENAME` (`user_device_id`,`actuator_state_name`) USING BTREE,
  CONSTRAINT `FK_user_actuator_state_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_actuator_state: ~8 rows (приблизительно)
DELETE FROM `user_actuator_state`;
/*!40000 ALTER TABLE `user_actuator_state` DISABLE KEYS */;
INSERT INTO `user_actuator_state` (`user_actuator_state_id`, `user_device_id`, `actuator_state_name`, `actuator_message_code`, `transition_time`) VALUES
	(15, 3, 'Включено', 'DeviceOn', 5),
	(19, 3, 'Выключено', 'DeviceOff', 5),
	(20, 4, 'Включено', 'On', 5),
	(22, 4, 'Выключено', 'Off', 5),
	(23, 3, 'Включено на 50%', 'On50', 5),
	(27, 4, 'Включено на 50%', 'On50', 5),
	(31, 4, 'Включено на 10%', 'On10', 5),
	(34, 3, 'Включить на 10%', 'On10', 5);
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_actuator_state_condition: ~3 rows (приблизительно)
DELETE FROM `user_actuator_state_condition`;
/*!40000 ALTER TABLE `user_actuator_state_condition` DISABLE KEYS */;
INSERT INTO `user_actuator_state_condition` (`actuator_state_condition_id`, `user_actuator_state_id`, `left_part_expression`, `sign_expression`, `right_part_expression`, `condition_num`, `condition_interval`) VALUES
	(1, 20, 'a', '>', 'b', 1, 10),
	(4, 20, 'm', '=', 'n', 2, 7),
	(5, 23, 'm/(4+m)^2', '<', '0', 1, 15);
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
  `device_log` varchar(50) DEFAULT NULL,
  `device_pass` varchar(50) DEFAULT NULL,
  `measure_data_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`user_device_id`),
  UNIQUE KEY `USER_DEVICE_TOPIC_WRITE` (`mqtt_topic_write`),
  KEY `USER_DEVICE_NAME_INDX` (`user_id`,`device_user_name`),
  KEY `FK_user_device_action_type` (`action_type_id`),
  KEY `FK_user_device_mqtt_servers` (`mqqt_server_id`),
  KEY `FK_user_device_users` (`unit_id`),
  KEY `FK_user_device_unit_factor` (`factor_id`),
  KEY `DEVICE_LOG_INDX` (`device_log`),
  CONSTRAINT `FK_user_device_action_type` FOREIGN KEY (`action_type_id`) REFERENCES `action_type` (`action_type_id`),
  CONSTRAINT `FK_user_device_mqtt_servers` FOREIGN KEY (`mqqt_server_id`) REFERENCES `mqtt_servers` (`server_id`),
  CONSTRAINT `FK_user_device_unit` FOREIGN KEY (`unit_id`) REFERENCES `unit` (`unit_id`),
  CONSTRAINT `FK_user_device_unit_factor` FOREIGN KEY (`factor_id`) REFERENCES `unit_factor` (`factor_id`),
  CONSTRAINT `FK_user_device_users` FOREIGN KEY (`unit_id`) REFERENCES `unit` (`unit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_device: ~9 rows (приблизительно)
DELETE FROM `user_device`;
/*!40000 ALTER TABLE `user_device` DISABLE KEYS */;
INSERT INTO `user_device` (`user_device_id`, `user_id`, `device_user_name`, `user_device_mode`, `user_device_measure_period`, `user_device_date_from`, `action_type_id`, `device_units`, `mqtt_topic_write`, `mqtt_topic_read`, `mqqt_server_id`, `unit_id`, `factor_id`, `description`, `device_log`, `device_pass`, `measure_data_type`) VALUES
	(1, 1, 'UniPing RS-485', 'Однократное измерение', 'ежесекундно', '2017-03-03 18:43:27', 1, '°С', '/kalistrat1/detector1', '', 3, 96, 64, 'UniPing RS-485 xxxxx', 'kalistrat1', '7345345', 'число'),
	(2, 1, 'HWg-STE', 'Периодическое измерение', 'ежегодно', '2017-02-28 18:32:52', 1, '°С x 10e2', '/kalistrat1/detector2', '', 3, 95, 66, 'Это описание устройства HWg-STE. Максимальная длина 200 символов fdfdf', 'kalistrat1', '7345345', 'число'),
	(3, 1, 'Logitech HD Webcam C270', NULL, NULL, NULL, 2, NULL, '/kalistrat1/actuator3', '', 3, NULL, NULL, 'Logitech HD Webcam C270 максимальная длина 200 символов', 'kalistrat1', '7345345', 'текст'),
	(4, 1, 'Microsoft LifeCam HD-3000', NULL, NULL, NULL, 2, NULL, '/kalistrat1/actuator4', '', 3, NULL, NULL, 'Microsoft LifeCam HD-3000', 'kalistrat1', '7345345', 'текст'),
	(37, 1, 'термометр-1', NULL, 'не задано', '2017-07-12 14:05:51', 1, 'Ед', '/garage1/temp1', '', 3, 96, 64, 'термометр-1', 'garage1', '123123123', 'текст'),
	(39, 1, 'wer', NULL, 'не задано', '2017-07-12 14:52:19', 2, 'Ед', '/garage1/wer1', '', 3, 96, 64, 'wer', 'garage1', '123123123', 'текст'),
	(42, 1, 'qwer2', NULL, 'не задано', '2017-07-12 15:43:06', 1, 'Ед', '/kalistrat1/wer1', '42', 3, 96, 64, 'qwer2', 'kalistrat1', '7345345', 'текст'),
	(43, 1, 'Измеритель1', NULL, 'не задано', '2017-07-19 16:59:57', 1, 'Ед', '/garage1/measurer1', '43', 3, 96, 64, 'Измеритель1', 'garage1', '123123123', 'число'),
	(44, 1, 'tes1', NULL, 'не задано', '2017-10-27 01:35:27', 1, 'Ед', '/testable/tes1', '44', 3, 96, 64, 'tes1', 'testable', 'testable', 'текст');
/*!40000 ALTER TABLE `user_device` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_devices_tree
CREATE TABLE IF NOT EXISTS `user_devices_tree` (
  `user_devices_tree_id` int(11) NOT NULL AUTO_INCREMENT,
  `leaf_id` int(11) NOT NULL,
  `parent_leaf_id` int(11) DEFAULT NULL,
  `user_device_id` int(11) DEFAULT NULL,
  `leaf_name` varchar(30) NOT NULL,
  `user_id` int(11) NOT NULL,
  `timezone_id` int(11) DEFAULT NULL,
  `mqtt_server_id` int(11) DEFAULT NULL,
  `time_topic` varchar(150) DEFAULT NULL,
  `sync_interval` int(11) DEFAULT NULL,
  `control_log` varchar(50) DEFAULT NULL,
  `control_pass` varchar(50) DEFAULT NULL,
  `control_pass_sha` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`user_devices_tree_id`),
  KEY `FK_user_devices_tree_user_device` (`user_device_id`),
  KEY `FK_user_devices_tree_users` (`user_id`),
  KEY `FK_user_devices_tree_timezones` (`timezone_id`),
  KEY `FK_user_devices_tree_mqtt_servers` (`mqtt_server_id`),
  KEY `CONTROL_LOG_IN_INDX` (`control_log`),
  CONSTRAINT `FK_user_devices_tree_mqtt_servers` FOREIGN KEY (`mqtt_server_id`) REFERENCES `mqtt_servers` (`server_id`),
  CONSTRAINT `FK_user_devices_tree_timezones` FOREIGN KEY (`timezone_id`) REFERENCES `timezones` (`timezone_id`),
  CONSTRAINT `FK_user_devices_tree_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `FK_user_devices_tree_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=187 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_devices_tree: ~19 rows (приблизительно)
DELETE FROM `user_devices_tree`;
/*!40000 ALTER TABLE `user_devices_tree` DISABLE KEYS */;
INSERT INTO `user_devices_tree` (`user_devices_tree_id`, `leaf_id`, `parent_leaf_id`, `user_device_id`, `leaf_name`, `user_id`, `timezone_id`, `mqtt_server_id`, `time_topic`, `sync_interval`, `control_log`, `control_pass`, `control_pass_sha`) VALUES
	(1, 1, NULL, NULL, 'Устройства', 1, 17, 3, '', 0, '', '', ''),
	(5, 2, 1, NULL, 'Кухня', 1, 19, 3, '/kalistrat1/synctime', 5, 'kalistrat1', '7345345', '7fac25fd39a90cec55cdce1a44f804aa26f0506b2abf696de559b99f38393e1f'),
	(6, 3, 2, 3, 'Logitech HD Webcam C270', 1, 17, 3, '/kalistrat1/synctime', 0, 'kalistrat1', '7345345', '7fac25fd39a90cec55cdce1a44f804aa26f0506b2abf696de559b99f38393e1f'),
	(7, 4, 2, 2, 'HWg-STE', 1, 17, 3, '/kalistrat1/synctime', 0, 'kalistrat1', '7345345', '7fac25fd39a90cec55cdce1a44f804aa26f0506b2abf696de559b99f38393e1f'),
	(40, 5, 2, 4, 'Microsoft LifeCam HD-3000', 1, 17, 3, '/kalistrat1/synctime', 0, 'kalistrat1', '7345345', '7fac25fd39a90cec55cdce1a44f804aa26f0506b2abf696de559b99f38393e1f'),
	(41, 6, 2, 1, 'UniPing RS-485', 1, 17, 3, '/kalistrat1/synctime', 0, 'kalistrat1', '7345345', '7fac25fd39a90cec55cdce1a44f804aa26f0506b2abf696de559b99f38393e1f'),
	(146, 1, NULL, NULL, 'Устройства', 2, 17, 3, '', 0, '', '', ''),
	(170, 7, 1, NULL, 'Гараж', 1, 17, 3, '/garage1/synctime', 1, 'garage1', '123123123', '932f3c1b56257ce8539ac269d7aab42550dacf8818d075f0bdf1990562aae3ef'),
	(171, 8, 7, 37, 'термометр-1', 1, 17, 3, '/garage1/synctime', 1, 'garage1', '123123123', '932f3c1b56257ce8539ac269d7aab42550dacf8818d075f0bdf1990562aae3ef'),
	(173, 9, 7, 39, 'wer', 1, 17, 3, '/garage1/synctime', 1, 'garage1', '123123123', '932f3c1b56257ce8539ac269d7aab42550dacf8818d075f0bdf1990562aae3ef'),
	(176, 10, 2, 42, 'qwer2', 1, 17, 3, '/kalistrat1/synctime', 0, 'kalistrat1', '7345345', '7fac25fd39a90cec55cdce1a44f804aa26f0506b2abf696de559b99f38393e1f'),
	(178, 1, NULL, NULL, 'Устройства', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(179, 1, NULL, NULL, 'Устройства', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(180, 2, 1, NULL, 'qwe', 5, 17, 3, '/qwe123/synctime', 0, 'qwe123', '123123', '96cae35ce8a9b0244178bf28e4966c2ce1b8385723a96a6b838858cdd6ca0a1e'),
	(181, 1, NULL, NULL, 'Устройства', 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(182, 1, NULL, NULL, 'Устройства', 7, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(184, 11, 7, 43, 'Измеритель1', 1, 17, 3, '/garage1/synctime', 1, 'garage1', '123123123', '932f3c1b56257ce8539ac269d7aab42550dacf8818d075f0bdf1990562aae3ef'),
	(185, 12, 1, NULL, 'testable', 1, 17, 3, '/testable/synctime', 1, 'testable', 'testable', '408bc0bc6063c1add7d79404087b90dec06235915649d1073b0e872a5a80eedc'),
	(186, 13, 12, 44, 'tes1', 1, 17, 3, '/testable/synctime', 0, 'testable', 'testable', '408bc0bc6063c1add7d79404087b90dec06235915649d1073b0e872a5a80eedc');
/*!40000 ALTER TABLE `user_devices_tree` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_device_measures
CREATE TABLE IF NOT EXISTS `user_device_measures` (
  `user_device_measure_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_device_id` int(11) NOT NULL,
  `measure_value` double(10,2) DEFAULT NULL,
  `measure_date` datetime DEFAULT NULL,
  `measure_mess` varchar(255) DEFAULT NULL,
  `measure_date_value` datetime DEFAULT NULL,
  PRIMARY KEY (`user_device_measure_id`),
  KEY `FK_user_device_measures_user_device` (`user_device_id`),
  CONSTRAINT `FK_user_device_measures_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10017 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_device_measures: ~254 rows (приблизительно)
DELETE FROM `user_device_measures`;
/*!40000 ALTER TABLE `user_device_measures` DISABLE KEYS */;
INSERT INTO `user_device_measures` (`user_device_measure_id`, `user_device_id`, `measure_value`, `measure_date`, `measure_mess`, `measure_date_value`) VALUES
	(1, 2, 21.00, '2017-01-18 18:19:40', '21', NULL),
	(2, 2, 25.00, '2017-01-19 18:20:13', '25', NULL),
	(3, 2, 22.00, '2017-01-20 18:20:33', '22', NULL),
	(4, 2, 27.00, '2017-01-21 18:20:49', '27', NULL),
	(5, 2, 15.00, '2017-01-22 18:21:05', '15', NULL),
	(6, 2, 24.00, '2017-01-23 18:21:21', '24', NULL),
	(7, 1, 10.00, '2017-01-23 10:21:42', '10', NULL),
	(8, 1, 7.00, '2017-01-23 12:21:54', '7', NULL),
	(9, 1, 15.00, '2017-01-23 14:22:05', '15', NULL),
	(10, 1, 17.00, '2017-01-23 16:22:15', '17', NULL),
	(11, 1, 20.54, '2017-01-23 18:22:30', '20.54', NULL),
	(12, 2, 34.00, '2017-01-26 19:22:47', '34', NULL),
	(13, 2, 34.00, '2017-01-26 19:22:57', '34', NULL),
	(14, 2, 56.00, '2017-01-26 19:23:06', '56', NULL),
	(15, 2, 45.00, '2017-01-26 19:23:15', '45', NULL),
	(16, 2, 34.00, '2017-01-26 19:23:23', '34', NULL),
	(17, 2, 35.00, '2017-01-26 19:23:35', '35', NULL),
	(18, 2, 44.21, '2017-01-26 19:23:46', '44.21', NULL),
	(19, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(20, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(21, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(22, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(23, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(24, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(25, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(26, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(27, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(28, 1, 20.00, '2017-05-20 15:10:22', '20', NULL),
	(29, 1, 25.00, '2017-05-20 15:11:58', '25', NULL),
	(30, 1, 25.00, '2017-05-20 15:11:58', '25', NULL),
	(31, 1, 25.00, '2017-05-20 15:11:58', '25', NULL),
	(32, 1, 25.00, '2017-05-20 15:11:58', '25', NULL),
	(33, 1, 25.00, '2017-05-20 15:11:58', '25', NULL),
	(34, 1, 25.00, '2017-05-20 15:11:58', '25', NULL),
	(35, 1, 25.00, '2017-05-20 15:11:58', '25', NULL),
	(36, 1, 25.00, '2017-05-20 15:11:58', '25', NULL),
	(37, 1, 25.00, '2017-05-20 15:11:58', '25', NULL),
	(38, 1, 25.00, '2017-05-20 15:11:59', '25', NULL),
	(39, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(40, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(41, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(42, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(43, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(44, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(45, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(46, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(47, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(48, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(49, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(50, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(51, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(52, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(53, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(54, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(55, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(56, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(57, 1, 25.00, '2017-05-20 15:14:57', '25', NULL),
	(58, 2, 18.00, '2017-05-20 15:14:57', '18', NULL),
	(59, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(60, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(61, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(62, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(63, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(64, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(65, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(66, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(67, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(68, 1, 25.00, '2017-05-20 15:17:36', '25', NULL),
	(69, 1, 20.00, '2017-05-20 15:31:53', '20', NULL),
	(70, 1, 20.00, '2017-05-20 15:31:53', '20', NULL),
	(71, 1, 20.00, '2017-05-20 15:31:53', '20', NULL),
	(72, 1, 20.00, '2017-05-20 15:31:53', '20', NULL),
	(73, 1, 20.00, '2017-05-20 15:31:53', '20', NULL),
	(74, 1, 20.00, '2017-05-20 15:31:53', '20', NULL),
	(75, 1, 20.00, '2017-05-20 15:31:54', '20', NULL),
	(76, 1, 20.00, '2017-05-20 15:31:54', '20', NULL),
	(77, 1, 20.00, '2017-05-20 15:31:54', '20', NULL),
	(78, 1, 20.00, '2017-05-20 15:31:54', '20', NULL),
	(79, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(80, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(81, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(82, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(83, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(84, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(85, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(86, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(87, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(88, 1, 20.00, '2017-05-20 15:32:27', '20', NULL),
	(89, 1, 11.00, '2017-05-20 19:05:13', '11', NULL),
	(90, 2, 22.00, '2017-05-20 19:05:13', '22', NULL),
	(91, 1, 11.00, '2017-05-20 19:05:13', '11', NULL),
	(92, 2, 22.00, '2017-05-20 19:05:13', '22', NULL),
	(93, 1, 11.00, '2017-05-20 19:05:13', '11', NULL),
	(94, 2, 22.00, '2017-05-20 19:05:13', '22', NULL),
	(95, 1, 11.00, '2017-05-20 19:05:13', '11', NULL),
	(96, 2, 22.00, '2017-05-20 19:05:13', '22', NULL),
	(97, 1, 11.00, '2017-05-20 19:05:13', '11', NULL),
	(98, 2, 22.00, '2017-05-20 19:05:13', '22', NULL),
	(99, 1, 11.00, '2017-05-20 19:05:13', '11', NULL),
	(100, 2, 22.00, '2017-05-20 19:05:13', '22', NULL),
	(101, 1, 11.00, '2017-05-20 19:05:13', '11', NULL),
	(102, 2, 22.00, '2017-05-20 19:05:13', '22', NULL),
	(103, 1, 11.00, '2017-05-20 19:05:13', '11', NULL),
	(104, 2, 22.00, '2017-05-20 19:05:13', '22', NULL),
	(105, 1, 11.00, '2017-05-20 19:05:13', '11', NULL),
	(106, 2, 22.00, '2017-05-20 19:05:13', '22', NULL),
	(107, 1, 11.00, '2017-05-20 19:05:14', '11', NULL),
	(108, 2, 22.00, '2017-05-20 19:05:14', '22', NULL),
	(109, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(110, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(111, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(112, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(113, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(114, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(115, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(116, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(117, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(118, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(119, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(120, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(121, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(122, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(123, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(124, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(125, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(126, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(127, 1, 11.00, '2017-06-07 23:22:38', '11', NULL),
	(128, 2, 22.00, '2017-06-07 23:22:38', '22', NULL),
	(129, 1, 11.00, '2017-06-07 23:25:46', '11', NULL),
	(130, 2, 22.00, '2017-06-07 23:25:46', '22', NULL),
	(131, 1, 11.00, '2017-06-07 23:25:46', '11', NULL),
	(132, 2, 22.00, '2017-06-07 23:25:46', '22', NULL),
	(133, 1, 11.00, '2017-06-07 23:25:46', '11', NULL),
	(134, 2, 22.00, '2017-06-07 23:25:47', '22', NULL),
	(135, 1, 11.00, '2017-06-07 23:25:47', '11', NULL),
	(136, 2, 22.00, '2017-06-07 23:25:47', '22', NULL),
	(137, 1, 11.00, '2017-06-07 23:25:47', '11', NULL),
	(138, 2, 22.00, '2017-06-07 23:25:47', '22', NULL),
	(139, 1, 11.00, '2017-06-07 23:25:47', '11', NULL),
	(140, 2, 22.00, '2017-06-07 23:25:47', '22', NULL),
	(141, 1, 11.00, '2017-06-07 23:25:47', '11', NULL),
	(142, 2, 22.00, '2017-06-07 23:25:47', '22', NULL),
	(143, 1, 11.00, '2017-06-07 23:25:47', '11', NULL),
	(144, 2, 22.00, '2017-06-07 23:25:47', '22', NULL),
	(145, 1, 11.00, '2017-06-07 23:25:47', '11', NULL),
	(146, 2, 22.00, '2017-06-07 23:25:47', '22', NULL),
	(147, 1, 11.00, '2017-06-07 23:25:47', '11', NULL),
	(148, 2, 22.00, '2017-06-07 23:25:47', '22', NULL),
	(149, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(150, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(151, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(152, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(153, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(154, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(155, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(156, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(157, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(158, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(159, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(160, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(161, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(162, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(163, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(164, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(165, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(166, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(167, 1, 11.00, '2017-06-07 23:33:35', '11', NULL),
	(168, 2, 22.00, '2017-06-07 23:33:35', '22', NULL),
	(169, 1, 11.00, '2017-06-07 23:37:31', '11', NULL),
	(170, 2, 22.00, '2017-06-07 23:37:31', '22', NULL),
	(171, 1, 11.00, '2017-06-07 23:37:32', '11', NULL),
	(172, 2, 22.00, '2017-06-07 23:37:32', '22', NULL),
	(173, 1, 11.00, '2017-06-07 23:37:32', '11', NULL),
	(174, 2, 22.00, '2017-06-07 23:37:32', '22', NULL),
	(175, 1, 11.00, '2017-06-07 23:37:32', '11', NULL),
	(176, 2, 22.00, '2017-06-07 23:37:32', '22', NULL),
	(177, 1, 11.00, '2017-06-07 23:37:32', '11', NULL),
	(178, 2, 22.00, '2017-06-07 23:37:32', '22', NULL),
	(179, 1, 11.00, '2017-06-07 23:37:32', '11', NULL),
	(180, 2, 22.00, '2017-06-07 23:37:32', '22', NULL),
	(181, 1, 11.00, '2017-06-07 23:37:32', '11', NULL),
	(182, 2, 22.00, '2017-06-07 23:37:32', '22', NULL),
	(183, 1, 11.00, '2017-06-07 23:37:32', '11', NULL),
	(184, 2, 22.00, '2017-06-07 23:37:32', '22', NULL),
	(185, 1, 11.00, '2017-06-07 23:37:32', '11', NULL),
	(186, 2, 22.00, '2017-06-07 23:37:32', '22', NULL),
	(187, 1, 11.00, '2017-06-07 23:37:32', '11', NULL),
	(188, 2, 22.00, '2017-06-07 23:37:32', '22', NULL),
	(189, 1, 11.00, '2017-06-07 23:39:13', '11', NULL),
	(190, 2, 22.00, '2017-06-07 23:39:13', '22', NULL),
	(191, 2, 22.00, '2017-06-07 23:43:04', '22', NULL),
	(192, 1, 11.00, '2017-06-07 23:43:04', '11', NULL),
	(193, 1, 11.00, '2017-06-07 23:45:11', '11', NULL),
	(194, 2, 22.00, '2017-06-07 23:45:11', '22', NULL),
	(195, 1, 11.00, '2017-06-08 00:22:16', '11', NULL),
	(196, 2, 22.00, '2017-06-08 00:22:16', '22', NULL),
	(197, 2, 22.00, '2017-06-09 00:25:32', '22', NULL),
	(198, 1, 11.00, '2017-06-09 00:25:32', '11', NULL),
	(199, 1, 11.00, '2017-06-09 00:31:20', '11', NULL),
	(200, 2, 22.00, '2017-06-09 00:31:20', '22', NULL),
	(201, 1, 0.00, '2017-06-11 20:42:44', '0', NULL),
	(202, 2, 4.00, '2017-06-11 20:43:11', '4', NULL),
	(203, 1, 4.00, '2017-06-11 20:43:45', '4', NULL),
	(204, 1, 2.00, '2017-06-11 20:45:59', '2', NULL),
	(205, 37, NULL, '2010-07-30 00:00:00', 'cleorus', NULL),
	(206, 37, NULL, '2017-07-12 00:00:00', 'cleorus', NULL),
	(207, 37, NULL, '2017-07-12 00:00:00', 'cleorus', NULL),
	(208, 37, NULL, '2017-07-12 17:10:33', 'cleorus', NULL),
	(209, 37, NULL, '2017-07-12 17:12:10', 'cleorus', NULL),
	(210, 37, NULL, '2017-07-12 17:14:24', '23.2', NULL),
	(211, 37, NULL, '2017-07-12 17:15:20', '23,2', NULL),
	(212, 37, NULL, '2017-07-12 17:16:25', '23,2', NULL),
	(213, 37, 23.20, '2017-07-12 17:17:24', '23,2', NULL),
	(214, 37, 23.92, '2017-07-12 17:17:47', '23.92', NULL),
	(215, 37, 23.00, '2017-07-12 17:18:07', '23', NULL),
	(216, 37, 23.00, '2017-07-12 17:18:21', '23.00', NULL),
	(217, 37, 23.01, '2017-07-12 17:18:36', '23.006', NULL),
	(218, 37, 23.01, '2017-07-19 12:44:50', '23.006', NULL),
	(219, 37, 777.00, '2017-07-19 12:45:47', '777', NULL),
	(220, 37, NULL, '2017-07-19 15:29:05', NULL, '2017-07-19 15:29:11'),
	(9960, 42, NULL, '2017-09-06 14:33:10', '25', NULL),
	(9961, 42, NULL, '2017-09-06 14:34:04', '25', NULL),
	(9962, 42, NULL, '2017-09-06 14:34:31', '25', NULL),
	(9963, 42, NULL, '2017-09-06 15:51:58', '27', NULL),
	(9964, 42, NULL, '2017-09-06 17:14:52', '27', NULL),
	(9966, 37, NULL, '2017-09-08 16:00:25', '27', NULL),
	(9967, 1, 27.00, '2017-09-08 16:00:25', '27', NULL),
	(9968, 2, 27.00, '2017-09-08 16:00:25', '27', NULL),
	(9969, 42, NULL, '2017-09-08 16:00:25', '27', NULL),
	(9971, 37, NULL, '2017-09-08 16:01:52', '27', NULL),
	(9972, 1, 27.00, '2017-09-08 16:01:52', '27', NULL),
	(9973, 2, 27.00, '2017-09-08 16:01:52', '27', NULL),
	(9974, 42, NULL, '2017-09-08 16:01:52', '27', NULL),
	(9976, 37, NULL, '2017-09-08 16:03:07', '27', NULL),
	(9977, 1, 27.00, '2017-09-08 16:03:07', '27', NULL),
	(9978, 2, 27.00, '2017-09-08 16:03:07', '27', NULL),
	(9979, 42, NULL, '2017-09-08 16:03:07', '27', NULL),
	(9981, 37, NULL, '2017-09-08 16:03:33', '27', NULL),
	(9982, 1, 27.00, '2017-09-08 16:03:33', '27', NULL),
	(9983, 2, 27.00, '2017-09-08 16:03:33', '27', NULL),
	(9984, 42, NULL, '2017-09-08 16:03:33', '27', NULL),
	(9986, 37, NULL, '2017-09-08 16:04:13', '27', NULL),
	(9987, 1, 27.00, '2017-09-08 16:04:13', '27', NULL),
	(9988, 2, 27.00, '2017-09-08 16:04:13', '27', NULL),
	(9989, 42, NULL, '2017-09-08 16:04:13', '27', NULL),
	(9997, 43, NULL, '2017-10-18 12:23:43', 'вап', NULL),
	(10009, 43, 567.00, '1973-02-25 06:04:13', NULL, NULL),
	(10010, 43, 567.67, '1973-02-25 06:04:13', NULL, NULL),
	(10011, 43, 567.67, '2017-10-18 12:49:10', NULL, NULL),
	(10012, 43, 567.67, '2017-10-18 13:50:06', NULL, NULL),
	(10013, 43, NULL, '2017-10-26 23:40:14', '', NULL),
	(10014, 43, 123.00, '2017-10-26 23:40:26', NULL, NULL),
	(10015, 43, 123.00, '2017-10-26 23:50:15', NULL, NULL),
	(10016, 43, 456.00, '2017-10-26 23:50:25', NULL, NULL);
/*!40000 ALTER TABLE `user_device_measures` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_device_state_notification
CREATE TABLE IF NOT EXISTS `user_device_state_notification` (
  `user_state_notification_id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_type_id` int(11) DEFAULT NULL,
  `user_actuator_state_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_state_notification_id`),
  KEY `FK_user_device_state_notification_notification_type` (`notification_type_id`),
  KEY `FK_user_device_state_notification_user_actuator_state` (`user_actuator_state_id`),
  CONSTRAINT `FK_user_device_state_notification_notification_type` FOREIGN KEY (`notification_type_id`) REFERENCES `notification_type` (`notification_type_id`),
  CONSTRAINT `FK_user_device_state_notification_user_actuator_state` FOREIGN KEY (`user_actuator_state_id`) REFERENCES `user_actuator_state` (`user_actuator_state_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_device_state_notification: ~2 rows (приблизительно)
DELETE FROM `user_device_state_notification`;
/*!40000 ALTER TABLE `user_device_state_notification` DISABLE KEYS */;
INSERT INTO `user_device_state_notification` (`user_state_notification_id`, `notification_type_id`, `user_actuator_state_id`) VALUES
	(1, 1, 15),
	(2, 2, 15);
/*!40000 ALTER TABLE `user_device_state_notification` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_device_task
CREATE TABLE IF NOT EXISTS `user_device_task` (
  `user_device_task_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_device_id` int(11) DEFAULT NULL,
  `task_type_id` int(11) DEFAULT NULL,
  `task_interval` int(11) DEFAULT NULL,
  `interval_type` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`user_device_task_id`),
  KEY `FK_user_device_task_user_device` (`user_device_id`),
  KEY `FK_user_device_task_task_type` (`task_type_id`),
  CONSTRAINT `FK_user_device_task_task_type` FOREIGN KEY (`task_type_id`) REFERENCES `task_type` (`task_type_id`),
  CONSTRAINT `FK_user_device_task_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_device_task: ~3 rows (приблизительно)
DELETE FROM `user_device_task`;
/*!40000 ALTER TABLE `user_device_task` DISABLE KEYS */;
INSERT INTO `user_device_task` (`user_device_task_id`, `user_device_id`, `task_type_id`, `task_interval`, `interval_type`) VALUES
	(1, 2, 1, 1, 'DAYS'),
	(3, 43, 1, 1, 'DAYS'),
	(4, 44, 1, 5, 'SECONDS');
/*!40000 ALTER TABLE `user_device_task` ENABLE KEYS */;


-- Дамп структуры для таблица things.user_state_condition_vars
CREATE TABLE IF NOT EXISTS `user_state_condition_vars` (
  `state_condition_vars_id` int(11) NOT NULL AUTO_INCREMENT,
  `actuator_state_condition_id` int(11) DEFAULT NULL,
  `var_code` varchar(20) DEFAULT NULL,
  `user_device_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`state_condition_vars_id`),
  KEY `FK_user_state_condition_vars_user_actuator_state_condition` (`actuator_state_condition_id`),
  KEY `FK_user_state_condition_vars_user_device` (`user_device_id`),
  CONSTRAINT `FK_user_state_condition_vars_user_actuator_state_condition` FOREIGN KEY (`actuator_state_condition_id`) REFERENCES `user_actuator_state_condition` (`actuator_state_condition_id`),
  CONSTRAINT `FK_user_state_condition_vars_user_device` FOREIGN KEY (`user_device_id`) REFERENCES `user_device` (`user_device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы things.user_state_condition_vars: ~5 rows (приблизительно)
DELETE FROM `user_state_condition_vars`;
/*!40000 ALTER TABLE `user_state_condition_vars` DISABLE KEYS */;
INSERT INTO `user_state_condition_vars` (`state_condition_vars_id`, `actuator_state_condition_id`, `var_code`, `user_device_id`) VALUES
	(1, 1, 'a', 2),
	(2, 1, 'b', 1),
	(7, 4, 'm', 2),
	(8, 4, 'n', 2),
	(9, 5, 'm', 1);
/*!40000 ALTER TABLE `user_state_condition_vars` ENABLE KEYS */;


-- Дамп структуры для функция things.w_task_device_list
DELIMITER //
CREATE DEFINER=`kalistrat`@`localhost` FUNCTION `w_task_device_list`(
	`eUserDeviceId` int

) RETURNS text CHARSET utf8
begin
return(
select ifnull(concat(
'<task_device_list>'
,group_concat(concat(
'<task_data>'
,'<task_id>',udt.user_device_task_id,'</task_id>'
,'</task_data>'
) separator ''
)
,'</task_device_list>'
),'<task_device_list/>')
from user_device ud
join user_device_task udt on udt.user_device_id=ud.user_device_id
where ud.user_device_id = eUserDeviceId
);
end//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
