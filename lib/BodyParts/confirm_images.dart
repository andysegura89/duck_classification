

import 'package:birdbrain/BodyParts/body_result.dart';
import 'package:flutter/material.dart';
import 'package:birdbrain/home.dart';
import 'package:birdbrain/nav_bar.dart';


class ConfirmImages extends StatefulWidget {
  Map _results;
  ConfirmImages(this._results);

  @override
  ConfirmImagesState createState() => ConfirmImagesState(_results);
}

class ConfirmImagesState extends State<ConfirmImages> {
  Map _results;
  var img;
  var body_parts = ['head_dorsal', 'head_side', 'head_ventral',
  'body_dorsal', 'body_ventral', 'wing_dorsal', 'wing_ventral'];
  Map translations = {'head_dorsal': 'back side of the head',
  'head_side': 'side of the head', 'head_ventral':'stomach side of the head',
  'body_dorsal':'back side of the body', 'body_ventral':
    'stomach side of the body', 'wing_dorsal': 'back side of the body',
  'wing_ventral': 'stomach side of the wing'};

  ConfirmImagesState(this._results);

  Widget buildImageCard(int index) =>
      Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children:[ index < 7 ?
              Text(translations[body_parts[index]],
              style: const TextStyle(
                fontSize: 10,
                )
              ) : const SizedBox(height:10),
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: GestureDetector(onTap: () async {

                },
                  child: index < 7 ? Image(
                  image: Image.file(_results[body_parts[index]][0]).image,
                    width: 125,
                    height: 125,
                    fit: BoxFit.cover,
                  )
                      :  Column(
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector( // take a photo button
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BodyResultsScreen(_results))
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 200,
                          alignment: Alignment.center,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector( // take a photo button
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Home())
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 200,
                          alignment: Alignment.center,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Discard',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),

                      ],
                  )
                )
            ),

            ]),
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
              'Sequence results',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 0.8),
            )
        ),
        body: Center(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemCount: 8, //# of iterations
                itemBuilder: (context, index) => buildImageCard(index))


        )
    );

  }
}