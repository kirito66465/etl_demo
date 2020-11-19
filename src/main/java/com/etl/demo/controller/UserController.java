package com.etl.demo.controller;

import com.etl.demo.pojo.*;
import com.etl.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpSession;

@RestController
public class UserController {
    @Autowired
    private UserService userService;

    @RequestMapping("login")
    public String login(
            @RequestParam(value = "id", required = true) String id,
            @RequestParam(value = "password", required = true) String password,
            HttpSession httpSession
    ) {

        String username = this.userService.login(id, password);
        if (username != null) {
            httpSession.setAttribute("userid", id);
            return username;
        }
        return null;
    }

    @RequestMapping("getusername")
    public String getUser(HttpSession httpSession) {
        String userid = (String) httpSession.getAttribute("userid");
        String username = this.userService.getName(userid);
        return username;
    }

    @RequestMapping("getuser")
    public BankMess getUserId(HttpSession httpSession) {
        String userid = (String) httpSession.getAttribute("userid");
        return this.userService.getUser(userid);
    }

    @RequestMapping("takeout")
    public int doTakeout(@RequestParam(value = "act") String act, @RequestParam(value = "actPasw") String actPasw, @RequestParam(value = "amount") String amount) {
        return this.userService.doTakeout(act, actPasw, amount);
    }

    @RequestMapping("findAllStmtment")
    public PageResult<BankStatment> findAllStatment(
            @RequestParam(name = "page", required = true, defaultValue = "1") Integer page,
            @RequestParam(name = "rows", required = true, defaultValue = "10") Integer rows
    ) {
        return this.userService.findAllStatment(page, rows);
    }

    @RequestMapping("findAllAmt")
    public PageResult<AcctAmt> findAllAmt(
            @RequestParam(name = "page", required = true, defaultValue = "1") Integer page,
            @RequestParam(name = "rows", required = true, defaultValue = "10") Integer rows
    ) {
        return this.userService.findAllAmt(page, rows);
    }

    @RequestMapping("findAllChange")
    public PageResult<AcctChange> findAllChange(
            @RequestParam(name = "page", required = true, defaultValue = "1") Integer page,
            @RequestParam(name = "rows", required = true, defaultValue = "10") Integer rows,
            HttpSession httpSession
    ) {
        String act = (String) httpSession.getAttribute("userid");
        return this.userService.findAllChange(page, rows, act);

    }

}
