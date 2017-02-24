package com.concretepage.service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by cl on 2017/2/24.
 */
public class FireGreeting implements Runnable {

    private List<IFireGreetingListener> listeners = new ArrayList<>();

    synchronized public void addListener(IFireGreetingListener listener) {
        this.listeners.add(listener);
    }

    private static FireGreeting instance;
    synchronized public static FireGreeting getInstance()
    {
        if(null == instance)
        {
            instance = new FireGreeting();
        }
        return instance;
    }

    @Override
    public void run() {
        while (true) {
            try {
                Thread.sleep( 1000 );
                String str = new Date().toString();
                for (IFireGreetingListener listener : listeners) {
                    listener.notify(str);
                }
            } catch ( InterruptedException e ) {
                e.printStackTrace();
            }
        }
    }
}