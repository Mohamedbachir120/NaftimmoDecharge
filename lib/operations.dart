import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naftal_perso/all_non_etique.dart';
import 'package:naftal_perso/all_objects.dart';
import 'package:naftal_perso/data/Bien_materiel.dart';
import 'package:naftal_perso/data/Equipe.dart';
import 'package:naftal_perso/data/User.dart';
import 'package:naftal_perso/history.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:skeleton_animation/skeleton_animation.dart';
import 'data/Localisation.dart';
import 'main.dart';

void main() => runApp(MyApp());


List tileList = [
  [null, null],
  [null, Colors.blue],
  [null, Colors.blue.shade900],
  [Colors.green, Colors.blue.shade900],
  [null, Colors.green],
  [null, Colors.green.shade900],
  [null, Colors.red],
  [null, Colors.red.shade200]
];

bool check_format(int type, String value) {
  if (type == 0) {
    // Expression réguliére pour les localisations

    final localisation = RegExp(r'^([A-Z]|[0-9]){4}L([A-Z]|[0-9]){6,8}$');
    final localisation2 = RegExp(r'^K[0-9]{4}L[0-9]{5}$');

    return localisation.hasMatch(value) || localisation2.hasMatch(value);
  } else if (type == 1) {
    // Expression réguliére pour les bien Matériaux

    final BienMateriel = RegExp(r'^[A-Z]([0-9]|[A-Z]){9,14}$');

    return BienMateriel.hasMatch(value);
  }
  return true;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String username = "";
  String post_user = "";
  String annee = "";
  String cop_lib = "";
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  late Future<int> initAPP;

  Future<int> _initPackageInfo() async {
    await initConnectivity();
  if(_connectionStatus == ConnectivityResult.wifi){
    User user = await User.auth();
    try {
      
    
    Dio dio = Dio();
      dio.options.headers["Authorization"]= 'Bearer ' +await user.getToken();

    var response =
    await dio.get('${IP_ADDRESS}api/auth/lastVersion');

     final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;
     List<Map<String, dynamic>> list = await db.query(
        'updates',
        columns: ['version']);

    var lastVersion = response.data['version'];

    if(list[0]["version"] != response.data['version']){
      var response =  await dio.get('${IP_ADDRESS}localite');
     List temp = response.data;
    List<Localisation> loc =  List.generate(temp.length, (i) {
      return Localisation(
        temp[i]['loc_ID'],
        temp[i]['loc_LIB'],
        temp[i]['cop_LIB'],
        temp[i]['cop_ID']
      );
    });
      
      response = await dio.get('${IP_ADDRESS}equipe');
      temp = response.data;

      List<Equipe> equi = List.generate(temp.length, (i) {

        return Equipe(
          YEAR: temp[i]['year'] ,
         INV_ID:  temp[i]['inv_ID'], 
         COP_ID:  temp[i]['cop_ID'],
          EMP_ID:  temp[i]['emp_ID'], 
          EMP_FULLNAME:  temp[i]['emp_FULLNAME'], 
          JOB_LIB:  temp[i]['job_LIB'],
           GROUPE_ID:  temp[i]['groupe_ID'], 
           EMP_IS_MANAGER:  temp[i]['emp_IS_MANAGER']);

      });

      var batch = db.batch();
       batch.execute("DELETE FROM T_E_LOCATION_LOC;");
       batch.execute("DELETE FROM T_E_GROUPE_INV;");


      for (var item in loc) {
        batch.insert('T_E_LOCATION_LOC', item.toMap());
      }
      for(var item in equi){
        batch.insert('T_E_GROUPE_INV', item.toMap());
      }

      batch.insert('updates',{ "id":1,"version":lastVersion},
      conflictAlgorithm: ConflictAlgorithm.replace);
      await batch.commit(noResult: true);
    }
    
    }
    catch (e) {
    }
    
    }
    final info = await PackageInfo.fromPlatform();
      _packageInfo = info;
    return 0;
  }

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initAPP = _initPackageInfo();

  }

  @override
  dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status' + e.toString());
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }


  void synchronize(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.sync, color: Colors.black87, size: 25),
          Text(
            "Synchronisation en cours",
            style: TextStyle(fontSize: 17.0, color: Colors.black87),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 214, 214, 214),
    ));
    List<Bien_materiel> objects = await Bien_materiel.synchonized_objects();
      User user  = await User.auth();    
    Dio dio = Dio();
      dio.options.headers["Authorization"]= 'Bearer ' +await user.getToken();
    var response =
        await dio.post('${IP_ADDRESS}save_manyDecharge', data: jsonEncode(objects));

    

    if (response.toString() == "true") {
      final database = openDatabase(join(await getDatabasesPath(), DBNAME));
      final db = await database;
      await db.rawUpdate(
          "UPDATE Bien_materiel SET stockage = 1 where stockage = 0");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.check, color: Colors.white, size: 25),
            Text(
              "Synchronisation effectuée avec succès",
              style: TextStyle(fontSize: 17.0, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green,
      ));
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

  Future<String> User_infos() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;
    User user = await User.auth();
    final List<Map<String, dynamic>> list1 = await db.query(
        'T_E_LOCATION_LOC where COP_ID = "${user.COP_ID}"',
        distinct: true,
        columns: ['COP_LIB']);

    final List<Map<String, dynamic>> list2 = await db.query(
        'T_E_GROUPE_INV where EMP_ID = "${user.matricule}"',
        distinct: true,
        columns: ['JOB_LIB', 'YEAR']);
