-- ******************************************************
-- efangfp_2014.sql
--
-- Loader for Final Project Database
--
-- Description:	This script contains the DDL to load
--              the tables of the
--              MOTORLAB_SUBJECT database
--
-- There are 14 tables in this DB
--
-- Student:  Emerson Fang
--
-- Date:   November, 2014
--
-- ******************************************************
--    SPOOL SESSION
-- ******************************************************

echo on
spool efang2014fp.lst

-- ******************************************************
--    DROP TABLES
-- Note:  Issue the appropiate commands to drop tables
-- ******************************************************
DROP view PAYMENTS_VIEW;
drop view totalpaidpersubject;
DROP table tbmeasurement purge;
DROP table tbmeasure_type purge;
DROP table tbparticipant_note purge;
DROP table tbnotetype purge;
DROP table tbexp_vers_participation purge;
DROP table tbpolarity_type purge;
DROP table tbexp_version purge;
DROP table tbsubject_address purge;
DROP table tbsubject_email purge;
DROP table tbsubject_phone purge;
DROP table tbsubject purge;
DROP table tbexperiment purge;
DROP table tbexperiment_type purge;
DROP table tbresearcher purge;

-- ******************************************************
--    DROP SEQUENCES
-- Note:  Issue the appropiate commands to drop sequences
-- ******************************************************

--DROP sequence seqsubject;

-- ******************************************************
--    CREATE TABLES
-- ******************************************************

CREATE table tbresearcher (
        researcherid      char(3)                 NOT NULL
          CONSTRAINT researcherid_ck CHECK (researcherid between 0 and 999 )
          CONSTRAINT pk_researcher PRIMARY KEY,
        researcher_lastname    varchar2(40)          NOT NULL,
        researcher_firstname    varchar2(40)          NOT NULL
);

CREATE table tbsubject (
        subjectid       char(6)                 not null
          constraint subjectid_ck CHECK (subjectid between 000000 and 999999 )
          constraint pk_subject primary key,
        subject_lastname    varchar2(40)          NOT NULL,
        subject_firstname    varchar2(40)          NOT NULL
);


/*how to specify only certain character combinations in tbsubjectphone for phone type?*/
CREATE table tbsubject_phone (
        subjectid       char(6)                 not null,
        lineno          numeric(38,0)                 null,
        phoneno         char(10)                null,
        phonetype       char(20)                null,
        constraint lineno_ck CHECK (lineno between 000 and 999 ),
        constraint phoneno_ck CHECK (phoneno between 0000000000 and 9999999999),
        constraint fk_subjectid_tbsubjectphone FOREIGN KEY (subjectid) references tbsubject(subjectid) on delete cascade,
        constraint pk_subjectphone PRIMARY KEY (subjectid, lineno)
);

/*how to check that no two e-mails are the same, and there is an @ symbol?*/
/*SELECT
    name, email, COUNT(*)
FROM
    users
GROUP BY
    name, email
HAVING 
    COUNT(*) > 1
    */
CREATE table tbsubject_email (
        subjectid       char(6)                 not null,
        emailno         numeric(38,0)                 null,
        subjectemail    char(100)                null
          constraint subjectemail_ck check (subjectemail like ('%@%.%')),
        constraint email_ck CHECK (emailno between 000 and 999 ),
        constraint fk_subjectid_tbsubjectemail FOREIGN KEY (subjectid) references tbsubject(subjectid) on delete cascade,
        constraint pk_subjectemail PRIMARY KEY (subjectid, emailno)
);

/*make sure constraints for addresses are appropriate - i.e. state abbreviations?*/
CREATE table tbsubject_address (
        subjectid     char(6)                  not null,
        addressno     numeric(38,0)                  not null,
        streetnumber  char(50)                 null,
        streetname    char(100)                null,
        city          char(100)                null,
        state         char(2)                  null,
        zip           char(5)                  null,
        addresstype   char(20)                 null,
        constraint addressno_ck CHECK (addressno between 000 and 999 ),
        constraint fk_subjectid_tbsubjectaddress FOREIGN KEY(subjectid) references tbsubject(subjectid) on delete cascade,
        constraint pk_subjectaddress PRIMARY KEY (subjectid, addressno)
);

