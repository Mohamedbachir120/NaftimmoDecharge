import 'package:naftal_perso/data/Bien_materiel.dart';
import 'package:naftal_perso/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Employe {
  String EMP_ID;
  String EMP_FULLNAME;
  Employe({required this.EMP_ID, required this.EMP_FULLNAME});

  static show_employes() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query("T_E_EMPLOYE");

    return List.generate(maps.length, (i) {
      return Employe(
          EMP_ID: maps[i]["EMP_ID"], EMP_FULLNAME: maps[i]["EMP_FULL_NAME"]);
    });
  }
   Future <int> countSN() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("Non_Etiquete  where matricule = '${this.EMP_ID}'");
   
     return maps.length;   


  }


  Future<List<Bien_materiel>> get_linked_Object() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("Bien_materiel where matricule  = '${this.EMP_ID}' ");

    return List.generate(maps.length, (i) {
      return Bien_materiel(
          maps[i]['code_bar'],
          maps[i]['etat'],
          maps[i]['date_scan'],
          maps[i]['stockage'],
          maps[i]['matricule']
          );
    });
  }

  static Future<Employe> getBymatricule(String matricule) async{
     final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("T_E_EMPLOYE where EMP_ID  = '${matricule}' ");
      return Employe(
         EMP_ID: maps[0]['EMP_ID'],
         EMP_FULLNAME: maps[0]['EMP_FULL_NAME'],
         
          );
       
       


  }
}
