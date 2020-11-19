package com.etl.demo.mapper;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

@Component
public interface CunKuanMapper {
    @Update("update bank_mess set act_cur = act_cur+#{act_cur},cur_upd_date=#{time},time_cur=#{timestamp} where act=#{act}")
    int cunKuan(BigDecimal act_cur, String act,Date time,Timestamp timestamp);
    @Insert("insert into acct_change ( act,act_name,cur_flag,opp_act,bus_cur,bus_act_cur,bus_ser_act,bus_date,bus_flag,time_cur)values(#{act},#{actName},1,9999,#{act_cur},00,#{busSerAct},#{time},1,#{timestamp})")
    int insetCunKuan(String act,String actName, BigDecimal act_cur,String busSerAct, Date time, Timestamp timestamp);
}