CREATE table tbexperiment_type (
        exptype       char(4)   not null,
        exptype_description char(100) not null,
        constraint pk_tbexperiment_type PRIMARY KEY (exptype)
);

CREATE table tbexperiment (
        experimentid    char(4)              not null
          constraint experimentid_ck check (experimentid between 0 and 9999),
        exptype         char(4)                 not null,
        exp_polarityon  char(1)                 not null,
          CONSTRAINT polarityon_ck CHECK (exp_polarityon = '0' OR exp_polarityon = '1'),
        polarityDescription char(20)          null,
          constraint fk_exptype_tbexperiment FOREIGN KEY(exptype) references tbexperiment_type(exptype) on delete cascade,
          constraint pk_tbexperiment PRIMARY KEY (experimentid),
          constraint exppolarityon_ck check (
              exp_polarityon = 0 -- polarityDescription null or not null
              OR (exp_polarityon <> 0 AND polarityDescription IS NOT NULL)
              )
);
        
--SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'TBEXPERIMENT';        
        
CREATE table tbexp_version (
        experimentid    char(4)              not null,
          constraint fk_experimentid_tbexp_version foreign key (experimentid) references tbexperiment(experimentid) on delete cascade,
        versionID       numeric(38,0)            not null
          constraint versionID_ck check (versionID>=0),
        versionDescription  char(100)         not null,
          constraint pk_tbexp_version PRIMARY KEY (experimentid,versionID)
);

CREATE table tbpolarity_type (
        polarityType    char(1)             not null,
        polarity        char(8)             not null,
          constraint pk_tbpolarity_type PRIMARY KEY (polarityType)
);


CREATE table TBEXP_VERS_PARTICIPATION (
        experimentid    char(4)             not null,
        versionID       numeric(38,0)           not null,
        subjectid     char(6)               not null,
        polarityType    char(1)             not null,
        exp_particip_date date              null,
        start_time      timestamp                null,
        end_time        timestamp                null,
        payment         number(5,2)         not null
          constraint payment_ck check (payment between 0 and 600),
        gender          char(1)             not null
          constraint gender_ck check (gender in ('M', 'F', 'm', 'F')),
        matlab_initials   char(3)           not null,
        handedness        char(1)           not null
          constraint handedness_ck check (handedness in ('R', 'L', 'A', 'r', 'l', 'a')),
        hand_used         char(1)           not null
          constraint handused_ck check (hand_used in ('R', 'L', 'r', 'l')),
        age               char(3)           not null
          constraint age_ck check (age between 0 and 200),
        researcherID      char(3)           not null,
          constraint fk_expid_versid_tbexp_vers_par 
            foreign key (experimentid, versionID) references tbexp_version(experimentid,versionID) on delete cascade,
          constraint pk_expid_versID_subjid PRIMARY KEY (experimentid, versionID, subjectid),
          constraint fk_resID_tbexp_vers_part FOREIGN KEY (researcherID) references tbresearcher(researcherid) on delete cascade
);
              
alter table TBEXP_VERS_PARTICIPATION modify( exp_particip_date date default to_date(sysdate, 'dd-MON-yy'));

alter table TBEXP_VERS_PARTICIPATION add constraint fk_polType_tbexp_vers_part 
    foreign key (polarityType) references tbpolarity_type(polarityType) on delete cascade;
 
--alter table TBEXP_VERS_PARTICIPATION modify( start_time date default to_date(sysdate, 'dd-MON-yy'));
--alter table TBEXP_VERS_PARTICIPATION modify( end_time date default to_date(sysdate, 'dd-MON-yy'));

CREATE table tbnotetype (
      notetype  char(3) not null,
      meaning   char(20)  not null,
      constraint pk_notetype_tbnotetype primary key (notetype)
);


