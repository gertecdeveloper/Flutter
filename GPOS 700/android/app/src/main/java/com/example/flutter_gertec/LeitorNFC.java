package com.example.flutter_gertec;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentFilter;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.nfc.tech.IsoDep;
import android.nfc.tech.MifareClassic;
import android.os.Bundle;
import android.widget.Toast;

import java.util.List;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class LeitorNFC extends AppCompatActivity {
    private static final String CHANNEL = "samples.flutter.dev/gedi";
    private NfcAdapter nfcAdapter;
    private Tag tag;
    private MifareClassic mifareClassic;
    private IsoDep isoDep;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_leitor_n_f_c);
    }

    protected void onStart() {
        super.onStart();
        // Liga o Sensor da NFC
        nfcAdapter = NfcAdapter.getDefaultAdapter(this);
    }

    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        try {
            tag = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);
            if (tag == null) {
                Toast.makeText(getApplicationContext(), "Não foi possível ler o cartão.", Toast.LENGTH_SHORT).show();
            } else {
                LerCartaoNfc();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    protected void onResume() {
        super.onResume();
        IntentFilter tagDetected = new IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED);
        IntentFilter ndefDetected = new IntentFilter(NfcAdapter.ACTION_NDEF_DISCOVERED);
        IntentFilter techDetected = new IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED);
        IntentFilter idDetected = new IntentFilter((NfcAdapter.EXTRA_ID));

        IntentFilter[] nfcIntentFilter = new IntentFilter[] { techDetected, tagDetected, ndefDetected, idDetected };

        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0,
                new Intent(this, getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), 0);
        if (nfcAdapter != null)
            nfcAdapter.enableForegroundDispatch(this, pendingIntent, nfcIntentFilter, null);

    }

    protected void LerCartaoNfc() {
        Intent intent = new Intent();
        if (MifareClassic.get(tag) != null) {
            mifareClassic = MifareClassic.get(tag);
            intent.putExtra("codigoNFCID", idCartao().toString());
            setResult(RESULT_OK, intent);
            finish();
        } else if (IsoDep.get(tag) != null) {
            isoDep = IsoDep.get(tag);
            intent.putExtra("codigoNFCID", idCartao().toString());
            setResult(RESULT_OK, intent);
            finish();
        }
    }

    // Converte o ID do cartão que esta em Bytes para String
    public String idCartao() {
        byte[] idCartao = null;
        long result = 0;

        if (mifareClassic != null) {
            idCartao = mifareClassic.getTag().getId();
        } else if (isoDep != null) {
            idCartao = isoDep.getTag().getId();
        }

        if (idCartao == null)
            return "";

        for (int i = idCartao.length - 1; i >= 0; --i) {
            result <<= 8;
            result |= idCartao[i] & 0x0FF;
        }
        return Long.toString(result);

    }

    private static String bytesToHex(byte[] hashInBytes) {

        StringBuilder sb = new StringBuilder();
        for (byte b : hashInBytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
