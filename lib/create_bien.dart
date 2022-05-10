import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:naftal_perso/data/Bien_materiel.dart';
import 'package:naftal_perso/data/Employe.dart';
import 'package:naftal_perso/data/User.dart';
import 'package:naftal_perso/operations.dart';
import 'package:path/path.dart';

import 'package:naftal_perso/detail_bien.dart';
import 'package:naftal_perso/main.dart';
import 'package:sqflite/sqflite.dart';

  TextEditingController codeBarLoc = TextEditingController();

class Create_Bien extends StatefulWidget {
  final Employe employe;
  const Create_Bien({Key? key, required this.employe}) : super(key: key);

  @override
  _Create_BienState createState() => _Create_BienState(employe: this.employe);
}

class _Create_BienState extends State<Create_Bien> {
  _Create_BienState({required this.employe});
  final Employe employe;
  List<String> Localites = [];

  // late Bien_materiel bien;
  TextEditingController nomController = TextEditingController();
  TextEditingController codeBarBien = TextEditingController();

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
  }

  String formattedText(String text) {
    String result =
        text.replaceAll('-', "").replaceAll(" ", "").replaceAll("_", "");
    result = result.toUpperCase();

    return result;
  }

  String getEtat(int nb) {
    switch (nb) {
      case 1:
        return "Bon";
      case 2:
        return "Hors service";
      case 3:
        return "A réformer";
      default:
        return "";
    }
  }

  Future<int> getItems() async {
    User employe = await User.auth();
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> Struct = await db.query(
        'T_E_LOCATION_LOC where COP_ID = "${employe.COP_ID}"',
        distinct: true,
        columns: ['LOC_ID']);

    Localites = List.generate(Struct.length, (i) {
      return "${Struct[i]['LOC_ID']}";
    });
    return Localites.length;
  }

  Future<void> Check_localite(BuildContext context) async {
    if ( check_format(1, codeBarBien.text) == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.info, color: Colors.white, size: 25),
            Text(
              "Opération échouée objet non valide",
              style: TextStyle(fontSize: 17.0),
            ),
          ],
        ),
        backgroundColor: Colors.red,
      ));
    } else {
     
          Bien_materiel bien = Bien_materiel(
              codeBarBien.text,
              MODE_SCAN,
              DateTime.now().toIso8601String(),
              0,
              employe.EMP_ID);

          bool exist = await bien.exists();

          if (exist == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: Colors.white, size: 25),
                  Text(
                    "Bien matériel existe déjà",
                    style: TextStyle(fontSize: 17.0),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
            ));
          } else {
            await bien.Store_Bien();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detail_Bien(
                  employe: employe,
                  bien_materiel: bien,
                ),
              ),
            );
          }
        
      
    }
  }

  Future<void> scanBarcodeNormal(BuildContext context) async {
    User employe = await User.auth();
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      codeBarBien.text = barcodeScanRes;
    });

    if (check_format(1, codeBarBien.text) == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.info, color: Colors.white, size: 25),
            Text(
              "Opération échouée objet non valide",
              style: TextStyle(fontSize: 17.0),
            ),
          ],
        ),
        backgroundColor: Colors.red,
      ));
    } else {
      Bien_materiel bien = Bien_materiel(
          codeBarBien.text,
          MODE_SCAN,
          DateTime.now().toIso8601String(),
          0,
          employe.matricule);

      bool exist = await bien.exists();

      if (exist == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.info, color: Colors.white, size: 25),
              Text(
                "Bien matériel existe déjà",
                style: TextStyle(fontSize: 17.0),
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('naftal_perso Scanner',
              style: TextStyle(color: yellow)),
          backgroundColor: blue,
        ),
        body: Builder(builder: (BuildContext context) {
          return SingleChildScrollView(
              child: FutureBuilder(
                  future: getItems(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: blue,
                                    ),
                                    Text(
                                      "Associer un bien matériel",
                                      style: TextStyle(
                                          color: blue, fontSize: 20.0),
                                    )
                                  ],
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Icon(Icons.person),
                                          Expanded(
                                            child: Text(
                                              'UTILISATEUR : ${employe.EMP_FULLNAME}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                   
                                    TextButton.icon(
                                        style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: blue),
                                        onPressed: () async {
                                          await scanBarcodeNormal(context);
                                        },
                                        icon: Icon(Icons.add),
                                        label: Text("Scanner un article")),
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ou bien',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 10, 20, 20),
                                      child: TextFormField(
                                        controller: codeBarBien,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.qr_code_2,
                                            color: Colors.black,
                                          ),
                                          labelText: "Saisir Code article",
                                          labelStyle:
                                              TextStyle(color: Colors.black),

                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          //fillColor: Colors.green
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Icon(Icons.emoji_objects),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Etat: ${getEtat(MODE_SCAN)}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                                primary: Colors.white,
                                                backgroundColor: Colors.green
                                                // Text Color
                                                ),
                                            icon: Icon(Icons.check,
                                                color: Colors.white),
                                            label: Text("Valider"),
                                            onPressed: () async {

                                             await Check_localite(context);
                                            },
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ]),
                      );
                    } else {
                      return Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: SizedBox(
                                  height: 5,
                                  width: double.infinity,
                                  child: LinearProgressIndicator()),
                            )
                          ],
                        ),
                      );
                    }
                  })));
        }));
  }
}
// ignore_for_file: prefer_const_constructors