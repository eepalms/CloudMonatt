USE oat_db;

CREATE TABLE `PCR_manifest` (
  `index` int(11) NOT NULL AUTO_INCREMENT,
  `PCR_number` int(11) DEFAULT NULL,
  `PCR_value` varchar(100) DEFAULT NULL,
  `PCR_desc` varchar(100) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `create_request_host` varchar(50) DEFAULT NULL,
  `last_update_time` datetime DEFAULT NULL,
  `last_update_request_host` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`index`),
  UNIQUE KEY `PCR_UNIQUE` (`PCR_number`,`PCR_value`)
);

CREATE TABLE `attest_request` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` varchar(50) DEFAULT NULL,
  `host_name` varchar(50) DEFAULT NULL,
  `request_time` datetime DEFAULT NULL,
  `next_action` int(11) DEFAULT NULL,
  `is_consumed_by_pollingWS` tinyint(1) DEFAULT NULL,
  `audit_log_id` int(11) DEFAULT NULL,
  `host_id` int(11) DEFAULT NULL,
  `request_host` varchar(50) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `PCRMask` varchar(50) DEFAULT NULL,
  `result` int(11) DEFAULT NULL,
  `is_sync` tinyint(1) DEFAULT NULL,
  `validate_time` datetime DEFAULT NULL, 
  `security_property` varchar(50) DEFAULT NULL,
  `vm_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_audit_log_id` (`audit_log_id`),
  KEY `UNIQUE` (`request_id`,`host_id`)
);



/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2012/9/7 10:13:55                            */
/*==============================================================*/


drop table if exists HOST;

drop table if exists MLE;

drop table if exists OEM;

drop table if exists OS;

drop table if exists PCR_WHITE_LIST;


/*==============================================================*/
/* Table: HOST                                                  */
/*==============================================================*/
create table HOST
(
   ID                   int not null auto_increment,
   HOST_NAME            varchar(50),
   IP_ADDRESS           varchar(50),
   PORT                 varchar(50),
   EMAIL                varchar(100),
   ADDON_CONNECTION_STRING varchar(100),
   DESCRIPTION          varchar(100),
   primary key (ID)
);

/*==============================================================*/
/* Table: MLE                                                   */
/*==============================================================*/
create table MLE
(
   ID                   int not null auto_increment,
   OEM_ID               int,
   OS_ID                int,
   NAME                 varchar(50),
   VERSION              varchar(100),
   ATTESTATION_TYPE     varchar(50),
   MLE_TYPE             varchar(50),
   DESCRIPTION          varchar(100),
   primary key (ID)
);

/*==============================================================*/
/* Table: HOST_MLE                                              */
/*==============================================================*/
create table HOST_MLE
(
   ID int not null auto_increment,
   HOST_ID int ,
   MLE_ID int ,
   primary key (ID) ,
   FOREIGN KEY (HOST_ID) REFERENCES HOST(ID) ON DELETE CASCADE ,
   CONSTRAINT mle_fk FOREIGN KEY (MLE_ID) REFERENCES MLE(ID)
);


/*==============================================================*/
/* Table: OEM                                                   */
/*==============================================================*/
create table OEM
(
   ID                   int not null auto_increment,
   NAME                 varchar(50),
   DESCRIPTION          varchar(100),
   primary key (ID)
);

/*==============================================================*/
/* Table: OS                                                    */
/*==============================================================*/
create table OS
(
   ID                   int not null auto_increment,
   NAME                 varchar(50),
   VERSION              varchar(50),
   DESCRIPTION          varchar(100),
   primary key (ID)
);

/*==============================================================*/
/* Table: PCR_WHITE_LIST                                        */
/*==============================================================*/
create table PCR_WHITE_LIST
(
   ID                   int not null auto_increment,
   MLE_ID               int,
   PCR_NAME             varchar(10),
   PCR_DIGEST           varchar(100) default NULL,
   primary key (ID)
);

/*==============================================================*/
/* End 								*/
/*==============================================================*/
