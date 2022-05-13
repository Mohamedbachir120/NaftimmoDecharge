import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:naftal_perso/all_objects.dart';
import 'package:naftal_perso/data/Bien_materiel.dart';
import 'package:naftal_perso/data/Employe.dart';
import 'package:naftal_perso/detail_bien.dart';
import 'package:naftal_perso/main.dart';
import 'package:naftal_perso/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sqflite/sqflite.dart';

import 'data/User.dart';
import 'package:path/path.dart';

void main() {
  runApp(const History());
}

class History extends StatelessWidget {
  const History({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'History',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HistoryPage(title: 'NaftalAppScann'),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<Bien_materiel> list;
  late User user;
  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);
  var _currentIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  Widget BienWidget(Bien_materiel bien, BuildContext context) {
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
            Colors.white,
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
              children: [
                Icon(Icons.timer),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Scanné le :",
                  style: textStyle,
                ),
                Text(
                  bien.date_scan.toString(),
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
                    onPressed: () async {
                      Employe employe =
                          await Employe.getBymatricule(bien.matricule);
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

  Future<List> fetchBien(BuildContext context) async {
    user = await User.auth();
    list = await Bien_materiel.history();
    list = list.reversed.toList();

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchBien(context),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && list.length > 0) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title:
                  const Text('Naftal Scanner', style: TextStyle(color: yellow)),
              backgroundColor: blue,
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration:
                      BoxDecoration(color: Color.fromARGB(255, 244, 246, 247)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history, size: 30, color: blue),
                          Text(
                            "Historique des articles",
                            style: TextStyle(
                                fontSize: 20,
                                color: blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.green,
                        child: IconButton(
                            onPressed: () async {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.sync,
                                        color: Colors.black87, size: 25),
                                    Text(
                                      "Synchronisation en cours",
                                      style: TextStyle(
                                          fontSize: 17.0,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                                backgroundColor:
                                    Color.fromARGB(255, 214, 214, 214),
                              ));
                              List<Bien_materiel> objects =
                                  await Bien_materiel.synchonized_objects();

                              User user = await User.auth();
                              Dio dio = Dio();
                              dio.options.headers["Authorization"] =
                                  'Bearer ' + await user.getToken();
                              var response = await dio.post(
                                  '${IP_ADDRESS}save_manyDecharge',
                                  data: jsonEncode(objects));

                              if (response.toString() == "true") {
                                final database = openDatabase(join(
                                    await getDatabasesPath(),
                                    DBNAME));
                                final db = await database;
                                await db.rawUpdate(
                                    "UPDATE Bien_materiel SET stockage = 1 where stockage = 0");

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.check,
                                          color: Colors.white, size: 25),
                                      Text(
                                        "Synchronisation effectuée avec succès",
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                ));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.info,
                                          color: Colors.white, size: 25),
                                      Text(
                                        "une erreur est survenue veuillez réessayer",
                                        style: TextStyle(fontSize: 17.0),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            },
                            icon: Icon(
                              Icons.sync_sharp,
                              size: 20,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 225,
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return (BienWidget(list[index], context));
                    },
                    physics: ScrollPhysics(),
                  ),
                )
              ],
            )),
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
        } else if (snapshot.connectionState == ConnectionState.done &&
            list.length == 0) {
          return Scaffold(
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                      child: Icon(
                    Icons.history,
                    size: 35,
                  )),
                  Center(
                      child: Text(
                    "La liste d'historique est vide",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ))
                ],
              ),
            ),
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
        } else {
          return Scaffold(
            body: Container(
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
            ),
          );
        }
      },
    );
  }
}
