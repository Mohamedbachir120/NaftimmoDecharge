
import 'package:dio/dio.dart';
import 'package:naftal_perso/data/Bien_materiel.dart';
import 'package:naftal_perso/data/LoginInfos.dart';
import 'package:naftal_perso/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  late String matricule;
  late String nom;
  late String COP_ID;
  late String INV_ID;
  late String JOB_LIB;

  late String validity;

  late String? token;
  User(String matricule, String nom, String COP_ID, String INV_ID,
      String validity, String JOB_LIB) {
    this.matricule = matricule;
    this.nom = nom;
    this.COP_ID = COP_ID;
    this.INV_ID = INV_ID;
    this.validity = validity;
    this.JOB_LIB = JOB_LIB;
  }

  Map<String, dynamic> toMap() {
    return {
      'matricule': matricule,
      'nom': nom,
      'COP_ID': COP_ID,
      'INV_ID': INV_ID,
      "validity": validity,
      "JOB_LIB": JOB_LIB
    };
  }

  Map<String, dynamic> toJson() => {
        'matricule': matricule,
        'nom': nom,
        'COP_ID': COP_ID,
        'INV_ID': INV_ID,
        "validity": validity,
        "JOB_LIB": JOB_LIB
      };

  static Future<String> getName(String matricule) async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("T_E_GROUPE_INV where EMP_ID  = '${matricule}' ");
    return maps[0]["EMP_FULLNAME"];
  }

  static Future<User> getBymatricule(String matricule) async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("T_E_GROUPE_INV where EMP_ID  = '${matricule}' ");
    return User(
        maps[0]['EMP_ID'],
        maps[0]['EMP_FULLNAME'],
        maps[0]['COP_ID'],
        maps[0]["INV_ID"],
        DateTime.now().add(Duration(days: 1)).toIso8601String(),
        maps[0]["JOB_LIB"]);
  }

  Future<List<Bien_materiel>> get_linked_Object() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("Bien_materiel where matricule  = '${this.matricule}' ");

    return List.generate(maps.length, (i) {
      return Bien_materiel(maps[i]['code_bar'], maps[i]['etat'],
          maps[i]['date_scan'], maps[i]['stockage'], maps[i]['matricule']);
    });
  }

  static check_user() async {
    try {
      final database = openDatabase(join(await getDatabasesPath(), DBNAME));
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query('User');

      return maps.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<User> auth() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('User');

    return User(maps[0]['matricule'], maps[0]['nom'], maps[0]['COP_ID'],
        maps[0]['INV_ID'], maps[0]["validity"], maps[0]["JOB_LIB"]);
  }

  static show_users() async {
    User user = await User.auth();
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("T_E_GROUPE_INV where COP_ID  = '${user.COP_ID}' ");

    return List.generate(maps.length, (i) {
      return User(
          maps[i]['EMP_ID'],
          maps[i]['EMP_FULLNAME'],
          user.COP_ID,
          maps[i]["INV_ID"],
          DateTime.now().add(Duration(days: 1)).toIso8601String(),
          maps[i]["JOB_LIB"]);
    });
  }

  Future<int> countSN() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("Non_Etiquete  where matricule = '${this.matricule}'");

    return maps.length;
  }

  Future<String> getToken() async {
    try {
      
    var dio = Dio();
    final response = await dio.post(
      '${IP_ADDRESS}api/auth/signin',
      data: LoginInfo(username: this.matricule, password: "a").toJson(),
    );

    final data = response.data;
    print(response);
    return(data["accessToken"]).toString();
    } catch (e) {
      return "";
    }
  }

  @override
  String toString() {
    return 'User{matricule: $matricule, name: $nom}';
  }
}
