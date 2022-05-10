
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:naftal_perso/data/LoginInfos.dart';
import 'package:naftal_perso/data/User.dart';
import 'package:naftal_perso/main.dart';
import 'operations.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool visibility = false;
  @override
  void initState() {
    super.initState();
  }

  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<int> fetchUser(BuildContext context) async {
    int nb = await User.check_user();
    if (nb > 0) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false);
    }

    return nb;
  }

  void change_visibilty() {
    setState(() {
      visibility = !visibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUser(context),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != 1) {
          return Scaffold(
              body: SingleChildScrollView(
                  child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // ignore: prefer_const_literals_to_create_immutables
                colors: [
                  Color.fromRGBO(0, 73, 132, 1),
                  Color.fromRGBO(0, 73, 132, 1),
                  Color.fromRGBO(0, 73, 132, 1),
                  Color.fromRGBO(0, 73, 132, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 34.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // ignore: deprecated_member_use
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            child: Text(
                              "Connectez-vous",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 227, 24, 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage(
                              "assets/naftal.png",
                            ),
                            height: 170,
                            width: 170,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 3,
                                  blurRadius: 3,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                labelText: "Matricule",
                                hintText: "Matricule",
                                labelStyle: TextStyle(color: Colors.black),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                //fillColor: Colors.green
                              ),
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 3,
                                  blurRadius: 3,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.black,
                                  ),
                                ),
                                labelText: "Mot de passe",
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                //fillColor: Colors.green
                              ),
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextButton(
                            onPressed: () async {},
                            child: Text(
                              "Mot de passe oubliée?",
                              style: TextStyle(
                                color: const Color.fromRGBO(0, 73, 132, 1),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                primary: const Color.fromRGBO(0, 73, 132, 1),
                                onPrimary: Colors.white,
                              ),
                              onPressed: () async {
                                change_visibilty();
                           


                                if (emailController.text.trim().length > 5 &&
                                    passwordController.text.trim() == "a") {
                                      User user ;
                                  final database = openDatabase(
                                      join(await getDatabasesPath(), DBNAME));

                                  final db = await database;
                                  final List<
                                      Map<String,
                                          dynamic>> maps = await db.query(
                                      "T_E_GROUPE_INV where EMP_ID = '${emailController.text.trim()}' and YEAR = ${YEAR} and COP_ID = '${STRUCTURE}' ");

                                  if (maps.length > 0) {
                                     user = User(
                                      maps[0]["EMP_ID"],
                                      maps[0]["EMP_FULLNAME"],
                                      STRUCTURE,
                                      maps[0]["INV_ID"],
                                      DateTime.now().add(Duration(days: 1)).toIso8601String(),
                                      maps[0]["JOB_LIB"]
                                    );
                                     db.insert('User', user.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
                                    Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) =>  MyApp()),
                                    ModalRoute.withName('/Login'),
                                  );
                                  }else{

                                     ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.info,
                                            color: Colors.white, size: 20),
                                        Text(
                                          "Matricule ou Mot de passe incorrect",
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                  ));

                                  }

                                 
                                  change_visibilty();
                                } else {
                                  change_visibilty();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.info,
                                            color: Colors.white, size: 20),
                                        Text(
                                          "Nom ou Mot de passe incorrect",
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                }
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
                                      'Connexion',
                                      style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Visibility(
                              visible: visibility,
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ))
                        ],
                      ),
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
    );
  }
}