CREATE table TBPARTICIPANT_NOTE (
        experimentid    char(4)             not null,
        versionID       numeric(38,0)           not null,
        subjectid     char(6)               not null,
        noteno        numeric(38,0)               not null
          constraint noteno_ck check (noteno between 1 and 99999),
        note          char(100)             not null,
        notetype      char(3)               not null,
        notedate      date                  null,
        notetime      timestamp              null,
        researcherID      char(3)           not null,
          constraint fk_notetype_tbparticipant_note foreign key (notetype) references tbnotetype(notetype) on delete cascade,
          constraint fk_resID_tbpart_note foreign key (researcherid) references tbresearcher(researcherid) on delete cascade,
          constraint fk_eIDvIDsIDtbpart_note 
            foreign key (experimentid, versionid, subjectid) references TBEXP_VERS_PARTICIPATION(experimentid, versionID, subjectid) on delete cascade,
          constraint pk_eIDvIDsIDnNo_tbpn primary key (experimentid, versionID, subjectid, noteno)
);

alter table tbparticipant_note modify( notedate date default to_date(sysdate, 'dd-MON-yy'));

create table tbmeasure_type (
    measureType char(20)  not null,
    detail    char(100)   not null,
    units     char(10)    not null,
    constraint pk_measureType_tbmsrtype primary key (measureType)
);

create table tbmeasurement (
    experimentid    char(4)             not null,
    versionID       numeric(38,0)           not null,
    subjectid     char(6)               not null,
    measureNo     numeric(38,0)            not null
      constraint measureNo_ck check (measureNo > 0),
    dataNumber    number                null,
    dataChar      char                null,
    measureType char(20)  not null,
      constraint fk_measureType_tbmsrmnt foreign key (measureType) references tbmeasure_type(measureType) on delete cascade,
      constraint fk_eIDvIDsID_tbmsrmt
            foreign key (experimentid, versionid, subjectid) references TBEXP_VERS_PARTICIPATION(experimentid, versionID, subjectid) on delete cascade,
          constraint pk_eIDvIDsIDmNo primary key (experimentid, versionID, subjectid, measureNo) 
);

-- ******************************************************
--    CREATE SEQUENCES
-- ******************************************************

--none--
    
-- ******************************************************
--    POPULATE TABLES
-- ******************************************************

/* inventory tbresearcher */
INSERT into tbresearcher values ('101', 'Waldo', 'Ralph');
INSERT into tbresearcher values ('102', 'Smith', 'Sam');
INSERT into tbresearcher values ('103', 'Bob', 'Joe');

/* inventory tbsubject */
INSERT into tbsubject values ('100000', 'Smith', 'Bob');
INSERT into tbsubject values ('000001', 'Harris', 'John');
INSERT into tbsubject values ('234500', 'Fey', 'Mia');

/* inventory tbsubject_phone */
INSERT into tbsubject_phone values ('100000', '1', '5555555555', 'Home');
INSERT into tbsubject_phone values ('000001', '1', '2345437890', 'Home');
INSERT into tbsubject_phone values ('000001', '2', '2345891348', 'Cell');
INSERT into tbsubject_phone values ('234500', '1', '1234567890', 'Cell');

/* inventory tbsubject_email */
INSERT into tbsubject_email (subjectid, emailno, subjectemail) values ('100000', '1', 'smith@smith.com');
INSERT into tbsubject_email (subjectid, emailno, subjectemail) values ('000001', '1', 'harris@harrisguy.net');
INSERT into tbsubject_email (subjectid, emailno, subjectemail) values ('000001', '2', 'crazyfrisbee@harris.com');
INSERT into tbsubject_email (subjectid, emailno, subjectemail) values ('234500', '1', 'feylawoffices@feylaw.com');

/* inventory tbsubject_address */
INSERT into tbsubject_address (subjectid, addressno, streetnumber, streetname, city, state, zip, addresstype) 
  values ('100000', '1', '100', 'Soldier''s Field Boulevard', 'Boston', 'MA', '23140', 'Home');
INSERT into tbsubject_address (subjectid, addressno, streetnumber, streetname, city, state, zip, addresstype) 
  values ('234500', '1', '230', 'West Street', 'Cambridge', 'MA', '23451', 'School');
INSERT into tbsubject_address (subjectid, addressno, streetnumber, streetname, city, state, zip, addresstype) 
  values ('234500', '2', '450', 'South Avenue', 'Allston', 'MA', '34231', 'Business');
INSERT into tbsubject_address (subjectid, addressno, streetnumber, streetname, city, state, zip, addresstype) 
  values ('000001', '1', '453', 'South Avenue', 'Allston', 'MA', '34231', 'Business');

