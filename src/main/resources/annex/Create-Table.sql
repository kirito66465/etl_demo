-- 银行账户信息表
CREATE TABLE stgdata.bank_mess (
    act	            VARCHAR(20)
    , act_name	    VARCHAR(20)
    , act_pasw	    VARCHAR(20)
    , certi	        VARCHAR(20)
    , certi_number	VARCHAR(20)
    , cur	        VARCHAR(4)
    , act_open_cur	NUMERIC(40,8)
    , act_open_date	VARCHAR(20)
    , act_cur	    NUMERIC(40,8)
    , act_city	    VARCHAR(2)
    , act_job	    VARCHAR(2)
    , cur_upd_date	DATE
    , time_cur	    Timestamp
    , act_flag	    VARCHAR(4)
);
COMMENT ON TABLE stgdata.bank_mess is '银行账户信息表';
COMMENT ON COLUMN stgdata.bank_mess.act is '负债账号';
COMMENT ON COLUMN stgdata.bank_mess.act_name is '账户名称';
COMMENT ON COLUMN stgdata.bank_mess.act_pasw is '账户密码';
COMMENT ON COLUMN stgdata.bank_mess.certi is '证件类型';
COMMENT ON COLUMN stgdata.bank_mess.certi_number is '证件号码';
COMMENT ON COLUMN stgdata.bank_mess.cur is '币种';
COMMENT ON COLUMN stgdata.bank_mess.act_open_cur is '开户金额';
COMMENT ON COLUMN stgdata.bank_mess.act_open_date is '开户日期';
COMMENT ON COLUMN stgdata.bank_mess.act_cur is '当前账户余额';
COMMENT ON COLUMN stgdata.bank_mess.act_city is '开户城市';
COMMENT ON COLUMN stgdata.bank_mess.act_job is '户主职业';
COMMENT ON COLUMN stgdata.bank_mess.cur_upd_date is '余额最近更新日期';
COMMENT ON COLUMN stgdata.bank_mess.time_cur is '时间戳';
COMMENT ON COLUMN stgdata.bank_mess.act_flag is '账户状态';

pg_bulkload -i /usr/pgsql-11/bin/data/bank_mess.txt -O stgdata.bank_mess -l /var/lib/pgsql/log/bank_mess.log  -o "TYPE=CSV" -o "DELIMITER=|"

-- 账户余额发生明细表
CREATE TABLE stgdata.acct_change (
    act	VARCHAR(20)
    , act_name	    VARCHAR(20)
    , cur_flag	    VARCHAR(4)
    , opp_act	    VARCHAR(20)
    , bus_cur	    NUMERIC(40,8)
    , bus_act_cur	VARCHAR(4)
    , bus_ser_act	VARCHAR(10)
    , bus_date	    DATE
    , bus_flag	    VARCHAR(4)
    , time_cur	    timestamp 
);
COMMENT ON TABLE stgdata.acct_change is '账户余额发生明细表';
COMMENT ON COLUMN stgdata.acct_change.act is '负债账号';
COMMENT ON COLUMN stgdata.acct_change.act_name is '账户名称';
COMMENT ON COLUMN stgdata.acct_change.cur_flag is '借贷标志';
COMMENT ON COLUMN stgdata.acct_change.opp_act is '对方账号';
COMMENT ON COLUMN stgdata.acct_change.bus_cur is '交易金额';
COMMENT ON COLUMN stgdata.acct_change.bus_act_cur is '交易币种';
COMMENT ON COLUMN stgdata.acct_change.bus_ser_act is '交易流水号';
COMMENT ON COLUMN stgdata.acct_change.bus_date is '交易日期';
COMMENT ON COLUMN stgdata.acct_change.bus_flag is '记录状态';
COMMENT ON COLUMN stgdata.acct_change.time_cur is '时间戳';

pg_bulkload -i /usr/pgsql-11/bin/data/acct_cur_change_${ETL_DATE}.txt -O stgdata.acct_change -l /var/lib/pgsql/log/acct_change_${ETL_DATE}.log  -o "TYPE=CSV" -o "DELIMITER=|"
/* 1019号成功导入9条，失败1条；1025号全部失败 */

-- 银行拉链表
CREATE TABLE odsdata.acct_amt (
    act	            VARCHAR(20)
    , cur	        VARCHAR(4)
    , act_open_cur	NUMERIC(40,8)
    , act_cur	    NUMERIC(40,8)
    , act_city	    VARCHAR(2)
    , act_job	    VARCHAR(2)
    , start_date	DATE
    , end_date	    DATE
);
COMMENT ON TABLE odsdata.acct_amt is '账户余额发生明细表';
COMMENT ON COLUMN odsdata.acct_amt.act is '负债账号';
COMMENT ON COLUMN odsdata.acct_amt.cur is '币种';
COMMENT ON COLUMN odsdata.acct_amt.act_open_cuis is '开户金额';
COMMENT ON COLUMN odsdata.acct_amt.act_cur is '当前账户余额';
COMMENT ON COLUMN odsdata.acct_amt.act_city is '开户城市';
COMMENT ON COLUMN odsdata.acct_amt.act_job is '户主职业';
COMMENT ON COLUMN odsdata.acct_amt.start_dt is '开始日期';
COMMENT ON COLUMN odsdata.acct_amt.end_dt is '结束日期';

-- 银行报表
CREATE TABLE gdmdata.bank_statement (
    act	            VARCHAR(20)
    , cur	        VARCHAR(4)
    , act_open_cur	NUMERIC(40,8)
    , act_cur	    NUMERIC(40,8)
    , act_city	    VARCHAR(2)
    , act_job	    VARCHAR(2)
    , act_lastd_cur	NUMERIC(40,8)
    , act_lastm_cur	NUMERIC(40,8)
    , act_lasts_cur	NUMERIC(40,8)
    , act_lasty_cur	NUMERIC(40,8)
    , act_cur_sum	NUMERIC(40,8)
);
COMMENT ON TABLE gdmdata.bank_statement is '银行报表';
COMMENT ON COLUMN gdmdata.bank_statement.act is '负债账号';
COMMENT ON COLUMN gdmdata.bank_statement.cur is '币种';
COMMENT ON COLUMN gdmdata.bank_statement.act_open_cur is '开户金额';
COMMENT ON COLUMN gdmdata.bank_statement.act_cur	is '当前余额';
COMMENT ON COLUMN gdmdata.bank_statement.act_city is '开户城市';
COMMENT ON COLUMN gdmdata.bank_statement.act_job is '户主职业';
COMMENT ON COLUMN gdmdata.bank_statement.act_lastd_cur is '账户上日余额';
COMMENT ON COLUMN gdmdata.bank_statement.act_lastm_cur is '账户上月末余额';
COMMENT ON COLUMN gdmdata.bank_statement.act_lasts_cur is '账户上季末余额';
COMMENT ON COLUMN gdmdata.bank_statement.act_lasty_cur is '账户上年同期末余额';
COMMENT ON COLUMN gdmdata.bank_statement.act_cur_sum is '账户余额月积数';