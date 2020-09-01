package com.example.flutter_gertec;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentFilter;
import android.nfc.FormatException;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.nfc.tech.Ndef;
import android.os.Bundle;
import android.util.Log;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

import java.io.IOException;

public class NfcLeitura extends AppCompatActivity {
    private EditText editMesagemPadrao;
    private TextView mTvMessage;
    private NfcLeituraGravacao nfcLeituraGravacao;
    private NfcAdapter mNfcAdapter;
    private static final String MENSAGEM_PADRAO = "GERTEC";
    private int processo = 1000;
    private byte[] getID;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.fragment_leitura);
        mTvMessage = findViewById(R.id.tv_message);
        initNFC();
    }

    private void initNFC(){
        mNfcAdapter = NfcAdapter.getDefaultAdapter(this);
        // nfcManager = new NfcManager(this);
    }


    @Override
    protected void onResume() {
        super.onResume();
        IntentFilter tagDetected = new IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED);
        IntentFilter ndefDetected = new IntentFilter(NfcAdapter.ACTION_NDEF_DISCOVERED);
        IntentFilter techDetected = new IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED);
        IntentFilter idDetected = new IntentFilter((NfcAdapter.EXTRA_ID));
        IntentFilter[] nfcIntentFilter = new IntentFilter[]{techDetected,tagDetected,ndefDetected, idDetected};

        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, new Intent(this, getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), 0);
        if(mNfcAdapter!= null)
            mNfcAdapter.enableForegroundDispatch(this, pendingIntent, nfcIntentFilter, null);
    }

    @Override
    protected void onPause() {
        super.onPause();
        if(mNfcAdapter!= null)
            mNfcAdapter.disableForegroundDispatch(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Intent intent = new Intent();
        intent.putExtra("mensagemLeitura", mTvMessage.toString());
        setResult(RESULT_OK, intent);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Tag tag = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);

        Log.d("TAG", "onNewIntent: " + intent.getAction());

        if (tag != null) {

            Ndef ndef = Ndef.get(tag);
            for (int i = 0; i < tag.getTechList().length;i++){
                System.out.println("Tags: "+tag.getTechList()[i]);
            }
            if(ndef == null){
                Toast.makeText(getApplicationContext(), "Tipo de cartão não suportado.", Toast.LENGTH_SHORT).show();
            }else {
                nfcLeituraGravacao = new NfcLeituraGravacao(ndef.getTag());
                readFromNFC(ndef);
            }
        }
    }
    private void readFromNFC(Ndef ndef) {

        String mensagem;
        String idCarao;
        Long tempoExecucao;

        try {

            // Recebe a leitura das atuais mensagens cadastradas no cartão
            mensagem = nfcLeituraGravacao.retornaMensagemGravadaCartao(ndef);
            idCarao = nfcLeituraGravacao.idCartaoHexadecimal();

            // Recebe o tempo total de execução da operação de leitura
            tempoExecucao = nfcLeituraGravacao.retornaTempoDeExeculcaoSegundos();

            if(mensagem.equals("")){
                mTvMessage.setText("Não existe mensagem gravada no cartão");
            }else{
                mTvMessage.setText("ID Cartão: " + idCarao + "\n"+ mensagem+
                        "\n\nTempo de execução: "+String.format("%02d segundos", tempoExecucao));
            }

        } catch (IOException | FormatException e) {
            Toast.makeText(this, e.getMessage(), Toast.LENGTH_LONG ).show();
        } catch (Exception e) {
            Toast.makeText(this, e.getMessage(), Toast.LENGTH_LONG ).show();
        }
    }
}