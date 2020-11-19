# etl_demo
## 一、项目介绍
### 1. 简述
银行存取款转账业务+ETL流程+实现报表
### 2. 详述
（1）云端服务器Linux中，运行脚本main_1.sh进行作业调度，实现：
- 对txt数据进行数据装载（stgdata.bank_mess、odsdata.acct_amt）；
- 生成历史拉链表；
- 进行拉链表数据验证；
- 衍生指标加工。<br>
（2）运行项目，完成以下步骤：
- 登录admin账户，查看前日银行历史拉链表和衍生指标；
- 登录普通用户，进行存取款、转账业务操作，并可查看当日或全部交易记录。<br>
（3）运单服务器Linux中，运行脚本main_2.sh进行作业调度，实现：
- 更新当天历史拉链表；
- 进行拉链表数据验证；
- 衍生指标加工。<br>
（4）运行项目，完成下述步骤：
- 登录admin账户，查看前日银行历史拉链表和衍生指标。

## 二、项目技术工具
### （1）所需工具
#### 1.服务器
- 阿里云CentOS
- Postgres数据库
- pg_bulkload数据装载软件
- Tomcat Web应用服务器
#### 2.本地开发
- IDEA
- 浏览器
- Navicat数据库图形化管理工具
### （2）所需技术
#### 1.服务器
- Linux命令
- Shell脚本
- Perl脚本
- ETL开发（拉链算法、upsert算法）
#### 2.本地开发
- Spring Boot整合SSM
- EasyUI
- Maven
- Git

## 三、表结构
### （1）STGDATA贴源层
#### 1.银行账户信息表bank_mess
|字段中文名称|字段英文名称|数据类型|
|---|---|---|
|负债账号|act|VARCHAR(20)|
|账户名称|act_name|VARCHAR(20)|
|账户密码|act_pasw|VARCHAR(20)|
|证件类型|certi|VARCHAR(20)|
|证件号码|certi_number|VARCHAR(20)|
|币种|cur|VARCHAR(4)|
|开户金额|act_open_cur|NUMERIC(40,8)|
|开户日期|act_open_date|VARCHAR(20)|
|当前账户余额|act_cur|NUMERIC(40,8)|
|开户城市|act_city|VARCHAR(2)|
|户主职业|act_job|VARCHAR(2)|
|余额最近更新日期|cur_upd_date|DATE|
|时间戳|time_cur|Timestamp|
|账户状态|act_flag|VARCHAR(4)|
#### 2.账户余额发生明细表acct_change
|字段中文名称|字段英文名称|数据类型|
|---|---|---|
|负债账号|act|VARCHAR(20)|
|账户名称|act_name|VARCHAR(20)|
|借贷标志|cur_flag|VARCHAR(4)|
|对方账号|opp_act|VARCHAR(20)|
|交易金额|bus_cur|NUMERIC(40,8)|
|交易币种|bus_act_cur|VARCHAR(4)|
|交易流水号|bus_ser_act|VARCHAR(10)|
|交易日期|bus_date|DATE|
|记录状态|bus_flag|VARCHAR(4)|
|时间戳|time_cur|timestamp|
### （2）ODSDATA逻辑层
#### 1.历史拉链表acct_amt
|字段中文名称|字段英文名称|数据类型|
|---|---|---|
|负债账号|act|VARCHAR(20)|
|币种|cur|VARCHAR(4)|
|开户金额|act_open_cur|NUMERIC(40,8)|
|当前账户余额|act_cur|NUMERIC(40,8)|
|开户城市|act_city|VARCHAR(2)|
|户主职业|act_job|VARCHAR(2)|
|开始日期 |start_date|DATE|
|结束日期|end_date|DATE|
### （3）GDMDATA应用层
#### 1.银行报表/衍生指标bank_statement
|字段中文名称|字段英文名称|数据类型|
|---|---|---|
|负债账号|act|VARCHAR(20)|
|币种|cur|VARCHAR(4)|
|开户金额|act_open_cur|NUMERIC(40,8)|
|当前余额|act_cur|NUMERIC(40,8)|
|开户城市|act_city|VARCHAR(2)|
|户主职业|act_job|VARCHAR(2)|
|账户上日余额|act_lastd_cur|NUMERIC(40,8)|
|账户上月末余额|act_lastm_cur|NUMERIC(40,8)|
|账户上季末余额|act_lasts_cur|NUMERIC(40,8)|
|账户上年同期末余额|act_lasty_cur|NUMERIC(40,8)|
|账户余额月积数|act_cur_sum|NUMERIC(40,8)|

### （4）Postgres数据库表结构
- 3个schema：stgdata、odsdata、gdmdata
- 4张基本表：stgdata.bank_mess、stgdata.acct_change、odsdata.acct_amt、gdmdata.bank_statement
- 4张临时表：odsdata.acct_amt_source、odsdata.acct_amt_cur、acct_amt_insert_cur、odsdata.acct_amt_update

## 四、附件说明
/resources/annex文件夹下：
- acct_amt_cur.txt：         银行拉链表准备数据
- bank_mess.txt：            银行账户信息表准备数据
- Create-Table.sql：         建表准备语句
- dataloading1.sh：          装载bank_mess.txt数据
- dataloading2.sh：          装载acct_amt_cur.txt数据
- main1.sh：                 Linux第一次作业调度脚本
- main2.sh：                 Linux第二次作业调度脚本
- odsdata.pl：               拉链表生成更新
- Table-Structure.xlsx：     表结构Excel文件
- verify.pl：                验证拉链表数据脚本
- 拉链算法.sql：              实现拉链算法的语句