package com.etl.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import tk.mybatis.spring.annotation.MapperScan;

/**
 * Description：SpringBoot启动类
 */
@SpringBootApplication
@MapperScan("com.etl.demo.mapper")
public class EtlApplication {
    public static void main(String[] args) {
        SpringApplication.run(EtlApplication.class ,args);
    }
}
