package com.example.flutter_gBot.services;

import android.util.Log;

import java.lang.reflect.Method;

public class LedUtil {

    private static final String TAG = LedUtil.class.getSimpleName();

    public static void setBlueLed(){
        Log.d(TAG,"luz azul");
        setLed("0x0200");
    }

    public static void setBluePlusWhiteLed(){
        Log.d(TAG,"luz azul + Branco");
        setLed("0x0220");
    }

    public static void setLightBlueLed(){
        Log.d(TAG,"luz azul Claro");
        setLed("0x0270");
    }

    public static void setPinkLed(){
        Log.d(TAG,"luz Rosa");
        setLed("0x0280");
    }

    public static void setLightPinkLed(){
        Log.d(TAG,"luz Rosa Claro");
        setLed("0x0380");
    }

    public static void setCyanLed(){
        Log.d(TAG,"luz Ciano");
        setLed("0x0300");
    }

    public static void setGreenLed(){
        Log.d(TAG,"luz verde");
        setLed("0x0100");
    }

    public static void setLightGreen(){
        Log.d(TAG,"luz Verde Claro");
        setLed("0x0119");
    }

    public static void setLightGreenPlusWhite(){
        Log.d(TAG,"luz Verde Claro + branco");
        setLed("0x0140");
    }

    public static void setRedLed(){
        Log.d(TAG,"luz vermelho");
        setLed("0x0080");
    }

    public static void setOrangeLed(){
        Log.d(TAG,"luz laranja");
        setLed("0x0180");
    }

    public static void setOnLed(){
        Log.d(TAG,"Ligue a luz de digitalização");
        setLed("0xffff");
    }

    public static void setOffLed(){
        Log.d(TAG,"Desligue a luz de digitalização");
        setLed("0x0000");
    }


    private static void setLed(String cmd){
        try{
            Class WriteSysFileManagerClass = Class.forName("android.os.WriteSysFileManager");
            Object WriteSysFileManager = WriteSysFileManagerClass.newInstance();
            Method method = WriteSysFileManagerClass.getMethod("writeSysFile", String.class, String.class);
            method.invoke(WriteSysFileManager, "/sys/class/leds/aw9109_led/onoff_by_reg",cmd);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
