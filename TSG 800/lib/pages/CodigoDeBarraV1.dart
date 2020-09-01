import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageCodigoDeBarraV1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CodigoDeBarrav1(title: 'Ler Código de Barras'),
    );
  }
}

class CodigoDeBarrav1 extends StatefulWidget {
  CodigoDeBarrav1({Key key, this.title}) : super(key: key);
  final String title;
  _CodigoDeBarrav1 createState() => _CodigoDeBarrav1();
}

class _CodigoDeBarrav1 extends State<CodigoDeBarrav1> {
  static const platform = const MethodChannel('samples.flutter.dev/gedi');
  final myController = TextEditingController();
  List<String> resultadosBardCod = new List<String>();

  Future<void> _leitorCodigoDeBarra(String tipoLeitura) async {
    print("_leitorCodigoDeBarra");
    try {
      String teste = await platform.invokeMethod('leitorCodigov1', <String, dynamic>{"tipoLeitura": tipoLeitura});
      setState(() {
        resultadosBardCod.add(teste);
      });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;
    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);

    return new Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: ScreenUtil.instance.setWidth(40.0),
        ),
        child: Column(
          children: <Widget>[
            Text(
              "Ler Código de Barras",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: ScreenUtil.instance.setWidth(100),
                  child: RaisedButton(
                    child: Text(
                      'EAN 8',
                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(15), color: Colors.red),
                    ),
                    onPressed: () {
                      _leitorCodigoDeBarra("EAN_8");
                    },
                  ),
                ),
                SizedBox(
                  width: ScreenUtil.instance.setWidth(100),
                  child: RaisedButton(
                    child: Text(
                      'EAN 13',
                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(15), color: Colors.red),
                    ),
                    onPressed: () {
                      _leitorCodigoDeBarra("EAN_13");
                    },
                  ),
                ),
                SizedBox(
                  width: ScreenUtil.instance.setWidth(100), // specific value
                  child: RaisedButton(
                    child: Text(
                      'EAN 14',
                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(15), color: Colors.red),
                    ),
                    onPressed: () {
                      _leitorCodigoDeBarra("EAN_14");
                    },
                  ),
                ),
                SizedBox(
                  width: ScreenUtil.instance.setWidth(100), // specific value
                  child: RaisedButton(
                    child: Text(
                      'QR CODE',
                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(15), color: Colors.red),
                    ),
                    onPressed: () {
                      _leitorCodigoDeBarra("QR_CODE");
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: new ListView.builder(
                shrinkWrap: true,
                itemCount: resultadosBardCod.length,
                itemExtent: 50,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: ListTile(
                      dense: true,
                      title: Text(
                        resultadosBardCod[index],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(12.0), color: Colors.black54),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
