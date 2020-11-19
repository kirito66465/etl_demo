#!/bin/bash
# ---------------------------------------------------------------------------
# ----------------------说明------------------------------------------------
# 请使用postgres用户运行此脚本！
# ---------------------------------------------------------------------------
# 传入日期参数
# echo "请输入一个参数:$1"
# if [ -n "$1" ]
# then
#     echo "传入参数成功！"
# else
#     echo "请输入一个参数！"
#     exit
# fi
# ETL_DATE=$1
# ---------------------------------------------------------------------------
# 变量准备
echo "----------变量准备----------"
data="/usr/pgsql-11/bin/data/acct_amt_cur.txt"
db="odsdata.acct_amt"
log="/var/lib/pgsql/log/acct_amt.log"
if [ $? -eq 0 ]; then
    echo "succeed！"
else
    echo "failed!"
fi
# ---------------------------------------------------------------------------
# 数据装载
echo "----------数据装载----------"
load_data() {
    pg_bulkload -i ${data} -O ${db} -l ${log}  -o "TYPE=CSV" -o "DELIMITER=|"
}
load_data
if [ $? -eq 0 ]; then
    echo "The data with acct_amt has been loaded successfully!"
fi
# for i in 1 2 3
# do
#     load_data
#     if [ $? -eq 0 ]; then
#         echo "The data with acc_change_${ETL_DATE} has been loaded successfully!"
#         break
#     else
#         echo "failed!"
#         sleep 1
#         if [  $i == 3  ]
#         then
#             exit
#         fi
#     fi
# done