import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naftal_perso/Login.dart';
import 'package:numberpicker/numberpicker.dart';
import 'data/User.dart';
import 'operations.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';

import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

const IP_ADDRESS = "http://10.96.3.21:8080/naftimobackend/";
// const IP_ADDRESS = "http://192.168.0.127:8080/";

int MODE_SCAN = 1;
int YEAR = DateTime.now().year;

var STRUCTURE = "";
const DBNAME = "naftal_scan2.db";

void main() {
  runApp(const ChoixStructure());
}

class ChoixStructure extends StatelessWidget {
  const ChoixStructure({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChoixStructure',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChoixStructurePage(title: 'NaftalAppScann'),
    );
  }
}

class ChoixStructurePage extends StatefulWidget {
  const ChoixStructurePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ChoixStructurePage> createState() => _ChoixStructurePageState();
}

class _ChoixStructurePageState extends State<ChoixStructurePage> {
  bool visibility = false;
  List<String> Structures = [];
  int minVal = DateTime.now().year - 1;
  int maxVal = DateTime.now().year + 1;

  @override
  void initState() {
    super.initState();
  }

  Future<int> initDatabase(BuildContext context) async {
    int nb = 0;

    String dbPathScan = join(await getDatabasesPath(), DBNAME);

    bool dbExistsScan = await io.File(dbPathScan).exists();
    if (!dbExistsScan) {
      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "naftal_scan2.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await io.File(dbPathScan).writeAsBytes(bytes, flush: true);
    }
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('User');

    nb = maps.length;

    if (nb > 0) {
      User user = User(maps[0]['matricule'], maps[0]['nom'], maps[0]['COP_ID'],
          maps[0]['INV_ID'], maps[0]["validity"], maps[0]["JOB_LIB"]);

      DateTime date = DateTime.parse(user.validity);
      DateTime now = DateTime.now();

      if (date.isAfter(now)) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
            (Route<dynamic> route) => false);
      } else {
        nb = 0;
        await db.execute("DELETE FROM User;");
        final List<Map<String, dynamic>> Struct = await db.query(
            'T_E_LOCATION_LOC',
            distinct: true,
            columns: ['COP_ID', 'COP_LIB']);

        Structures = List.generate(Struct.length, (i) {
          return "${Struct[i]['COP_ID']} - ${Struct[i]['COP_LIB']}";
        });
      }
    } else {
      final List<Map<String, dynamic>> Struct = await db.query(
          'T_E_LOCATION_LOC',
          distinct: true,
          columns: ['COP_ID', 'COP_LIB']);

      Structures = List.generate(Struct.length, (i) {
        return "${Struct[i]['COP_ID']} - ${Struct[i]['COP_LIB']}";
      });
    }
    return nb;
  }

  void change_visibilty() {
    setState(() {
      visibility = !visibility;
    });
  }

  void Show_Error(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Colors.white, size: 20),
          Text(
            "Centre d'opération invalide",
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: initDatabase(context),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data != 1) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Naftal Scanner',
                      style: TextStyle(color: Colors.yellow)),
                  backgroundColor: Color.fromRGBO(0, 73, 132, 1),
                ),
                body: SingleChildScrollView(
                    child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/team.jpg",
                        width: double.infinity,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.home_filled,
                              size: 23,
                              color: Colors.blue[900],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                "Centre d'opération",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color.fromRGBO(0, 73, 132, 1)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                          alignment: Alignment.center,
                          child: EasyAutocomplete(
                            suggestions: Structures,
                            onChanged: (value) => setState(() {
                              STRUCTURE = value;
                            }),
                            onSubmitted: (value) => (value) => setState(() {
                                  STRUCTURE = value;
                                }),
                          )),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 23,
                              color: Colors.blue[900],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Année d'inventaire",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color.fromRGBO(0, 73, 132, 1)),
                            )
                          ],
                        ),
                      ),
                      Builder(builder: (context) {
                        return NumberPicker(
                          value: YEAR,
                          minValue: minVal,
                          maxValue: maxVal,
                          onChanged: (value) => setState(() => YEAR = value),
                        );
                      }),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                primary: Colors.yellow[700],
                                onPrimary: Colors.white,
                              ),
                              onPressed: () async {
                                print(STRUCTURE);
                                change_visibilty();
                                try {
                                  setState(() {
                                    if (STRUCTURE.contains("-")) {
                                      STRUCTURE = STRUCTURE.substring(
                                          0, STRUCTURE.indexOf("-") - 1);
                                    }
                                  });
                                  if (STRUCTURE.length >= 1) {
                                    final database = openDatabase(
                                        join(await getDatabasesPath(), DBNAME));
                                    final db = await database;

                                    final List<
                                        Map<String,
                                            dynamic>> maps = await db.query(
                                        "T_E_LOCATION_LOC where COP_ID = '${STRUCTURE}'; ");
                                    if (maps.length > 0) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage()));
                                    } else {
                                      Show_Error(context);
                                    }
                                  } else {
                                    Show_Error(context);
                                  }
                                } catch (e) {
                                  Show_Error(context);
                                }
                                change_visibilty();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: <Widget>[
                                    Text(
                                      'Continuer',
                                      style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 30,
                                    )
                                  ],
                                ),
                              )),
                        ],
                      ),
                      SizedBox(height: 15),
                      Visibility(
                        visible: visibility,
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            color: Colors.yellow[700],
                          ),
                        ),
                      )
                    ],
                  ),
                )));
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
            ));
          }
        },
      ),
    );
  }
}
