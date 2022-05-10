import 'package:flutter/material.dart';
import 'package:naftal_perso/data/Bien_materiel.dart';
import 'package:naftal_perso/data/Localisation.dart';
import 'package:naftal_perso/main.dart';



class Update_Bien extends StatefulWidget {

    const Update_Bien({Key? key, required this.bien,required this.localisation}) : super(key: key);
    final Bien_materiel bien;
    final Localisation localisation;

  @override
  _Update_BienState createState() => _Update_BienState(bien: this.bien,localisation: this.localisation);
}

class _Update_BienState extends State<Update_Bien> {
     _Update_BienState({ required this.bien,required this.localisation}) ;

    final Bien_materiel bien;
    final Localisation localisation;



  TextEditingController nomController =  TextEditingController();

   static const Color  blue = Color.fromRGBO(0, 73, 132, 1);
   static const Color yellow   =  Color.fromRGBO(255, 227,24, 1);
  int _value= MODE_SCAN;

  
  @override
  void initState() {
    super.initState();
    setState(() {
      _value = bien.etat;
    });

 
  }



  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
            appBar: AppBar(
            automaticallyImplyLeading: false,
              title: const Text('Naftal Scanner',style: TextStyle(
              color: yellow
           
            )
            )
            ,backgroundColor:     blue,
            

            ),
            body: Builder(builder: (BuildContext context) {
              return SingleChildScrollView(
                child:  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit,
                                color: blue,),
                                Text(" Modification d'un bien matériel",
                                style: TextStyle(
                                  color: blue,
                                  fontSize:20.0
                                ),
                                )
                              ],
                            ),
                          
                          ),
                          Card(
                            
                            child:
                            
                             Column(
                               children: [
                                 Container(
                                   margin: EdgeInsets.all(10),
                                   width: double.infinity,
                                  child:
                                   Row(
                                     children: [
                                       Icon(Icons.qr_code_2),
                                       SizedBox(width: 10,),
                                       Text('Bien Matériel : ${bien.code_bar}',
                                       style: TextStyle(
                                         fontSize: 16
                                       ),
                                       ),
                                     ],
                                   ),
                            ),
                    Container(
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      children: [
                                          Icon(Icons.rate_review),
                                          SizedBox(
                                            width: 10,
                                          ),
                                         Text("Etat du bien matériel",
                                          style: TextStyle(
                                          fontSize: 16,
                                  ),)
                                      ],
                                  )
                                 ,
                                        
                                      ListTile(
                                        title: Text(
                                          'Bon',
                                        ),
                                        leading: Radio(
                                          value: 1,
                                          groupValue: _value,
                                          onChanged:  (val){

                                            setState(() {
                                              
                                              _value = val as int;
                                             

                                            });
                                              

                                          } ,
                                        ),
                                      ),
                                         ListTile(
                                        title: Text(
                                          'Hors serivce',
                                        ),
                                        leading: Radio(
                                          value: 2,
                                          groupValue: _value,
                                          onChanged:  (val){

                                            setState(() {
                                              
                                              _value = val as int;
                                             
                                            });
                                              

                                          } ,
                                        ),
                                      ),
                                         ListTile(
                                        title: Text(
                                          'A réformer',
                                        ),
                                        leading: Radio(
                                          value: 3,
                                          groupValue: _value,
                                          onChanged:  (val){

                                            setState(() {
                                              
                                              _value = val as int;
                                           

                                            });
                                              

                                          } ,
                                        ),
                                      ),
                                ],

                            ),

                          ),
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
                                  icon: Icon(Icons.check , color:Colors.white),
                                  label: Text("Valider"),
                                  onPressed: ()async{

                                   

                                      bien.etat = _value;

                                      setState(() {
                                        MODE_SCAN = bien.etat;
                                      });

                                      bool stored =  await bien.Store_Bien_Soft();

                                      if(stored == true){

                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(builder: (context) =>  Detail_Bien(bien_materiel: bien,localisation:localisation ,),
                                              //     ),
                                              //   );
                                      }else{

                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content:
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(Icons.info,color: Colors.white,size: 25),
                                                Text("une erreur est survenue veuillez réessayer",
                                            style: TextStyle(fontSize: 17.0),
                                            ),
                                              ],
                                            ),
                                            backgroundColor: Colors.red,
                                          )
                                      );
                                      }


                                   
                                    

                                  },
                                )
                              ],
                            ),
                          )
                               ],
                             ),
                          ),
                           
                         
                         
                       
                         
                      
                        ]),
                )
                 
                  
                      );
            }));
  }
}
// ignore_for_file: prefer_const_constructors