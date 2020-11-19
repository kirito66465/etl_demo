package com.etl.demo.service.Impl;

import com.etl.demo.mapper.ZhuanZhangMapper;
import com.etl.demo.pojo.AcctChange;
import com.etl.demo.pojo.BankMess;
import com.etl.demo.service.ZhuanZhangService;
import com.etl.demo.utils.GetBusSerAct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@Service
public class ZhuanZhangServiceImpl implements ZhuanZhangService {

    @Autowired
    private ZhuanZhangMapper zhuanZhangMapper;
    private BankMess bankMess;

    @Override
    @Transactional//事务控制
    public Integer zhuanZhang(String act, String actPassword, String oppAct, String busCur) {
        Date date = new Date();
        SimpleDateFormat sdf1 = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat sdf2 = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Timestamp timestamp = Timestamp.valueOf(sdf2.format(date));
        Date time = null;
        try {
            time = sdf1.parse(sdf1.format(date));
        } catch (ParseException e) {
            e.printStackTrace();
        }

        bankMess = zhuanZhangMapper.selAct(act);
        if (!actPassword.equals(bankMess.getActPasw())) {//校验密码
            return -1; //密码错误
        } else {
            BigDecimal bigDecimal = new BigDecimal(busCur);//取款金额
            BigDecimal actCur = bankMess.getActCur();//原余额
            if (bigDecimal.compareTo(actCur) == 1) {//检验余额
                return -2;//余额不足
            } else {
                if (zhuanZhangMapper.selAct(oppAct) == null) {
                    return -4;//目标用户不存在
                } else {
                    BigDecimal newCur = actCur.subtract(bigDecimal);//新余额
                    System.out.println(newCur);
                    Integer i = zhuanZhangMapper.updata(act, newCur, time,timestamp);//扣款，更新日期
                    if (i != 1) {
                        return -3;//扣款失败
                    } else {

                        zhuanZhangMapper.addCur(oppAct, bigDecimal, time,timestamp);//给对方账户加钱，并更新日期

                        AcctChange acctChange = new AcctChange();
                        acctChange.setAct(act);
                        acctChange.setActName(bankMess.getActName());
                        acctChange.setCurFlag("0");
                        acctChange.setOppAct(oppAct);
                        acctChange.setBusCur(bigDecimal);
                        acctChange.setBusActCur(bankMess.getCur());
                        GetBusSerAct instance = GetBusSerAct.getInstance();
                        acctChange.setBusSerAct(instance.getNextBusSerAct());
                        acctChange.setBusDate(time);
                        acctChange.setBusFlag("1");

                        acctChange.setTimeCur(timestamp);
                        return zhuanZhangMapper.insertSelective(acctChange);//通用mapper插入数据
                    }
                }
            }
        }
    }
}
