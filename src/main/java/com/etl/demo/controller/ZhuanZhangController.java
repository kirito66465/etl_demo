package com.etl.demo.controller;

import com.etl.demo.service.UserService;
import com.etl.demo.service.ZhuanZhangService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpSession;

@RestController
public class ZhuanZhangController {

    @Autowired
    private ZhuanZhangService zhuanZhangService;
    private UserService userService;

    @RequestMapping("zhuan")
    public Integer zhuanZhang(
            HttpSession httpSession,
            @RequestParam(name = "actPassword",required = true,defaultValue = "")String actPassword,
            @RequestParam(name = "oppAct",required = true,defaultValue = "")String oppAct,
            @RequestParam(name = "actCur",required = true,defaultValue = "0")String busCur
    ){
        String act = (String) httpSession.getAttribute("userid");
        return zhuanZhangService.zhuanZhang(act,actPassword,oppAct,busCur);
    }
}
