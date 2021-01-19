// package com.gertec.exemplosgertec.CodigoBarras;
package CodigoBarras;

import android.os.Bundle;
import android.os.Handler;

import android.content.Context;

import com.example.flutter_gBot.MainActivity;
import com.example.flutter_gBot.services.LedUtil;
import com.example.flutter_gBot.services.ReadCodeService;
import com.example.flutter_gBot.services.ServiceResultReceiver;

import static com.example.flutter_gBot.services.ReadCodeService.SHOW_RESULT;


public class LeituraCodigoActivity implements ServiceResultReceiver.Receiver {

    private ServiceResultReceiver mServiceResultReceiver;
    private Context context;
    public static boolean ATIVADO = false;

    public LeituraCodigoActivity(Context context) {
        this.context = context;

        mServiceResultReceiver = new ServiceResultReceiver(new Handler());
        mServiceResultReceiver.setReceiver(this);
    }

    public void StartService(){
        if(!ATIVADO) {
            ATIVADO = true;
            StartLeitura(LeituraCodigoActivity.this, mServiceResultReceiver);
        }
    }

    public void StopService(){
        ATIVADO = false;
        ReadCodeService.START_SERVICES = false;
    }
    public void LedOn(){
        LedUtil.setRedLed();
    }

    public void LedOff(){
        LedUtil.setOffLed();
    }


    private void StartLeitura(LeituraCodigoActivity leituraCodigoActivity, ServiceResultReceiver mServiceResultReceiver){
        ReadCodeService.enqueueWork(this.context, mServiceResultReceiver);
    }

    @Override
    public void onReceiveResult(int resultCode, Bundle resultData) {
        String x = "";
        switch (resultCode) {
            case SHOW_RESULT:
                if (resultData != null) {
                    x = resultData.getString("data");
                    MainActivity._resultBarCode.success(x);
                }
                break;
        }
    }
}
