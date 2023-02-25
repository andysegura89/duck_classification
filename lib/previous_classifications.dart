import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:birdbrain/previous_result.dart';
import 'package:birdbrain/nav_bar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

///Previous classifications lists all previous classifications
///the user chose to save.

class PreviousClassifications extends StatefulWidget {
  PreviousClassifications();

  @override
  PreviousClassificationsState createState() => PreviousClassificationsState();
}

class PreviousClassificationsState extends State<PreviousClassifications> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference predictionsDB = FirebaseFirestore.instance.collection('predictionsDB');
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  var docIDs = <Map>[]; //stores all previous results that will be shown on feed
  var img;

  Future<String> getDownloadURL(String path) async{
    var ref = storage.ref(path);
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }


    Widget buildImageCard(int index) =>
      Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          margin: EdgeInsets.all(8),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: GestureDetector(onTap: () async {
                print('!!!8888!!!888!*!!*!*!*!');
                print(docIDs[index]['image']);
                print(docIDs[index]['mlPredicted']);
                print(docIDs[index]['confidence']);
                print(docIDs[index]['userPredicted']);
                print(docIDs[index]['uid']);
                print(docIDs[index]['documentID']);
                print(docIDs[index]['date']);
                if (docIDs[index]['userPredicted'] == null){
                  docIDs[index]['userPredicted'] = "None";
                }
                                    Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      PreviousResult(
                                          docIDs[index]['image'],
                                          docIDs[index]['mlPredicted'],
                                          docIDs[index]['confidence'],
                                          docIDs[index]['userPredicted'],
                                          docIDs[index]['uid'],
                                          docIDs[index]['documentID'],
                                          docIDs[index]['date']
                                      )
                                    )
                                  );
                                },
                // child: Image(
                //     image: Image
                //         .memory(base64Decode(docIDs[index]['image']))
                //         .image,
                child: Image.network(
                    docIDs[index]['image'],
                    fit: BoxFit.cover
                ),
              )
          ),
        ),

      );

  // Future getInfoFromDB() async {
  //   final User? user = auth.currentUser;
  //   final uid = user?.uid;
  //   await predictionsDB
  //       .where('uid', isEqualTo: uid)
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) async {
  //       if (doc['showOnFeed']) {
  //         String mlp;
  //         if (doc['mlPredicted'] == '0') {
  //           mlp = 'Diazi (Mexican Duck)';
  //         }
  //         else {
  //           mlp = 'Platyrhynchos (Mallard Duck)';
  //         }
  //         String duckImg = await getDownloadURL(doc['image'].toString());
  //         docIDs.add(
  //             {
  //               'image': duckImg,
  //               'mlPredicted': mlp,
  //               'confidence': doc['confidence'],
  //               'userPredicted': doc['userPredicted'],
  //               'email': doc['email'],
  //               'uid': doc['uid'],
  //               'documentID': doc.id,
  //               'date': doc['date']
  //             }
  //         );
  //       }
  //
  //     });
  //   });
  // }

  Future getInfoFromDB() async {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    var documentInfo = <Map<String, dynamic>>[];
    final querySnapshot = await predictionsDB
        .where('uid', isEqualTo: uid)
        .get();

    for(var doc in querySnapshot.docs){
      if (doc['showOnFeed']) {
        final duckImage = await getDownloadURL(doc['image']);
        String mlp;
        if (doc['mlPredicted'] == '0') {
          mlp = 'Diazi (Mexican Duck)';
        }
        else {
          mlp = 'Platyrhynchos (Mallard Duck)';
        }
        print("!!!!!!!*!*!*!*!*");
        print(duckImage);
        docIDs.add(
            {
              'image': duckImage,
              'mlPredicted': mlp,
              'confidence': doc['confidence'],
              'userPredicted': doc['userPredicted'],
              'email': doc['email'],
              'uid': doc['uid'],
              'documentID': doc.id,
              'date': doc['date']
            }
        );
      }

    }
  }


  @override
  Widget build(BuildContext context) {
    //getInfoFromDB();
    return Scaffold(
        backgroundColor: Colors.black,
        drawer: NavBar(),
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Machine Learning Results',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 0.8),
            )
        ),
        body: Center(
            child: FutureBuilder(
                future: getInfoFromDB(),
                builder: (context, snapshot) {
                  return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5,
                                  ),
                      itemCount: docIDs.length,
                      itemBuilder: (context, index) => buildImageCard(index));
                 }
             )
         )
    );
  }
}
