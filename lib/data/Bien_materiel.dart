import 'package:naftal_perso/data/User.dart';
import 'package:naftal_perso/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class Bien_materiel {
  /*
  état 1 = Bon 
  état 2 = Hors Service 
  état 3 = A réformer 

  */

  late final String code_bar;

  int etat = 3;
  String? date_scan;
  int stockage = 0;

  late String matricule;

  Bien_materiel(this.code_bar, this.etat, this.date_scan,
     this.stockage, this.matricule);


 String date_format() {
    DateTime day = DateTime.now();

    return "${day.day}/${day.month}/${day.year}    ${day.hour}:${day.minute}";
  }

  Map<String, dynamic> toMap() {
    return {
      "code_bar": code_bar,
      "etat": etat,
      "date_scan": date_scan,
      "matricule": matricule,
      "stockage": stockage
    };
  }

  Future<bool> local_check() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
        "Bien_materiel where code_bar  = '$code_bar' ");

    return (maps.length > 0);
  }

  Future<bool> net_check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try{

      
    User user  = await User.auth();    
      var dio = Dio();
      dio.options.headers["Authorization"]= 'Bearer ' +await user.getToken();
        final response =
            await dio.post('${IP_ADDRESS}existeBienDecharge', data: this.toJson(),  
            );
        if (response.toString() == "true") {
          return true;
        } else {
          return false;
        }
        }catch(e){
          return false;
      }

     
    } else {
      return false;
    }
  }

  Future<bool> exists() async {
    bool local = await local_check();
    bool net = await net_check();

    return local || net;
  }

  String get_state() {
    switch (this.etat) {
      case 1:
        return "Bon";
      case 2:
        return "Hors service";
      case 3:
        return "A réformer";
    }

    return "";
  }
  Future<User> get_User()async{
     final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query("T_E_GROUPE_INV where EMP_ID  = '${this.matricule}' ");

 
      return User(
        maps[0]["EMP_ID"],
        maps[0]["EMP_FULLNAME"],
        maps[0]["COP_ID"],
        maps[0]["INV_ID"],
        DateTime.now().add(Duration(days: 1)).toIso8601String(),
        maps[0]["JOB_LIB"],

           );
    

  }

  Future<bool> Store_Bien() async {
    this.date_scan = date_format();

    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
    User user  = await User.auth();    
      var dio = Dio();
      dio.options.headers["Authorization"]= 'Bearer ' +await user.getToken();
        final response =
            await dio.post('${IP_ADDRESS}create_bienDecharge', data: this.toJson());

        if (response == true) {
          this.stockage = 1;
        }
        this.stockage = 1;
        db.insert('Bien_materiel', this.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        return true;
      } on DioError {
         this.stockage = 0;
        db.insert('Bien_materiel', this.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        return true;
      }
    } else {
      await db.insert('Bien_materiel', this.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    }
  }

  Store_Bien_Soft() async {
    this.date_scan = date_format();

    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    try {
      if (this.stockage == 0) {
        db.rawUpdate(
            'UPDATE Bien_materiel SET etat = ${MODE_SCAN} where code_bar = \'${this.code_bar}\' ');
        return true;
      } else {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          try {
        User user  = await User.auth();    
      var dio = Dio();
      dio.options.headers["Authorization"]= 'Bearer ' +await user.getToken();
            final response =
                await dio.post('${IP_ADDRESS}create_bienDecharge', data: this.toJson());

            if (response.toString() == "true") {
              db.rawUpdate(
                  'UPDATE Bien_materiel SET etat = ${MODE_SCAN} where code_bar = \'${this.code_bar}\' ');
              return true;
            } else {
              return false;
            }
          } on DioError {
            return false;
          }
        } else {
          db.rawUpdate(
              'UPDATE Bien_materiel SET etat = ${MODE_SCAN} where code_bar = \'${this.code_bar}\' ');
          return true;
        }
      }
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> toJson() => {
        "code_bar": code_bar,
        "etat": etat,
        "date_scan": date_scan,
        "matricule": matricule,
        "stockage": stockage
      };
  static Future<List<Bien_materiel>> history() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query("Bien_materiel");

    return List.generate(maps.length, (i) {
      return Bien_materiel(
        maps[i]["code_bar"],
        maps[i]["etat"],
        maps[i]["date_scan"],
        maps[i]["stockage"],
        maps[i]["matricule"],
      );
    });
  }

  static Future<List<Bien_materiel>> synchonized_objects() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("Bien_materiel where stockage  = 0 ");

    return List.generate(maps.length, (i) {
      return Bien_materiel(
        maps[i]["code_bar"],
        maps[i]["etat"],
        maps[i]["date_scan"],
        maps[i]["stockage"],
        maps[i]["matricule"],
      );
    });
  }

  String toString() {
    return '''{ "code_bar": "$code_bar",
            "etat": $etat,
            "date_scan": "$date_scan",
            "matricule": "$matricule",
            "stockage": $stockage }''';
  }
}