if(username.length <= 2){

      cop_lib = list1[0]["COP_LIB"];
      username = user.nom;
      annee = list2[0]["YEAR"].toString();
      post_user = list2[0]["JOB_LIB"];
    
}

    return username;
  }

  @override
  Widget build(BuildContext context1) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text(
          'Naftal Perso',
          style: TextStyle(color: yellow),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Builder(builder: ((context) {
              switch (_connectionStatus) {
                case ConnectivityResult.mobile:
                  return IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  TextButton.icon(
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        synchronize(context1);
                                      },
                                      icon: Icon(Icons.sync_sharp,
                                          size: 20, color: Colors.white),
                                      label: Text(
                                        "synchroniser les données",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ))
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.network_cell),
                  );
                case ConnectivityResult.wifi:
                  return IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    TextButton.icon(
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.green),
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          synchronize(context1);
                                        },
                                        icon: Icon(Icons.sync_sharp,
                                            size: 20, color: Colors.white),
                                        label: Text(
                                          "synchroniser les données",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.wifi));
                default:
                  return Icon(Icons.wifi_off_sharp);
              }
            })),
          )
        ],
        backgroundColor: blue,
      ),
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
            child: FutureBuilder(
          future: initAPP,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: blue,
                          ),
                          Text(
                            "  MES OPÉRATIONS",
                            style: TextStyle(color: blue, fontSize: 20.0),
                          )
                        ],
                      ),
                    ),
                 
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextButton(
                        child: Column(children: [
                          Icon(
                            Icons.history,
                            color: blue,
                            size: 30,
                          ),
                          Text(
                            'Historique des opérations',
                            style: TextStyle(color: blue, fontSize: 18),
                          )
                        ]),
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => History()),
                          )
                        },
                      ),
                    ),


                      Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextButton(
                        child: Column(children: [
                          Icon(
                            Icons.device_unknown_sharp,
                            color: blue,
                            size: 30,
                          ),
                          Text(
                            'Liste des articles SN',
                            style: TextStyle(color: blue, fontSize: 18.0),
                          )
                        ]),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => All_Non_Etiqu()),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextButton(
                        child: Column(children: [
                          Icon(
                            Icons.person_search,
                            color: blue,
                            size: 30,
                          ),
                          Text(
                            'Tous les agents',
                            style: TextStyle(color: blue, fontSize: 18.0),
                          )
                        ]),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => All_objects()),
                          );
                        },
                      ),
                    ),
                 
                   
                 
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "version :${_packageInfo.version}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey),
                        )
                      ],
                    )
                  ]);
            } else {
              return Container(
                padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Skeleton(
                  width: 300,
                  height: 30,
                ),
                SizedBox(height: 30,),

                Skeleton(
                  width: double.infinity,
                  height: 80,
                ),
                SizedBox(height: 10,),
                Skeleton(
                  width: double.infinity,
                  height: 80,
                ),
                SizedBox(height: 10,),
                Skeleton(
                  width: double.infinity,
                  height: 80,
                )
              ],

            ));
        
            }
          }),
        ));
      }),
      drawer: Drawer(
        child: Card(
            child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255)
              ])),
          padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
          child: FutureBuilder(
            future: User_infos(),
            builder: (context1, snapshot) {
              if (snapshot.hasData) {
                return Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        child: Image(
                          image: AssetImage("assets/avatar.png"),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30, bottom: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_pin,
                          color: blue,
                        ),
                        Text(
                          "  MES INFORMATIONS",
                          style: TextStyle(color: blue, fontSize: 20.0),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.person),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "${username}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.engineering),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "${post_user}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_month),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "ANNEE D'INVENTAIRE : ${annee}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                     
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.home),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "${cop_lib}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                          onPressed: () async {
                            final database = openDatabase(
                                join(await getDatabasesPath(), DBNAME));
                            final db = await database;
                            await db.execute("DELETE FROM User;");

                            Navigator.pushAndRemoveUntil(
                              super.context,
                              MaterialPageRoute(
                                  builder: (context) => ChoixStructure()),
                              ModalRoute.withName('/structure'),
                            );
                          },
                          icon: Icon(
                            Icons.logout,
                            color: blue,
                          ),
                          label: Text(
                            "Déconnexion",
                            style: TextStyle(color: blue),
                          ))
                    ],
                  ))
                ]);
              } else {
                return Container();
              }
            },
          ),
        )),
      ),
    );
  }
}
// ignore_for_file: prefer_const_constructors