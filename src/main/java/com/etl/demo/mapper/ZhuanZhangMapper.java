package com.etl.demo.mapper;

import com.etl.demo.pojo.AcctChange;
import com.etl.demo.pojo.BankMess;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Component;
import tk.mybatis.mapper.common.Mapper;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

@Component
public interface ZhuanZhangMapper extends Mapper<AcctChange> {
    @Select("select * from bank_mess where act = #{act}")
    BankMess selAct(String act);

    @Update("update bank_mess set act_cur = #{newCur}, cur_upd_date = #{time}, time_cur = #{timestamp} " +
            "where act = #{act}")
    Integer updata(String act, BigDecimal newCur, Date time, Timestamp timestamp);//当前账户扣款

    @Update("update bank_mess set act_cur = act_cur + #{busCur}, cur_upd_date = #{time}, time_cur = #{timestamp} where act = " +
            "#{oppAct}")
    Integer addCur(String oppAct, BigDecimal busCur, Date time, Timestamp timestamp);//给对方账户增款
}
