#!/usr/bin/perl
#/*************Head Section**************************************************************************/
#/*Script Use           :  description of (xxxxxxxx)                                                */
#/*Create Date          : 2020/10/27                                                                */
#/*Gdm Developed By     : PACTERA                                                                   */
#/*Gdm Developed Date   : 2020/10/27                                                                */
#/*Gdm Checked By       : PACTERA                                                                   */
#/*Gdm Checked Date     : 2020/10/27                                                                */
#/*Source table 1       : schema_name.table_name                                                    */
#/*Target Table         : schema_name.table_name                                                    */
#/*ETL Frequency        : D:Daily                                                                   */
#/*ETL Policy           : [History Chain]                                                           */
#--------------- -------------- --------------------------------------------------------------------
#2020/10/27        PACTERA        CREATE
#/***************************************************************************************************/
#/* package section                                                                                 */
#/***************************************************************************************************/
use strict;                                        #Declare using Perl strict syntax
use DBI;
use DBD::Pg qw(:pg_types);
use DBD::Pg qw(:async);
#/***************************************************************************************************/
#/*variable section                                                                                 */
#/***************************************************************************************************/
#/*程序所需变量                                                                                     */
my $HOME    = '/app/script';         #ETL工作目录
my $LOG_DIR  = "${HOME}/LOG/ODS";                   #日志存放目录

#/***************************************************************************************************/
#/*参数变量                                                                                         */
my $CONTROL_FILE;                                               # 控制文件名称
my $DB_IP='139.196.28.154';                                     # Postgres数据库IP地址
my $DB_PORT='5432';                                             # Postgres通信端口
my $DB_NAME='postgres';                                         # Postgres数据库名称
my $ETL_DATE;                                                   # 数据日期
my $ETL_JOB;                                                    # ETL脚本名称
my $MAX_DATE=$ENV{"AUTO_MAXDATE"}||'30001231';                  # 最大日期
my $NULL_TIMESTAMP='1900-01-01';                                # 空时间戳
my $RET_CODE;                                                   # 返回码

my $SHORT_DATE;



my $STGDB='stgdata';                        #贴源层
my $ODSDB='odsdata';                        #汇聚层
my $GDMDB='gdmdata';                        #中间层

my $TRUE = 0;                                                   # 成功
my $FALSE = 1;                                                  # 失败

