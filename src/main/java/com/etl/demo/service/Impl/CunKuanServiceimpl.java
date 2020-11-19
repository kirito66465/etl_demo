package com.etl.demo.service.Impl;

import com.etl.demo.mapper.CunKuanMapper;
import com.etl.demo.service.CunkuanService;
import com.etl.demo.utils.GetBusSerAct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.DateFormat;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.Date;

@Service
public class CunKuanServiceimpl implements CunkuanService {
    @Autowired
    private CunKuanMapper cunKuanMapper;

    @Override
    public int cunKuan(BigDecimal act_cur,String act,String actName) {
        Date date = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date time = null;
        try {
            time = sdf.parse(sdf.format(date));
        } catch (ParseException e) {
            e.printStackTrace();
        }
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        GetBusSerAct a= GetBusSerAct.getInstance();
        String busSerAct= a.getNextBusSerAct();
        System.out.println("==========="+act);
        System.out.println("==========="+time);
        System.out.println("==========="+timestamp);
        System.out.println("==========="+actName);
        int x=cunKuanMapper.cunKuan(act_cur,act,time,timestamp);
        if(x==1){
          return cunKuanMapper.insetCunKuan(act,actName,act_cur,busSerAct,time,timestamp);
        }else{
            return 0;
        }
    }
}
