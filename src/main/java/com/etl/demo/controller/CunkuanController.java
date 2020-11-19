package com.etl.demo.controller;

import com.etl.demo.service.CunkuanService;
import com.etl.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;

@RestController
public class CunkuanController {
    @Autowired
    private UserService userService;
    @Autowired
    private CunkuanService cunkuanService;
    @RequestMapping("cunkuan")
    public int cunKuan(@RequestParam(value = "act_cur",required = true) BigDecimal act_cur, HttpSession httpSession){
        String act = (String)httpSession.getAttribute("userid");
        String actName = this.userService.getName(act);
        return cunkuanService.cunKuan(act_cur,act,actName);
    }
}
