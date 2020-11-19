package com.etl.demo.service.Impl;

import com.etl.demo.mapper.UserMapper;
import com.etl.demo.pojo.*;
import com.etl.demo.service.UserService;
import com.etl.demo.utils.GetBusSerAct;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Service
public class UserServiceimpl implements UserService {

    @Autowired
    private UserMapper userMapper;


    @Override
    public String login(String id, String password) {
        return this.userMapper.findUser(id,password);
    }

    @Override
    public BankMess getUser(String userid) {
        return this.userMapper.getUser(userid);
    }

    @Override
    @Transactional
    public int doTakeout(String act, String actPasw, String amount) {
        BigDecimal actcur =new BigDecimal( this.userMapper.getActCur(act,actPasw) );
        BigDecimal amout = new BigDecimal( amount );
        if ( amout.compareTo(actcur) == 1) {
            return -1;
        }


        GetBusSerAct instance = GetBusSerAct.getInstance();
        String nextBusSerAct = instance.getNextBusSerAct();

        Date date = new Date();
        SimpleDateFormat sdf1 = new SimpleDateFormat("yyyy-MM-dd");
        Date time = null;
        try {
            time = sdf1.parse(sdf1.format(date));
        }catch (Exception e){
            e.printStackTrace();
        }

        AcctChange acctChange = new AcctChange();
        acctChange.setAct(act);
        acctChange.setActName( this.getName(act) );
        acctChange.setCurFlag("-1");
        acctChange.setOppAct("0000");
        acctChange.setBusCur(amout);
        acctChange.setBusActCur("00");
        acctChange.setBusSerAct(nextBusSerAct);
        acctChange.setBusFlag("1");
        acctChange.setBusDate( time );
        acctChange.setTimeCur( new Timestamp(System.currentTimeMillis()) );

        this.userMapper.insertSelective(acctChange);
        return this.userMapper.doTakeout(act,actPasw,actcur.subtract(amout));

    }

    @Override
    public String getName(String userid) {
        return this.userMapper.getName(userid);
    }

    @Override
    public PageResult<BankStatment> findAllStatment(Integer page, Integer rows) {
        //  设置分页参数
        PageHelper.startPage(page, rows);
        List<BankStatment> bankStatments = this.userMapper.findAllStatment();
        PageInfo<BankStatment> info = new PageInfo<>(bankStatments);
        return new PageResult<BankStatment>(info.getTotal(), info.getList());
    }

    @Override
    public PageResult<AcctAmt> findAllAmt(Integer page, Integer rows) {
        //  设置分页参数
        PageHelper.startPage(page, rows);
        List<AcctAmt> AcctAmts = this.userMapper.findAllAmt();
        PageInfo<AcctAmt> info = new PageInfo<>(AcctAmts);
        return new PageResult<AcctAmt>(info.getTotal(), info.getList());
    }

    @Override
    public PageResult<AcctChange> findAllChange(Integer page, Integer rows,String act) {
        //  设置分页参数
        PageHelper.startPage(page, rows);
        List<AcctChange> acctChanges = this.userMapper.findAllChange(act);
        PageInfo<AcctChange> info = new PageInfo<>(acctChanges);
        return new PageResult<AcctChange>(info.getTotal(), info.getList());
    }
}
