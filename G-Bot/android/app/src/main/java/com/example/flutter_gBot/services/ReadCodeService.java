package com.example.flutter_gBot.services;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.RemoteException;
import android.os.ResultReceiver;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.JobIntentService;

import com.example.flutter_gBot.R;

import java.util.concurrent.CountDownLatch;

import wangpos.sdk4.libbasebinder.Core;
import wangpos.sdk4.libbasebinder.Scaner;

public class ReadCodeService extends JobIntentService {

    public static boolean START_SERVICES = true;

    private static final String TAG = ReadCodeService.class.getSimpleName();
    public static final String RECEIVER = "receiver";
    public static final int SHOW_RESULT = 123;

    private static CountDownLatch countDownLatch = null;
    private static MediaPlayer mediaPlayer;

    private ResultReceiver mResultReceiver;

    static final int READCODE_JOB_ID = 1000;
    private static final String ACTION_READ_CODE = "action.READ_CODE";

    private static Scaner scaner;

    private static Core core;

    public static void enqueueWork(Context context, ServiceResultReceiver workerResultReceiver) {
        Intent intent = new Intent(context, ReadCodeService.class);
        intent.putExtra(RECEIVER, workerResultReceiver);
        intent.setAction(ACTION_READ_CODE);
        countDownLatch = new CountDownLatch(1);
        START_SERVICES = true;
        enqueueWork(context, ReadCodeService.class, READCODE_JOB_ID, intent);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        new Thread(new Runnable() {
            @Override
            public void run() {
                scaner = new Scaner(getApplicationContext());
                Log.d(TAG, "Foi inicialiado a class do scanner");
            }
        }).start();
        mediaPlayer  = MediaPlayer.create(getApplicationContext(), R.raw.beep);
    }

    @SuppressLint("DefaultLocale")
    @Override
    protected void onHandleWork(@NonNull Intent intent) {

        if (intent.getAction() != null) {

            switch (intent.getAction()) {

                case ACTION_READ_CODE:
                    mResultReceiver = intent.getParcelableExtra(RECEIVER);
                    while (START_SERVICES){
                        Log.d(TAG, "Serviço de leitura sendo excultado.");
                        try {
                            String retorno = scanner();
                            if(retorno != null){
                                Bundle bundle = new Bundle();
                                bundle.putString("data",retorno);
                                mResultReceiver.send(SHOW_RESULT, bundle);
                                Thread.sleep(1000);
                            }
                            countDownLatch.await();
                        } catch (RemoteException e) {
                            e.printStackTrace();
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }

                    break;
            }
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "Fim do Serviço de Leitura");
    }

    @Override
    public boolean onStopCurrentWork() {
        Log.d(TAG, "onStopCurrentWork");
        return super.onStopCurrentWork();
    }



    private String scanner() throws RemoteException {

        int ret = -1;
        byte[] tempData = null;
        byte[] daBytes = new byte[128];

        int[] dataLen = new int[1];

        if(scaner == null){
            Log.i(TAG, "Serviço ainda não inicializado.");
            return null;
        }

        ret = scaner.scanSingle(daBytes, dataLen);

        countDownLatch.countDown();
        if(ret == 0){
            if(ret == 0 && daBytes[0] == 0){
                tempData = new byte[dataLen[0] -2];
                System.arraycopy(daBytes, 2, tempData, 0, dataLen[0]-2);
            }

            String codeRead = new String(tempData);
            Log.i(TAG, "Leitura efetuada: " + codeRead);
            mediaPlayer.start();
            return codeRead;
        }

        Log.i(TAG, "Nenhuma leitura efetuada.");
        return null;
    }

}