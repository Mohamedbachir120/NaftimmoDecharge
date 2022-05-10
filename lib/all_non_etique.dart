
import 'package:flutter/material.dart';
import 'package:naftal_perso/all_objects.dart';
import 'package:naftal_perso/data/Employe.dart';
import 'package:naftal_perso/data/Non_Etiquete.dart';
import 'package:naftal_perso/detail_NonEtiqu.dart';
import 'package:naftal_perso/operations.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'data/User.dart';

void main() {
  runApp(const All_Non_Etiqu());
}

class All_Non_Etiqu extends StatelessWidget {
  const All_Non_Etiqu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'All_Non_Etiqu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const All_Non_EtiquPage(title: 'NaftalAppScann'),
    );
  }
}

class All_Non_EtiquPage extends StatefulWidget {
  const All_Non_EtiquPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<All_Non_EtiquPage> createState() => _All_Non_EtiquPageState();
}

class _All_Non_EtiquPageState extends State<All_Non_EtiquPage> {
  late List<Non_Etiquete> list;
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
  String date_format(String date) {
    DateTime day = DateTime.parse(date);

    return "${day.day}/${day.month}/${day.year}    ${day.hour}:${day.minute}";
  }

  Widget NonEtiquWidget(Non_Etiquete non_etiqu, BuildContext context) {
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
                Icon(Icons.qr_code_2),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Numéro de série :",
                  style: textStyle,
                ),
                Expanded(
                  child: Text(
                    non_etiqu.num_serie,
                    style: textStyle,
                  ),
                )
              ],
            ),
          ),
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.ballot_rounded),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Marque :",
                  style: textStyle,
                ),
                Expanded(
                  child: Text(
                    non_etiqu.marque,
                    style: textStyle,
                  ),
                )
              ],
            ),
          ),
           
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.badge),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Nature :",
                  style: textStyle,
                ),
                Expanded(
                  child: Text(
                    non_etiqu.nature,
                    style: textStyle,
                  ),
                )
              ],
            ),
          ),
         
            Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: yellow
                  ),
                  onPressed: ()async{
                  Employe employe = await Employe.getBymatricule(non_etiqu.matricule);
                

                  Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> DetailNonEtiqu(
                    non_etiqu: non_etiqu, employe: employe))
                  );

                },
                 icon: Icon(Icons.book,color: blue,), 
                 label: Text("Détail",style: TextStyle(color: blue),))
              ],
            ),
          ),
         
         
         
      
        ],
      ),
    );
  }

  Future<List> fetchNonEtiqu(BuildContext context) async {
    user = await User.auth();
    list = await Non_Etiquete.history();
    list = list.reversed.toList();
    

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchNonEtiqu(context),
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
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Color.fromARGB(255, 244, 246, 247)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.format_list_numbered_rounded, size: 30, color: blue),
                              Text(
                                "Liste des articles non etiquetés",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                         ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 225,
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return (NonEtiquWidget(list[index], context));
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
                      MaterialPageRoute(builder: (context) => All_Non_Etiqu()),
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
        } else if(snapshot.connectionState == ConnectionState.done && list.length == 0){
             return Scaffold(
              body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Center(
                
                    child: Icon(Icons.format_list_numbered_rounded,size: 35,)),
                Center(
                
                    child: Text("La liste des article est vide",
                    style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold ) ,))
              ],
            ),
          ),   bottomNavigationBar: SalomonBottomBar(
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
                      MaterialPageRoute(builder: (context) => All_Non_Etiqu()),
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

        }else{
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
