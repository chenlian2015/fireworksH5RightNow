package com.concretepage.controller;

import com.concretepage.service.FireGreeting;
import com.concretepage.service.IFireGreetingListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;

import com.concretepage.vo.CalcInput;
import com.concretepage.vo.Result;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Controller
public class WebSocketController implements IFireGreetingListener {

    @Autowired
    private SimpMessagingTemplate template;


    @RequestMapping(value = "sendPoint.do")
    private @ResponseBody
    void sendPoint(HttpServletRequest request, HttpServletResponse response)
    {

        String strResult = "";
        try {
            String point = (String)request.getParameter("point");

            if (!StringUtils.isEmpty(point))
            {
                String [] pointArr = point.split("and");
                if (null != pointArr && pointArr.length ==2)
                {
                    Result result = new Result("{\"x\":"+pointArr[0]+","+"\"y\":"+pointArr[1]+"}");
                    this.template.convertAndSend("/topic/showResult", result);
                }
            }

            response.setContentType("text/json;charset=utf-8");
            PrintWriter pw = response.getWriter();
            pw.print("ok"+point);
            pw.flush();
            pw.close();
            pw = null;

        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();

        }
    }

	@MessageMapping("/add" )
    @SendTo("/topic/showResult")
    public Result addNum(CalcInput input) throws Exception {

	    if(input.getNum1()<0 || input.getNum1() >100)
        {
            return null;
        }

        if(input.getNum2()<0 || input.getNum2() >100)
        {
            return null;
        }

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
