import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:naftal_perso/all_non_etique.dart';
import 'package:naftal_perso/data/Employe.dart';
import 'package:naftal_perso/data/Non_Etiquete.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path/path.dart';

import 'package:naftal_perso/main.dart';
import 'package:sqflite/sqflite.dart';

class Create_Non_etiqu extends StatefulWidget {
  final Employe employe;
  const Create_Non_etiqu({Key? key, required this.employe}) : super(key: key);


  @override
  _Create_Non_etiquState createState() => _Create_Non_etiquState(employe:this.employe);
}

class _Create_Non_etiquState extends State<Create_Non_etiqu> {
  final Employe employe;
  _Create_Non_etiquState({required this.employe});
  
  int _value = 1;
  TextEditingController codeBar = TextEditingController();
  List<String> Natures = [];
  var visibile = false;

  
  TextEditingController nomController = TextEditingController();
  TextEditingController num_versionController = TextEditingController();
  TextEditingController marqueController = TextEditingController();
  TextEditingController modeleController = TextEditingController();
  TextEditingController natureController = TextEditingController();

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);

  @override
  void initState() {
    super.initState();
  }

  Future<int> getItems() async {
    final database = openDatabase(join(await getDatabasesPath(), DBNAME));
    final db = await database;

     final List<Map<String, dynamic>> natures = await db.query(
        'FIM_IMMOBILISATION',
        distinct: true,
        columns: ['FIM_ID','FIM_LIB']);
    Natures = List.generate(natures.length, (i){ 
        
        return "${natures[i]['FIM_ID']} ${natures[i]['FIM_LIB']}";


    });

        
    return natures.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Naftal Scanner', style: TextStyle(color: yellow)),
          backgroundColor: blue,
        ),
        body: Builder(builder: (BuildContext context) {
          return FutureBuilder(
            future: getItems(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                Color.fromRGBO(235, 242, 250, 1),
                                Color.fromRGBO(235, 242, 250, 0.7),
                                Color.fromRGBO(235, 242, 250, 0.5)
                              ])),
                          margin: EdgeInsets.only(bottom: 15),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: blue,
                              ),
                              Expanded(
                                child: Text(
                                  "Ajouter un article non etiqueté",
                                  style: TextStyle(color: blue, fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [
                             Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: TextFormField(
                                    controller: num_versionController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.numbers,
                                        color: Colors.black,
                                      ),
                                      labelText: "Numéro de série",
                                      hintText: "example : 1234898374",
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                    ),
                                  )),
                              Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: TextFormField(
                                    controller: marqueController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.ballot_rounded,
                                        color: Colors.black,
                                      ),
                                      labelText: "Marque",
                                      hintText: "Marque d'article",
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                    ),
                                  )),
                              Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: TextFormField(
                                    controller: modeleController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.merge_type_sharp,
                                        color: Colors.black,
                                      ),
                                      labelText: "Modèle",
                                      hintText: "Modèle d'article",
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                    ),
                                  )),
                             Container(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  alignment: Alignment.center,
                                  child: EasyAutocomplete(
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.badge,
                                        color: Colors.black,
                                      ),
                                      labelText: "Nature d'article",
                                      labelStyle:
                                          TextStyle(color: Colors.black),

                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      //fillColor: Colors.green
                                    ),
                                    suggestions: Natures,
                                    onChanged: (value) => setState(() {
                                      natureController.text = value;
                                    }),
                                    onSubmitted: (value) =>
                                        (value) => setState(() {
                                              natureController.text = value;
                                            }),
                                  )),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                                alignment: Alignment.centerLeft,
                                child: Row(children: [
                                  Icon(Icons.format_list_numbered),
                                  Text(
                                    "Nombre d'article ",
                                    style: TextStyle(fontSize: 18),
                                  )
                                ]),
                              ),
                              Builder(builder: (context) {
                                return NumberPicker(
                                  value: _value,
                                  minValue: 0,
                                  maxValue: 20,
                                  onChanged: (value) =>
                                      setState(() => _value = value),
                                );
                              }),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
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

                                        if( num_versionController.text.trim().length > 0 && marqueController.text.trim().length > 0 && modeleController.text.trim().length > 0 && natureController.text.trim().length > 0 ){
                                        
                                        visibile = !visibile;


                                     

                                       Non_Etiquete  etiqu = Non_Etiquete(num_versionController.text,
                                         MODE_SCAN,
                                          DateTime.now().toIso8601String(),
                                            0, 
                                            employe.EMP_ID,
                                            marqueController.text,
                                            modeleController.text,
                                            natureController.text, 
                                            _value
                                            );

                                        

                                        bool stored =
                                            await etiqu.Store_Non_Etique();

                                        if (stored == true) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>  All_Non_Etiqu(),
                                              ),
                                            );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.info,
                                                    color: Colors.white,
                                                    size: 25),
                                                Text(
                                                  "une erreur est survenue veuillez réessayer",
                                                  style:
                                                      TextStyle(fontSize: 17.0),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                        }   
                                          visibile = !visibile;
                                        }else{
                                            ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.info,
                                                    color: Colors.white,
                                                    size: 25),
                                                Text(
                                                  "Veuillez remplir tous les champs",
                                                  style:
                                                      TextStyle(fontSize: 17.0),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.red,
                                          ));

                                        }
                                      },
                                    )
                                  ],
                                ),

                              ),
                              Visibility(
                                visible: visibile,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Center(child: SizedBox(width: 30,height: 30,child:CircularProgressIndicator()),
                                )),
                              )
                            ],
                          ),
                        ),
                      ]),
                ));
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
          );
        }));
  }
}
// ignore_for_file: prefer_const_constructors