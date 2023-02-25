import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:birdbrain/previous_body_result.dart';
import 'package:birdbrain/nav_bar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

///Previous classifications lists all previous classifications
///the user chose to save.

class PreviousBodyClassifications extends StatefulWidget {
  PreviousBodyClassifications();

  @override
  PreviousBodyClassificationsState createState() => PreviousBodyClassificationsState();
}

class PreviousBodyClassificationsState extends State<PreviousBodyClassifications> {
  // late Future<List<Map<dynamic, dynamic>>> dodocIDscIDs; //stores all previous results that will be shown on feed
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference bodyPredictionsDB = FirebaseFirestore.instance.collection('bodyPredictionsDB');
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    // docIDs = getInfoFromDB();
  }

  Future<String> getDownloadURL(String path) async{
    var ref = storage.ref(path);
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

  Future<List<Map<String, dynamic>>> getInfoFromDB() async {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    var documentInfo = <Map<String, dynamic>>[];
    final querySnapshot = await bodyPredictionsDB
        .where('uid', isEqualTo: uid)
        .get();

    for(var doc in querySnapshot.docs){
      if (doc['showOnFeed']) {
        final head_dorsal_image = await getDownloadURL(doc['head_dorsal_image'].toString());
        final head_side_image = await getDownloadURL(doc['head_side_image'].toString());
        final head_ventral_image = await getDownloadURL(doc['head_ventral_image'].toString());
        final body_dorsal_image = await getDownloadURL(doc['body_dorsal_image'].toString());
        final body_ventral_image = await getDownloadURL(doc['body_ventral_image'].toString());
        final wing_dorsal_image = await getDownloadURL(doc['wing_dorsal_image'].toString());
        final wing_ventral_image = await getDownloadURL(doc['wing_ventral_image'].toString());
        documentInfo.add(
            {
              'head_dorsal_image' : head_dorsal_image,
              'head_side_image' : head_side_image,
              'head_ventral_image' : head_ventral_image,
              'body_dorsal_image' : body_dorsal_image,
              'body_ventral_image' : body_ventral_image,
              'wing_dorsal_image' : wing_dorsal_image,
              'wing_ventral_image' : wing_ventral_image,
              'email': doc['email'],
              'uid': doc['uid'],
              'documentID': doc.id,
              'date': doc['date']
            }
        );
      }
    }

    return documentInfo;
  }

  Widget buildImageCard(int index, List docs) =>
      Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          margin: EdgeInsets.all(8),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: GestureDetector(
                  onTap: () async {
                    print(docs[index]['head_dorsal_image']);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PreviousBodyResult(docs[index])
                        )
                    );
              },
                child: Image.network(
                    docs[index]['head_dorsal_image'],
                    fit: BoxFit.cover
                )
              )
          ),
        ),

      );



  @override
  Widget build(BuildContext context) {
    //getInfoFromDB();
    return Scaffold(
        backgroundColor: Colors.black,
        drawer: NavBar(),
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Machine Learning Results',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 0.8),
            )
        ),
        body: Center(
            child: FutureBuilder<List<Map<String,dynamic>>>(
                future: getInfoFromDB(),
                builder: (context, snapshot) {
                  print('snapshot - ${snapshot.data}');
                  if(!snapshot.hasData) return CircularProgressIndicator();
                  final docs = snapshot.data!;
                  return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index){
                        return buildImageCard(index, docs);
                        // if (snapshot.connectionState == ConnectionState.done) {
                        //   return Container(
                        //     width: 100,
                        //     height: 100,
                        //     //child: Text(docs[index]['email']),
                        //     child: Image.network(
                        //       docs[index]['head_dorsal_image'],
                        //       // width: 50,
                        //       // height: 50,
                        //       //'https://firebasestorage.googleapis.com/v0/b/duck-project-c2881.appspot.com/o/body_sequence_images%2Fhead_dorsal-39vj5Qwc5bOzEdX4zoeL9Xodi6C320227311557?alt=media&token=6a9d5bb8-b685-41a8-8332-c0458edafd24',
                        //       fit: BoxFit.cover,
                        //     ),
                        //     //child: Image.asset('assets/birdbrAIn logo.png'),
                        //   );
                          // return buildImageCard(
                          //     index, docIDs[index]['head_dorsal_image']);
                        // }
                        // else {
                        //   return CircularProgressIndicator();
                        // }
                      });
                }
            )
        )
    );
  }
}