/* inventory tbexperiment_type */
insert into tbexperiment_type (exptype, exptype_description) values ('VMR', 'Visuomotor Rotation Task');
insert into tbexperiment_type (exptype, exptype_description) values ('FF', 'Force-Field with Robot Arm');
insert into tbexperiment_type (exptype, exptype_description) values ('MM', 'Motor Math Task with Weighted Blocks');

/* inventory tbexperiment */
insert into tbexperiment (experimentid, exptype, exp_polarityon, polarityDescription) values ('1000', 'VMR', '1', 'cursor rotation');
insert into tbexperiment (experimentid, exptype, exp_polarityon, polarityDescription) values ('2000', 'FF', '1', 'Forcefield direction');
insert into tbexperiment (experimentid, exptype, exp_polarityon, polarityDescription) values ('3000', 'MM', '0', null);

/* inventory tbexp_version */
insert into tbexp_version (experimentid, versionID, versionDescription) values ('1000', '1', 'Sum of Sine Waves');
insert into tbexp_version (experimentid, versionID, versionDescription) values ('1000', '2', 'Sum of Sine Waves - 4 sine waves');
insert into tbexp_version (experimentid, versionID, versionDescription) values ('3000', '1', 'Subtraction Version 1');

/* inventory tbpolarity_type */
insert into tbpolarity_type (polaritytype, polarity) values ('P', 'positive');
insert into tbpolarity_type (polaritytype, polarity) values ('N', 'negative');
insert into tbpolarity_type (polaritytype, polarity) values ('0', 'none');

alter session set nls_timestamp_format = 'RR/MM/DD HH24:MI:SSXFF';
alter session set nls_date_language ='ENGLISH';
select * from nls_session_parameters where parameter = 'NLS_DATE_FORMAT';
select * from nls_session_parameters where parameter = 'NLS_TIME_FORMAT';

/* inventory tbexp_vers_participation */
insert into tbexp_vers_participation (experimentid,versionID,subjectid,polarityType,exp_particip_date,start_time,end_time,payment,gender,matlab_initials,handedness,hand_used,age,researcherID) values
  ('1000','1','100000','P','11-OCT-2014','11-12-14 10:05:23.000000000','12-OCT-11 10:05:23.000000000','30.00','M','bsm','R','R','21','101');
insert into tbexp_vers_participation (experimentid,versionID,subjectid,polarityType,exp_particip_date,start_time,end_time,payment,gender,matlab_initials,handedness,hand_used,age,researcherID) values
  ('1000','1','000001','N','11-OCT-2014','11-12-14 10:05:23.000000000','12-OCT-11 10:05:23.000000000','30.00','M','jha','A','R','72','102');
insert into tbexp_vers_participation (experimentid,versionID,subjectid,polarityType,exp_particip_date,start_time,end_time,payment,gender,matlab_initials,handedness,hand_used,age,researcherID) values
  ('1000','2','234500','P','11-OCT-2011','11-12-14 10:05:23.000000000','12-OCT-11 10:05:23.000000000','30.00','F','mfe','L','R','22','103');
insert into tbexp_vers_participation (experimentid,versionID,subjectid,polarityType,exp_particip_date,start_time,end_time,payment,gender,matlab_initials,handedness,hand_used,age,researcherID) values
  ('3000','1','100000','0','11-OCT-2011','11-12-14 10:05:23.000000000','12-OCT-11 12:05:23.000000000','30.00','M','bsm','R','R','18','101');

/* inventory tbnotetype */
insert into tbnotetype (notetype,meaning) values ('SER', 'Subject Error');
insert into tbnotetype (notetype,meaning) values ('MAL', 'Malfunction');
insert into tbnotetype (notetype,meaning) values ('GEN', 'General');

