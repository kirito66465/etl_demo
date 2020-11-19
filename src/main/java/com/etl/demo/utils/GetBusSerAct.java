package com.etl.demo.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Description：通过单例类生成交易流水号
 */
public class GetBusSerAct {

    //初始化序号
    private static Integer i=0;

    //创建本例对象
    private static GetBusSerAct instance = new GetBusSerAct();

    //私有化构造方法
    private GetBusSerAct(){}

    //对外提供获取本例对象的方法
    public static GetBusSerAct getInstance(){
        return instance;
    }

    //对外提供获取交易流水号方法
    public String getNextBusSerAct(){
        String id = null;
        Date date = new Date();
        SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
        //拼接流水号
        if (i<10){//只有一位时在前面加0
            id = format.format(date) + "0" +i.toString();
        }else {
            id = format.format(date) + i.toString();
        }
        i++;
        //表字段长度只支持两位序号
        if (i == 100){
            i = 0;
        }
        return id;
    }
    /*
     * 当前存在漏洞
     * 1.每日订单超过100则会重复。（表字段设置太短）
     * 2.跨日不会自动从0开始
     */
}
