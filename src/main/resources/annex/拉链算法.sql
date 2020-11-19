拉链算法初始装载：pg_bulkload -i /usr/pgsql-11/bin/data/acct_amt_cur.txt -O odsdata.acct_amt -l /var/lib/pgsql/log/acct_amt.log  -o "TYPE=CSV" -o "DELIMITER=|"
pg_bulkload -i /usr/pgsql-11/bin/data/bank_mess.txt -O stgdata.bank_mess -l /var/lib/pgsql/log/bank_mess.log  -o "TYPE=CSV" -o "DELIMITER=|"

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