/* inventory tbparticipant_note */
insert into tbparticipant_note (experimentid,versionID,subjectID,noteno,note,notetype,notedate,notetime,researcherID) values ('1000','1','100000','1','moved too slowly at first','SER','11-DEC-14','11-DEC-14 17:10:17.000000000','101');
insert into tbparticipant_note (experimentid,versionID,subjectID,noteno,note,notetype,notedate,notetime,researcherID) values ('1000','1','100000','2','Block A, Trial 200: made three movements on one trial','SER','11-DEC-14','11-DEC-14 17:15:23.000000000','101');
insert into tbparticipant_note (experimentid,versionID,subjectID,noteno,note,notetype,notedate,notetime,researcherID) values ('1000','2','234500','1','subject was extremely confused by cursor rotation','GEN','11-OCT-14','11-OCT-14 18:05:23.000000000','103');
insert into tbparticipant_note (experimentid,versionID,subjectID,noteno,note,notetype,notedate,notetime,researcherID) values ('3000','1','100000','1','program froze, had to restart and repeat Block H','MAL','11-OCT-11','11-OCT-11 12:40:00.000000000','101');

/* inventory tbmeasure_type */
insert into tbmeasure_type (measureType,detail,units) values ('p1_angle','angle of tricep to vertical','degrees');
insert into tbmeasure_type (measureType,detail,units) values ('p2_angle','angle of forearm to vertical','degrees');
insert into tbmeasure_type (measureType,detail,units) values ('arm_length1','shoulder to elbow','cm');
insert into tbmeasure_type (measureType,detail,units) values ('arm_length2','elbow to middle knuckle','cm');

/* inventory tbmeasurement */
insert into tbmeasurement (experimentid, versionID, subjectid, measureno, dataNumber, dataChar, measureType) values
  ('1000','1','100000','1',89.5,null,'p1_angle');
insert into tbmeasurement (experimentid, versionID, subjectid, measureno, dataNumber, dataChar, measureType) values
  ('1000','1','100000','2',78.4,null,'p1_angle');
insert into tbmeasurement (experimentid, versionID, subjectid, measureno, dataNumber, dataChar, measureType) values
  ('1000','1','100000','3',74.3,null,'p1_angle');
insert into tbmeasurement (experimentid, versionID, subjectid, measureno, dataNumber, dataChar, measureType) values
  ('1000','2','234500','1',87.5,null,'p1_angle');
insert into tbmeasurement (experimentid, versionID, subjectid, measureno, dataNumber, dataChar, measureType) values
  ('1000','2','234500','2',15.4,null,'arm_length1');
insert into tbmeasurement (experimentid, versionID, subjectid, measureno, dataNumber, dataChar, measureType) values
  ('3000','1','100000','1',16,null,'arm_length2');

-- ******************************************************
--    VIEW TABLES
--
-- Note:  Issue the appropiate commands to show your data
-- ******************************************************

/*1*/ SELECT * 
        FROM tbresearcher;

/*2*/ Select * from tbexperiment;

/*3*/ select * from tbexperiment_type;

/*4*/ SELECT * FROM tbsubject;

/*5*/ select * from tbsubject_address;

/*6*/ select * from tbsubject_email;

/*7*/ select * from tbsubject_phone;

/*8*/ select * from tbpolarity_type;

/*9*/ select * from tbmeasurement;

/*10*/ select * from tbmeasure_type;

/*11*/ select * from tbparticipant_note;

/*12*/ select * from tbnotetype;

/*13*/ select * from tbexp_vers_participation;

/*14*/ select * from tbexp_version;


CREATE VIEW payments_view AS
select a1.exp_particip_date, b.subjectid, b.subject_firstname, b.subject_lastname, a1.payment, e.exptype, c1.versionid, c1.versiondescription
from tbexp_vers_participation a1, tbsubject b, tbexp_version c1, tbexperiment d, tbexperiment_type e
where a1.subjectid = b.subjectid and
a1.experimentid = d.experimentid and
e.exptype = d.exptype and
a1.versionid = c1.versionid and
a1.experimentid = c1.experimentid
order by 1,7;

SELECT SUM(payment) as Total_Paid
from payments_view;

create view totalpaidpersubject as
select subjectid, subject_firstname, subject_lastname, SUM(payment) as Total_Paid
from payments_view
group by subjectid, subject_firstname, subject_lastname
order by 4;

select*
from payments_view;

select*
from TOTALPAIDPERSUBJECT;

select subjectid, subject_firstname, subject_lastname, total_paid
from totalpaidpersubject
where total_paid>500
order by 1;

COMMIT
-- ******************************************************
--    END SESSION
-- ******************************************************

spool off
