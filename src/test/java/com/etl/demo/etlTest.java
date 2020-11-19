package com.etl.demo;

import com.etl.demo.utils.GetBusSerAct;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * @Author：Dong
 * Date：2020/11/11 16:48
 * Description：
 */
@SpringBootTest
class etlTest {

    //获取流水号单例类测试
    @Test
    void getNumberTest(){
        GetBusSerAct instance = GetBusSerAct.getInstance();//调用静态方法获取对象
        String nextBusSerAct = instance.getNextBusSerAct();//用对象调方法获取流水号

        System.out.println(nextBusSerAct);
    }



}
