package com.concretepage.controller;

import com.concretepage.service.FireGreeting;
import com.concretepage.service.IFireGreetingListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.concretepage.vo.CalcInput;
import com.concretepage.vo.Result;

import java.io.File;
import java.util.Date;

@Controller
public class WebSocketController implements IFireGreetingListener {

    @Autowired
    private SimpMessagingTemplate template;

	@MessageMapping("/add" )
    @SendTo("/topic/showResult")
    public Result addNum(CalcInput input) throws Exception {

        Result result = new Result("{\"x\":"+input.getNum1()+","+"\"y\":"+input.getNum2()+"}");
        return result;
    }
    
    @RequestMapping("/start")
    public String start() {
        return "start";
    }


    WebSocketController()
    {
        //FireGreeting.getInstance().addListener(this);
    }


    @Override
    public void notify(String data) {
        Result result = new Result(new Date().toString());
        this.template.convertAndSend("/topic/showResult", result);
    }
}
