package com.etl.demo.mapper;

import com.etl.demo.pojo.AcctAmt;
import com.etl.demo.pojo.AcctChange;
import com.etl.demo.pojo.BankMess;
import com.etl.demo.pojo.BankStatment;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Component;
import tk.mybatis.mapper.common.Mapper;

import java.math.BigDecimal;
import java.util.List;

@Component
public interface UserMapper extends Mapper<AcctChange>{

    @Select("select act_name from stgdata.bank_mess where act = #{id} and act_pasw = #{password}")
    String findUser(String id,String password);

    @Select("select * from stgdata.bank_mess where act = #{userid}")
    BankMess getUser(String userid);

    @Select("select act_cur from stgdata.bank_mess where act = #{act} and act_pasw = #{actPasw}")
    String getActCur(String act, String actPasw);

    @Update("update  stgdata.bank_mess set act_cur = #{actCur} where act = #{act} and act_pasw = #{actPasw}")
    int doTakeout(String act, String actPasw, BigDecimal actCur);

    @Select("select act_name from stgdata.bank_mess where act = #{userid}")
    String getName(String userid);

    @Select("select * from gdmdata.bank_statment")
    List<BankStatment> findAllStatment();

    @Select("select * from odsdata.acct_amt")
    List<AcctAmt> findAllAmt();

    @Select("select * from stgdata.acct_change where act = #{act}")
    List<AcctChange> findAllChange(String act);
}


