/*======================================================================================
  Arquivo       : KioskMode.java
  Projeto       : Modo Quiosque
  Plataforma    : Android
  Equipamentos  : Dispositivos Android
  Data Criação  : 03/Nov/2020
  Autor         : Geovani Nogueira Santos

  Descrição   : KioskMode.java:
                   - Habilita e Desabilita o Kiosk Mode via aplicação.
  =========================================================================================*/

package com.example.flutter_gBot.Kiosk;

import android.app.Activity;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;

import android.view.View;

public class KioskMode extends AdminReceiver {

    private ComponentName componentName;
    private DevicePolicyManager devicePolicyManager;
    private Activity activity;

    public KioskMode(Activity activity) {
        this.activity = activity;
    }

    public void startKiosMode(){
        this.componentName = new ComponentName(this.activity.getApplicationContext(), AdminReceiver.class);
        this.devicePolicyManager = (DevicePolicyManager) this.activity.getSystemService(this.activity.DEVICE_POLICY_SERVICE);
        this.setLockTask(true);
        this.setVisibleMode(true);
    }

    public void stopKioskMode() throws Exception {
        if(this.componentName == null){
            throw new Exception("Modo Quiosque ainda não foi ativado");
        }
        this.setLockTask(false);
        this.setVisibleMode(false);
        this.componentName = null;
        this.devicePolicyManager = null;
    }

    // Modo que a aplicação ficará visivel no e equipamento
    private void setVisibleMode(Boolean enable) {
        if (enable) {
            int flags = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
            this.activity.getWindow().getDecorView().setSystemUiVisibility(flags);
        } else {
            int flags = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
            this.activity.getWindow().getDecorView().setSystemUiVisibility(flags);
        }
    }

    private void setLockTask(boolean start){
        if(start){
            activity.startLockTask();
        }else{
            activity.stopLockTask();
        }
    }

}
