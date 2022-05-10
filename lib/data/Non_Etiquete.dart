import 'package:naftal_perso/data/User.dart';
import 'package:naftal_perso/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class Non_Etiquete {
  /*
  état 1 = Bon 
  état 2 = Hors Service 
  état 3 = A réformer 

  */

  late final String num_serie;

  int etat = 3;
  String? date_scan;
  int stockage = 0;

  late String matricule;
  late String marque;
  late String modele;
  late String nature;
  int nombre=1;

  Non_Etiquete(this.num_serie, this.etat, this.date_scan,
     this.stockage, this.matricule, this.marque,this.modele,this.nature,this.nombre );

 String date_format() {
    DateTime day = DateTime.now();

    return "${day.day}/${day.month}/${day.year}    ${day.hour}:${day.minute}";
  }

  Map<String, dynamic> toMap() {
    return {
      "num_serie": num_serie,
 
      "etat": etat,
      "date_scan": date_scan,
      "matricule": matricule,
      "stockage": stockage,
      "marque":marque,
      "modele":modele,
      "nature":nature,
      "nombre":nombre

    };
  }

  Future<bool> local_check() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
        "Non_Etiquete where num_serie  = '$num_serie'  ");

    return (maps.length > 0);
  }

  Future<bool> net_check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {

      User user  = await User.auth();    
      var dio = Dio();
      dio.options.headers["Authorization"]= 'Bearer ' +await user.getToken();     
      final response =
          await dio.post('${IP_ADDRESS}existeNon_EtiqueDecharge', data: this.toJson());
      if (response.toString() == "true") {
        return true;
      } else {
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

  Future<bool> Store_Non_Etique() async {
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
            await dio.post('${IP_ADDRESS}create_NonEtiquDecharge', data: this.toJson());

        if (response == true) {
          this.stockage = 1;
        }
        this.stockage = 1;
        db.insert('Non_Etiquete', this.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        return true;
      } on DioError {
         this.stockage = 0;
        db.insert('Non_Etiquete', this.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        return true;
      }
    } else {
     
        await db.insert('Non_Etiquete', this.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          return true;
    }
  }

  Store_Non_Etique_Soft() async {
    this.date_scan = date_format();

    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    try {
      if (this.stockage == 0) {
        db.rawUpdate(
            'UPDATE Non_Etiquete SET etat = ${MODE_SCAN} where num_serie = \'${this.num_serie}\' ');
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
                await dio.post('${IP_ADDRESS}create_NonEtiquDecharge', data: this.toJson());

            if (response.toString() == "true") {
              db.rawUpdate(
                  'UPDATE Non_Etiquete SET etat = ${MODE_SCAN} where num_serie = \'${this.num_serie}\' ');
              return true;
            } else {
              return false;
            }
          } on DioError {
            return false;
          }
        } else {
          db.rawUpdate(
              'UPDATE Non_Etiquete SET etat = ${MODE_SCAN} where num_serie = \'${this.num_serie}\' ');
          return true;
        }
      }
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> toJson() => {
        "num_serie": num_serie,
        "etat": etat,
        "date_scan": date_scan,
        "matricule": matricule,
        "stockage": stockage,
        "marque":marque,
        "modele":modele,
        "nature":nature,
        "nombre":nombre
      };
  static Future<List<Non_Etiquete>> history() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query("Non_Etiquete");

    return List.generate(maps.length, (i) {
      return Non_Etiquete(
        maps[i]["num_serie"],
        maps[i]["etat"],
        maps[i]["date_scan"],
        maps[i]["stockage"],
        maps[i]["matricule"],
        maps[i]["marque"],
        maps[i]["modele"],
        maps[i]["nature"],
        maps[i]["nombre"]
      );
    });
  }

  static Future<List<Non_Etiquete>> synchonized_objects() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("Non_Etiquete where stockage  = 0 ");

    return List.generate(maps.length, (i) {
      return Non_Etiquete(
        maps[i]["num_serie"],
        maps[i]["etat"],
        maps[i]["date_scan"],
        maps[i]["stockage"],
        maps[i]["matricule"],
        maps[i]["marque"],
        maps[i]["modele"],
        maps[i]["nature"],
        maps[i]["nombre"]

      );
    });
  }

  String toString() {
    return '''{ "num_serie": "$num_serie",
            "etat": $etat,
            "date_scan": "$date_scan",
            "matricule": "$matricule",
            "stockage": $stockage,
             "marque": "$marque" ,
            "modele": "$modele" ,
            "nature" : "$nature" ,
            "nombre" : $nombre

            
            }''';
  }
}
