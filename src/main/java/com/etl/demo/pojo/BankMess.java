package com.etl.demo.pojo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import javax.persistence.Table;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

@Data
@Table(name = "stgdata.bank_mess")
public class BankMess {
    private String act;//负债账号
    private String actName;//账户名称
    private String actPasw;//账户密码
    private String certi;//证件类型
    private String certiNumber;//证件号码
    private String cur;//币种
    private BigDecimal actOpenCur;//开户金额
    private String actOpenDate;//开户日期
    private BigDecimal actCur;//当前账户余额
    private String actCity;//账户城市
    private String actJob;//账户职业
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date curUpdDate;//余额最近更新日期
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Timestamp timeCur;//时间戳
    private String actFlag;//账户状态----0-删除，1-正常
}