my $V_RPTDATE;                                                  #10位业务日期
#/***************************************************************************************************/
#/*Perl Function                                                                                    */
#/***************************************************************************************************/
#/*print message Function                                                                           */
#/***************************************************************************************************/
sub Message($)
{
    printf "[%02d:%02d:%02d] %s\n", (localtime(time()))[2,1,0], shift;
}
#/***************************************************************************************************/
#/*PSQL Function                                                                                    */
#/***************************************************************************************************/
sub run_psql_command
{
    my ($dbuser,$dbpasswd,$logFile) = @_ ;

    $ENV{"PGPASSWORD"} = $dbpasswd;

    my $rc = open(PSQL, "| psql -d $DB_NAME -h $DB_IP -p $DB_PORT -U $dbuser -a -v ON_ERROR_STOP=1 > ${logFile} 2>&1");
    # To see if psql command invoke ok?
    unless ($rc) {
        print "Could not invoke PSQL command\n";
        return 1;
    }

    print PSQL <<ENDOFINPUT;

\\timing
      
  /***************************************************************************************************/
  /*Group1:    tablename(xxxxxxx)                                                                      */
  /***************************************************************************************************/
 BEGIN;
 


/* 支持重跑脚本 */
-- 删除结束日期为最大日期的记录
-- 更新结束日期为当天的记录（结束日期更改为最大日期）
DELETE FROM odsdata.acct_amt
WHERE end_date = '${MAX_DATE}'; 
UPDATE odsdata.acct_amt
SET end_date = '${MAX_DATE}'
WHERE end_date = '${ETL_DATE}';

/* 取上日数据 */
-- 从历史拉链表中取出结束日期为最大日期的记录
DROP TABLE IF EXISTS odsdata.acct_amt_source;
CREATE TABLE odsdata.acct_amt_source (
    act	            VARCHAR(20)
    , cur	        VARCHAR(4)
    , act_open_cur	NUMERIC(40,8)
    , act_cur	    NUMERIC(40,8)
    , act_city	    VARCHAR(2)
    , act_job	    VARCHAR(2)
    , start_date	DATE
    , end_date	    DATE
);
INSERT INTO odsdata.acct_amt_source
SELECT act
    , cur
    , act_open_cur
    , act_cur
    , act_city
    , act_job
    , start_date
    , end_date
FROM odsdata.acct_amt
WHERE end_date = '${MAX_DATE}'
;

/* 取当日数据 */
-- 从交易明细表和银行账户信息表中查找出当天有余额更新的记录
DROP TABLE IF EXISTS odsdata.acct_amt_cur;
CREATE TABLE odsdata.acct_amt_cur (
    act	            VARCHAR(20)
    , cur	        VARCHAR(4)
    , act_open_cur	NUMERIC(40,8)
    , act_cur	    NUMERIC(40,8)
    , act_city	    VARCHAR(2)
    , act_job	    VARCHAR(2)
    , start_date	DATE
    , end_date	    DATE
);
INSERT INTO odsdata.acct_amt_cur
SELECT t1.act
    , t2.cur
    , t2.act_open_cur
    , t2.act_cur
    , t2.act_city
    , t2.act_job
    , '${ETL_DATE}'
    , '${MAX_DATE}'
FROM stgdata.acct_change t1
LEFT JOIN stgdata.bank_mess t2
ON t1.act = t2.act
WHERE t2.cur_upd_date = '${ETL_DATE}'
;



-- 昨日数据：
-- 1001 50.00 20200831 30001231
-- 1002 60.00 20200831 30001231

-- 当日数据：
-- 1001 50.00 20200831 30001231
-- 1002 60.00 20200831 30001231
-- 1003 80.00 20200901 30001231

-- 增量数据：
-- 1001 70.00 20200901 30001231
-- 1003 80.00 20200901 30001231

-- 1001 50.00 20200831 30001231删除
-- 1001 50.00 20200831 20200901插入
-- 1001 70.00 20200901 30001231插入
-- 1003 80.00 20200901 30001231插入

/* 增量数据，今日数据不在昨日数据里的新增数据 */
DROP TABLE IF EXISTS odsdata.acct_amt_insert_cur;
CREATE TABLE odsdata.acct_amt_insert_cur (
    act	            VARCHAR(20)
    , cur	        VARCHAR(4)
    , act_open_cur	NUMERIC(40,8)
    , act_cur	    NUMERIC(40,8)
    , act_city	    VARCHAR(2)
    , act_job	    VARCHAR(2)
    , start_date	DATE
    , end_date	    DATE
);
-- 插入1001 70.00 20200901 30001231
INSERT INTO odsdata.acct_amt_insert_cur
SELECT t1.act
    , t1.cur
    , t1.act_open_cur
    , t1.act_cur
    , t1.act_city
    , t1.act_job
    , '${ETL_DATE}'
    , '${MAX_DATE}'
FROM odsdata.acct_amt_cur t1
WHERE t1.act_cur <> (
    SELECT t2.act_cur
    FROM odsdata.acct_amt_source t2
    WHERE t1.act = t2.act
);
-- 插入1003 80.00 20200901 30001231
INSERT INTO odsdata.acct_amt_insert_cur
SELECT t1.act
    , t1.cur
    , t1.act_open_cur
    , t1.act_cur
    , t1.act_city
    , t1.act_job
    , '${ETL_DATE}'
    , '${MAX_DATE}'
FROM odsdata.acct_amt_cur t1
WHERE t1.act
NOT IN (
    SELECT t2.act
    FROM odsdata.acct_amt_source t2
)
;



-- 删改数据，昨日数据不在今日数据里的数据
DROP TABLE IF EXISTS odsdata.acct_amt_update;
CREATE TABLE odsdata.acct_amt_update (
    act	            VARCHAR(20)
    , cur	        VARCHAR(4)
    , act_open_cur	NUMERIC(40,8)
    , act_cur	    NUMERIC(40,8)
    , act_city	    VARCHAR(2)
    , act_job	    VARCHAR(2)
    , start_date	DATE
    , end_date	    DATE
);
-- 插入1001 50.00 20200831 20200901
INSERT INTO odsdata.acct_amt_update
SELECT t1.act
    , t1.cur
    , t1.act_open_cur
    , t1.act_cur
    , t1.act_city
    , t1.act_job
    , t1.start_date
    , '${ETL_DATE}'
FROM odsdata.acct_amt_source t1
WHERE (
    act
    , cur
    , act_open_cur
    , act_city
    , act_job
    , end_date
) IN (
    SELECT act
        , cur
        , act_open_cur
        , act_city
        , act_job
        , end_date
    FROM odsdata.acct_amt_cur
)
;
/*
昨日：acct_amt_source
2020-11-01 3000-12-31 50

今日：acct_amt_cur
2020-11-12 3000-12-31 100

拉链：
2020-11-01 2020-11-12 50
2020-11-12 3000-12-31 100
*/


-- 更新历史中上日数据的截止时间为当日时间(删除-插入代替更新)
-- 应该删除1001 50.00 20200831 30001231
-- 保留1005 10.00 20000000 30001231
DELETE FROM odsdata.acct_amt
WHERE end_date = '${MAX_DATE}';
INSERT INTO odsdata.acct_amt (
    act
    , cur
    , act_open_cur
    , act_cur
    , act_city
    , act_job
    , start_date
    , end_date
)
SELECT t1.act
    , t1.cur
    , t1.act_open_cur
    , t1.act_cur
    , t1.act_city
    , t1.act_job
    , t1.start_date
    , '${MAX_DATE}'
FROM odsdata.acct_amt_source t1
WHERE t1.act
NOT IN (
    SELECT t2.act
    FROM odsdata.acct_amt_cur t2
)
;
-- 插入删改数据
INSERT INTO odsdata.acct_amt (
    act
    , cur
    , act_open_cur
    , act_cur
    , act_city
    , act_job
    , start_date
    , end_date
)
SELECT act
    , cur
    , act_open_cur
    , act_cur
    , act_city
    , act_job
    , start_date
    , end_date
FROM odsdata.acct_amt_update
;
-- 插入增量数据
INSERT INTO odsdata.acct_amt (
    act
    , cur
    , act_open_cur
    , act_cur
    , act_city
    , act_job
    , start_date
    , end_date
)
SELECT act
    , cur
    , act_open_cur
    , act_cur
    , act_city
    , act_job
    , start_date
    , end_date
FROM odsdata.acct_amt_insert_cur
;



  END; 

       /*收集统计信息*/
   -- VACUUM ANALYZE stgdata.append_event; 
    
\\q

ENDOFINPUT

    close( PSQL ) ;
    # return 0 means ok
    $rc = $?;

    # print log file
    open (LOG_H,${logFile});
    my @log = <LOG_H>;
    close (LOG_H);

    print @log;

    return $rc;
}

