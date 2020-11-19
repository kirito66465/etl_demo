package com.etl.demo.pojo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import javax.persistence.Table;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

@Data
@Table(name = "stgdata.acct_change")
public class AcctChange {
    private String act;//负债账号
    private String actName;//账户名称
    private String curFlag;//借贷标志
    private String oppAct;//对方账号
    private BigDecimal busCur;//交易金额
    private String busActCur;//交易币种
    private String busSerAct;//交易流水号
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date busDate;//交易日期
    private String busFlag;//记录状态----0-删除，1-正常
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Timestamp timeCur;//时间戳
}