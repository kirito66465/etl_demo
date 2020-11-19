#!/bin/bash
# ---------------------------------------------------------------------------
# ----------------------说明--------------------------------------------------
# 请使用postgres用户运行此脚本！
# 此脚本在/usr/pgsql-11/bin/script目录下
# ---------------------------------------------------------------------------
# 传入日期参数
echo "请输入一个参数:$1"
if [ -n "$1" ]
then
    echo "传入参数成功！"
else
    echo "请输入一个参数！"
    exit
fi
ETL_DATE=$1
# ---------------------------------------------------------------------------
# 完成当天历史拉链表更新
echo "更新当天历史拉链表"
perl odsdata.pl ${ETL_DATE}

# ---------------------------------------------------------------------------
# 验证源表与目标表
perl verify.pl ${ETL_DATE}

# ---------------------------------------------------------------------------
# 加工衍生指标
perl gdmdata.pl ${ETL_DATE}