#/***************************************************************************************************/
#/*main Function                                                                                    */
#/***************************************************************************************************/
sub main
{
    # 获取信息
    Message('获取预信息');
    if ( substr(${CONTROL_FILE}, length(${CONTROL_FILE})-3, 3) eq 'dir' ) {
        $ETL_DATE = substr(${CONTROL_FILE},0, 8);
    };
    $SHORT_DATE=substr($ETL_DATE,4,4);
    
    $ETL_JOB=$0;
    $ETL_JOB=~s/.*\///;
    $ETL_JOB=~s/.pl//;

    my $DB_USER='etluser';
	my $DB_PASSWD='etluser';

    unless(-d "$LOG_DIR/$ETL_DATE" ){
        `mkdir -p $LOG_DIR/$ETL_DATE`;
    }

    my $logFile = "$LOG_DIR/$ETL_DATE/${ETL_JOB}.${ETL_DATE}.log";

    Message("ETL JOB        : $ETL_JOB");
    Message("DATA DATE      : $ETL_DATE");
    Message("GREENPLUM IP   : $DB_IP");
    Message("GREENPLUM PORT : $DB_PORT");
    Message("GREENPLUM USER : $DB_USER");
    Message("LOG FILE       : $logFile");
        
    my $rec = run_psql_command( $DB_USER, $DB_PASSWD, $logFile ) ;
    Message('运行psql转换程序,结束');
    return $rec;
}


#/***************************************************************************************************/
#/*parameter selection                                                                              */
#/***************************************************************************************************/
if ( $#ARGV !=0 )
{
    Message('请正确输入参数');
    exit 1;
}
$CONTROL_FILE = "$ARGV[0].dir"; 

open(STDERR, ">&STDOUT");
$RET_CODE = main();

if( $RET_CODE )
{
    Message('脚本运行失败');
    exit 1;
}
else
{
    Message('脚本运行成功');
    exit 0;
}

