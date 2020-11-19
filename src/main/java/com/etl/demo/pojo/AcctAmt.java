package com.etl.demo.pojo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import javax.persistence.Table;
import java.math.BigDecimal;
import java.util.Date;

@Data
@Table(name = "odsdata.acct_amt")
public class AcctAmt {
    private String act;//负债账号
    private String cur;//币种
    private BigDecimal actOpenCur;//开户金额
    private BigDecimal actCur;  // 当前账户余额
    private String actCity;//开户城市
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private String actJob;//开始日期
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date startDate;//结束日期
    private Date endDate;//数据日期
}