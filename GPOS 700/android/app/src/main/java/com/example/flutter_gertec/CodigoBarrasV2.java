package com.example.flutter_gertec;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.google.zxing.Result;

import me.dm7.barcodescanner.zxing.ZXingScannerView;

public class CodigoBarrasV2 extends AppCompatActivity implements View.OnClickListener, ZXingScannerView.ResultHandler {

    private static final String ACESSO_NEGADO = "Permissão negada à câmera";

    private boolean flash = false;

    private ViewGroup contentFrame;

    private ZXingScannerView mScannerView;

    private TextView txtLeitura;

    private Button btnFlash;

    int StartCameraFlag = 0;

    public static final String G700x = "GPOS700";
    public static final String G800x = "Smart G800";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.codigo_barras2);

        ActivityCompat.requestPermissions(CodigoBarrasV2.this, new String[] { Manifest.permission.CAMERA }, 1);

        txtLeitura = findViewById(R.id.textLeitura);

        btnFlash = findViewById(R.id.btnLigarFlash);

        btnFlash.setOnClickListener(this);

        contentFrame = (ViewGroup) findViewById(R.id.content_frame);
        mScannerView = new ZXingScannerView(this);
        contentFrame.addView(mScannerView);
    }

    @Override
    public void onClick(View view) {

        switch (view.getId()) {
            case R.id.btnLigarFlash:
                if (flash) {
                    mScannerView.setFlash(false);
                    flash = false;
                    btnFlash.setText("Flash - Desligado");
                } else {
                    mScannerView.setFlash(true);
                    flash = true;
                    btnFlash.setText("Flash - Ligado");
                }
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        startCamera();
    }

    @Override
    public void onPause() {
        super.onPause();
        mScannerView.stopCamera();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mScannerView != null)
            mScannerView.stopCamera();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case 1: {
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                } else {
                    Toast.makeText(CodigoBarrasV2.this, ACESSO_NEGADO, Toast.LENGTH_SHORT).show();
                }
                return;
            }
        }
    }

    @Override
    public void handleResult(Result result) {

        // new Thread(new Runnable() {
        // @Override
        // public void run() {
        // try {
        // stopCamera();
        // Thread.sleep(1000);
        // } catch (InterruptedException e) {
        // e.printStackTrace();
        // }
        // }
        // });

        AlertDialog alertDialog = new AlertDialog.Builder(CodigoBarrasV2.this).create();
        alertDialog.setTitle("Código " + result.getBarcodeFormat());
        // Intent intent = new Intent();
        // intent.putExtra("codigoBarCodeV2", result.getBarcodeFormat().toString());
        // setResult(RESULT_OK, intent);
        alertDialog.setMessage(result.getBarcodeFormat() + ": " + result.getText());

        alertDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                dialog.dismiss();
                startCamera();
            }
        });

        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, "OK", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                startCamera();
            }
        });
        alertDialog.show();
        // mScannerView.resumeCameraPreview(this);
        txtLeitura.setText(result.getBarcodeFormat() + ": " + result.getText());
    }

    protected void startCamera() {
        contentFrame.setVisibility(View.VISIBLE);
        mScannerView.setResultHandler(this);
        mScannerView.setAutoFocus(true);

        if (Build.MODEL.equals(G700x)) {
            if (StartCameraFlag == 0) {
                mScannerView.startCamera();
                StartCameraFlag = 1;
            } else {
                mScannerView.resumeCameraPreview(this);
            }
        } else {
            mScannerView.startCamera();
        }
    }

    protected void stopCamera() {
        mScannerView.stopCamera();
        contentFrame.setVisibility(View.INVISIBLE);
    }

}
