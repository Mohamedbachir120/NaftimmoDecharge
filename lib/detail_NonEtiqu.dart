import 'package:flutter/material.dart';
import 'package:naftal_perso/all_objects.dart';
import 'package:naftal_perso/create_bien.dart';
import 'package:naftal_perso/data/Non_Etiquete.dart';
import 'package:naftal_perso/detail_operation.dart';
import 'package:naftal_perso/history.dart';
import 'package:naftal_perso/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'data/Employe.dart';

class DetailNonEtiqu extends StatefulWidget {
  const DetailNonEtiqu(
      {Key? key,
      required this.non_etiqu,
      required this.employe
   
      })
      : super(key: key);

  final Non_Etiquete non_etiqu;
  final Employe employe;
 

  @override
  _DetailNonEtiquState createState() => _DetailNonEtiquState(
      non_etiqu: this.non_etiqu,
      employe: this.employe
   
      );
}

class _DetailNonEtiquState extends State<DetailNonEtiqu> {
 
  _DetailNonEtiquState(
      {required this.non_etiqu,
      required this.employe
      });

  final Non_Etiquete non_etiqu;
  final Employe employe;
  var _currentIndex = 2;

  late int nbrticle;
  Future<int> NBARTICLE() async {
    nbrticle = await employe.countSN();

    return nbrticle;
  }

  TextEditingController nomController = TextEditingController();

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
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
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.book,
                        color: blue,
                      ),
                      Text(
                        " Détail SN",
                        style: TextStyle(color: blue, fontSize: 20.0),
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
                            Icon(Icons.qr_code_2),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Code article : ${non_etiqu.num_serie}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.badge),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                'Nature : ${non_etiqu.nature}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.merge_type_sharp),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                'Modèle : ${non_etiqu.modele}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                   
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.person),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                'Utilisateur : ${employe.EMP_FULLNAME}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                          future: NBARTICLE(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                margin: EdgeInsets.all(10),
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Icon(Icons.format_list_numbered),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Nombre d'article SN possédés : ${nbrticle}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                      Container(
                        margin: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.blue[800]),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Detail_Operation(
                                        employe: employe,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.person),
                                label: Text("Utilisateur")),
                         
                                  TextButton.icon(
                                      style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: blue),
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Create_Bien(
                                              employe: employe,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text("Un article"))
                              
                            
                          ],
                        ),
                      ),
                   
                    ],
                  ),
                ),
              ]),
        ));
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

          /// Likes

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