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
my $DB_IP='139.196.28.154';                                       # Postgres数据库IP地址
my $DB_PORT='5432';                                             # Postgres通信端口
my $DB_NAME='postgres';                                        # Postgres数据库名称
my $ETL_DATE;                                                   # 数据日期
my $ETL_JOB;                                                    # ETL脚本名称
my $MAX_DATE=$ENV{"AUTO_MAXDATE"}||'30001231';                  # 最大日期
my $NULL_TIMESTAMP='1900-01-01';    # 空时间戳
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

SELECT count( * ) 
FROM stgdata.bank_mess
UNION ALL 
    SELECT count( * ) 
    FROM odsdata.acct_amt
    WHERE start_date <= '${ETL_DATE}'
    AND end_date > '${ETL_DATE}'
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

