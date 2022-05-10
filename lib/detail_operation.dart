import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:naftal_perso/all_objects.dart';
import 'package:naftal_perso/create_Non_etiqu.dart';
import 'package:naftal_perso/create_bien.dart';
import 'package:naftal_perso/data/Bien_materiel.dart';
import 'package:naftal_perso/data/Employe.dart';
import 'package:naftal_perso/detail_bien.dart';
import 'package:naftal_perso/history.dart';
import 'package:naftal_perso/main.dart';
import 'package:naftal_perso/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';


class Detail_Operation extends StatefulWidget {
  const Detail_Operation({Key? key, required this.employe})
      : super(key: key);

  final Employe employe;
  @override
  _Detail_OperationState createState() =>
      _Detail_OperationState(employe: this.employe);
}

class _Detail_OperationState extends State<Detail_Operation> {
  _Detail_OperationState({required this.employe});
  String _scanBarcode = '';
  final Employe employe;
  var _currentIndex = 2;
  int _value = MODE_SCAN;
  bool visible = false;
  bool show_detail = false;

  late int nb_objects;
  late int nbSN;
  TextEditingController nomController = TextEditingController();
  List<Bien_materiel> list_objects = [];

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
  }

  Future<int> get_employe() async {
    if (list_objects.isEmpty) {
      

      list_objects = await employe.get_linked_Object();
      list_objects = list_objects.reversed.toList();
      nb_objects = list_objects.length;
      nbSN = await employe.countSN();

    }

    return nb_objects;
  }

  
  TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  Widget BienWidget(Bien_materiel bien) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.white70, spreadRadius: 1),
        ],
        gradient: LinearGradient(
          // ignore: prefer_const_literals_to_create_immutables
          colors: [
            Colors.white60,
            Colors.white60,
            Color.fromARGB(255, 238, 238, 238),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.qr_code),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Code bar :",
                  style: textStyle,
                ),
                Text(
                  bien.code_bar,
                  style: textStyle,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                    onPressed: () async{
                      Navigator.push(

                        context,
                        MaterialPageRoute(
                          builder: (context) => Detail_Bien(
                            bien_materiel: bien,
                            employe: employe,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: blue,
                    ),
                    icon: Icon(Icons.book),
                    label: Text("Détail"))
              ],
            ),
          )
        ],
      ),
    );
  }

  String get_etat() {
    switch (MODE_SCAN) {
      case 1:
        return "Bon";
      case 2:
        return "Hors service";
      case 3:
        return "A réformer";
    }
    return "";
  }

  Future<void> scanBarcodeNormal(BuildContext context) async {
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
      _scanBarcode = barcodeScanRes;
    });

    if (check_format(1, _scanBarcode) == false) {
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
          _scanBarcode,
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
        bool stored = await bien.exists();

        if (stored == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Create_Bien(
                employe: employe,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.info, color: Colors.white, size: 25),
                Text(
                  "une erreur est survenue veuillez réessayer",
                  style: TextStyle(fontSize: 17.0),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naftal Scanner', style: TextStyle(color: yellow)),
        backgroundColor: blue,
      ),
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
            child: FutureBuilder(
                future: get_employe(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.book,
                                    color: blue,
                                  ),
                                  Text(
                                    " Détail Utilisateur",
                                    style:
                                        TextStyle(color: blue, fontSize: 20.0),
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
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Nom : ${employe.EMP_FULLNAME}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Icon(Icons.badge),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Matricule : ${employe.EMP_ID}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                              
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Icon(Icons.format_list_numbered),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Nombre des articles totales:',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          (nb_objects+nbSN).toString(),
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                  
                                  Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 241, 241, 241)),
                                    padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                                    child: Row(children: [
                                      Icon(
                                        Icons.add,
                                        size: 25,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Ajouter des articles",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ]),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.rate_review),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Etat d'article",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            )
                                          ],
                                        ),
                                        Flex(
                                          direction: Axis.horizontal,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Column(children: [
                                                ListTile(
                                                  title: Text(
                                                    '',
                                                  ),
                                                  leading: Radio(
                                                    value: 3,
                                                    groupValue: _value,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _value = val as int;
                                                        MODE_SCAN = _value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Text('A réformer')
                                              ]),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(children: [
                                                ListTile(
                                                  title: Text(
                                                    '',
                                                  ),
                                                  leading: Radio(
                                                    value: 2,
                                                    groupValue: _value,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _value = val as int;
                                                        MODE_SCAN = _value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Text('Hors service')
                                              ]),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    ListTile(
                                                      title: Text(
                                                        '',
                                                      ),
                                                      leading: Radio(
                                                        value: 1,
                                                        groupValue: _value,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            _value = val as int;
                                                            MODE_SCAN = _value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Text('Bon         ')
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        TextButton.icon(
                                            style: TextButton.styleFrom(
                                                primary: Colors.white,
                                                backgroundColor: blue),
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Create_Bien(
                                                          employe:
                                                              employe,
                                                        )),
                                              );
                                            },
                                            icon: Icon(Icons.add),
                                            label: Text("Ajouter article",
                                            
                                            )),
                                               TextButton.icon(
                                            style: TextButton.styleFrom(
                                                primary: Colors.white,
                                                backgroundColor: Colors.red),
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Create_Non_etiqu(
                                                          employe:
                                                              employe,
                                                        )),
                                              );
                                            },
                                            icon: Icon(Icons.add),
                                            label: Text("Article SN",
                                            
                                            )),
                                       
                                      ],
                                    ),
                                  ),
                                
                                ],
                              ),
                            ),
                            Card(
                                child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 241, 241, 241)),
                                    padding: EdgeInsets.fromLTRB(5, 5, 10, 5),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Icon(
                                              Icons.list_alt,
                                              size: 25,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("Liste des articles",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ]),
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  show_detail = !show_detail;
                                                });
                                              },
                                              icon: (show_detail == true)
                                                  ? Icon(
                                                      Icons
                                                          .arrow_drop_up_outlined,
                                                      size: 35,
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .arrow_drop_down_outlined,
                                                      size: 35,
                                                    ))
                                        ]),
                                  ),
                                  Visibility(
                                    visible: show_detail,
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              230,
                                      child: ListView.builder(
                                          itemCount: list_objects.length,
                                          itemBuilder: (context, index) {
                                            return BienWidget(
                                                list_objects[index]);
                                          }),
                                    ),
                                  )
                                ],
                              ),
                            ))
                          ]),
                    );
                  } else {
                    return LinearProgressIndicator();
                  }
                }));
      }),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
                ModalRoute.withName('/'),
              );
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => History()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => All_objects()),
              );
              break;
          }
        },
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Accueil"),
            selectedColor: Color.fromARGB(255, 4, 50, 88),
          ),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.history),
            title: Text("Historique"),
            selectedColor: Color.fromARGB(255, 4, 50, 88),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.storage),
            title: Text("Serveur"),
            selectedColor: Color.fromARGB(255, 4, 50, 88),
          ),
        ],
      ),
    );
  }
}
// ignore_for_file: prefer_const_constructors