import 'package:flutter/material.dart';

import 'package:naftal_perso/data/Employe.dart';
import 'package:naftal_perso/detail_operation.dart';

import 'package:naftal_perso/history.dart';
import 'package:naftal_perso/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() {
  runApp(const All_objects());
}

class All_objects extends StatelessWidget {
  const All_objects({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'All_objects',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const All_objectsPage(title: 'NaftalAppScann'),
    );
  }
}

class All_objectsPage extends StatefulWidget {
  const All_objectsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<All_objectsPage> createState() => _All_objectsPageState();
}

class _All_objectsPageState extends State<All_objectsPage> {
List<Employe> list = [];
late Employe user ;
List<Employe> duplicated = [];


  var _currentIndex = 3;
  TextEditingController editingController = TextEditingController();

  static const Color blue = Color.fromRGBO(0, 73, 132, 1);
  static const Color yellow = Color.fromRGBO(255, 227, 24, 1);
late Future<List> fetchItems;

  @override
  void initState() {
    super.initState();
    fetchItems = fetchEmployes(context);
  }
  TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  String date_format(String date) {
    DateTime day = DateTime.parse(date);

    return "${day.day}/${day.month}/${day.year}    ${day.hour}:${day.minute}";
  }
void filterSearchResults(String query) {
  query = query.toUpperCase();
  if(query.isNotEmpty) {
    setState(() {
      
    list = duplicated.where((element) => element.EMP_ID.contains(query) || element.EMP_FULLNAME.contains(query)).toList();
    });
   
  
  } else {
    setState(() {
      list.clear();
      list.addAll(duplicated);
    });
  }
}
  Widget EmployeWidget(Employe user) {
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
                Icon(Icons.badge),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Matricule :",
                  style: textStyle,
                ),
                Text(
                  user.EMP_ID,
                  style: textStyle,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Text(
                  "Nom : ${user.EMP_FULLNAME}",
                  style: textStyle,
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Detail_Operation(
                            employe: user,
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

  Future<List> fetchEmployes(BuildContext context) async {
    if (list.length == 0) {
      list = await Employe.show_employes();

      duplicated.addAll(list);
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchItems,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title:
                  const Text('Naftal Scanner', style: TextStyle(color: yellow)),
              backgroundColor: blue,
            ),
            body: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Column(
                children: [
                 
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      controller: editingController,
                      decoration: InputDecoration(
                          labelText: "Recherche",
                          hintText: "Recherche",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                  ),
                  SizedBox(
                    
                    height: MediaQuery.of(context).size.height - 260,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return (EmployeWidget(list[index]));
                      },
                      physics: ScrollPhysics(),
                    ),
                  )
                ],
              ),
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
        }  else {
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
          )
          );
        }
      },
    );
  }
}
