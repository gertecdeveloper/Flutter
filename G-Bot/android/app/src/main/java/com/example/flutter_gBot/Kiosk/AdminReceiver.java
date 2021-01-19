/*======================================================================================
  Arquivo       : AdminReceiver.java
  Projeto       : Modo Quiosque
  Plataforma    : Android
  Equipamentos  : Dispositivos Android
  Data Criação  : 03/Nov/2020
  Autor         : Geovani Nogueira

  Descrição   : AdminReceiver.java:
                   - Verifica se a aplicação esta como administradora do equipamento.
  =========================================================================================*/
package com.example.flutter_gBot.Kiosk;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

public class AdminReceiver extends DeviceAdminReceiver {

    @Override
    public void onEnabled(Context context, Intent intent) {
        super.onEnabled(context, intent);
        Toast.makeText(context, "Administrador de dispositivo ativado", Toast.LENGTH_SHORT).show();
    }

    @Override
    public CharSequence onDisableRequested(Context context, Intent intent) {
        super.onDisableRequested(context, intent);
        return "Aviso: o administrador do dispositivo será desativado.";
    }

    @Override
    public void onDisabled(Context context, Intent intent) {
        super.onDisabled(context, intent);
        Toast.makeText(context, "Administrador de dispositivo desativado", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onLockTaskModeEntering(Context context, Intent intent, String pkg) {
        super.onLockTaskModeEntering(context, intent, pkg);
        Toast.makeText(context, "Modo quiosque ativado", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onLockTaskModeExiting(Context context, Intent intent) {
        super.onLockTaskModeExiting(context, intent);
        Toast.makeText(context, "Modo quiosque desativado", Toast.LENGTH_SHORT).show();
    }

}