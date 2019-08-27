import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";

void main() => runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
      debugShowCheckedModeBanner: false,
    ));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text =
        (real / dolar).toStringAsFixed(2).replaceAll('.', ',');
    euroController.text = (real / euro).toStringAsFixed(2).replaceAll('.', ',');
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text =
        (dolar * this.dolar).toStringAsFixed(2).replaceAll('.', ',');
    euroController.text =
        (dolar * this.dolar / euro).toStringAsFixed(2).replaceAll('.', ',');
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text =
        (euro * this.euro).toStringAsFixed(2).replaceAll('.', ',');
    dolarController.text =
        (euro * this.euro / dolar).toStringAsFixed(2).replaceAll('.', ',');
  }

  void _resetFields() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Aguarde, carregando. . .",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao processar !",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        buidTextField(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buidTextField(
                            "Dolar", "\$", dolarController, _dolarChanged),
                        Divider(),
                        buidTextField(
                            "Euro", "€ ", euroController, _euroChanged),
                        Container(
                          child: RaisedButton(
                            onPressed: () {
                              _resetFields();
                            },
                            child: Text("Limpar campos",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25.0)),
                            color: Colors.amber,
                          ),
                        )
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buidTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    controller: c,
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    keyboardType: TextInputType.number,
    onChanged: f,
  );
}
