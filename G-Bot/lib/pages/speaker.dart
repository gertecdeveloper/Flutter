import 'package:flutter/material.dart';
import 'package:flutter_gBot/widgets/widgetsgertec.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeakerGBOT extends StatefulWidget {
  @override
  _SpeakerGBOTState createState() => _SpeakerGBOTState();
}

class _SpeakerGBOTState extends State<SpeakerGBOT> {
  TextEditingController inputText = new TextEditingController();

  FlutterTts flutterTts = FlutterTts();

  var ttsState;

  Future speak(String textoSpeak) async {
    if (textoSpeak.isEmpty) {
      WidgetsGertec.dialogo("Insira uma mensagem!", context: context);
    } else {
      await flutterTts.setLanguage("pt-BR");
      await flutterTts.speak(textoSpeak);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Text("Fala G-BOT", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetsGertec.buttonStandard("FRASE 1", iWidht: 300, callback: () => speak("Bem vindos a apresentação do G-Bot")),
                    WidgetsGertec.buttonStandard("FRASE 2", iWidht: 300, callback: () => speak("Possui Reconhecimento Facial")),
                    WidgetsGertec.buttonStandard("FRASE 3", iWidht: 300, callback: () => speak("Microfone e Leitor NFC")),
                    WidgetsGertec.buttonStandard("FRASE DIGITADA", iWidht: 300, callback: () => speak(inputText.text)),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                child: WidgetsGertec.formField(inputText, "Digite a sua frase aqui:", iWidht: 600),
              )
            ],
          ),
        ],
      ),
    );
  }
}
