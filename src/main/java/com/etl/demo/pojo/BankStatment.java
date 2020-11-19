package com.etl.demo.pojo;

import lombok.Data;

import javax.persistence.Table;
import java.math.BigDecimal;

@Data
@Table(name = "gdmdata.bank_statment")
public class BankStatment {
    private String act;//负债账号
    private String cur;//币种
    private BigDecimal actOpenCur;//开户金额
    private BigDecimal actCur;//当前余额
    private String actCity;//账户城市
    private String actJob;//账户职业
    private BigDecimal actLastdCur;//账户上日余额
    private BigDecimal actLastmCur;//账户上月末余额
    private BigDecimal actLastsCur;//账户上季末余额
    private BigDecimal actLastyCur;//账户上年同期末余额
    private BigDecimal actCurSum;//账户余额月积数
}