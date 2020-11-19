package com.etl.demo.service;


import com.etl.demo.pojo.*;

public interface UserService {
    String login(String id, String password);

    BankMess getUser(String userid);

    int doTakeout(String act, String actPasw, String amount);

    String getName(String userid);

    PageResult<BankStatment> findAllStatment(Integer page, Integer rows);

    PageResult<AcctChange> findAllChange(Integer page, Integer rows ,String act);

    PageResult<AcctAmt> findAllAmt(Integer page, Integer rows);
}
