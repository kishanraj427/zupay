import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:zupay/movie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController name = TextEditingController(),
      director = TextEditingController();
  File? image;
  late DatabaseReference rootRef;
  List<Movie> movieItems = [];

  @override
  void initState() {
    rootRef = FirebaseDatabase.instance
        .reference()
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('MovieList');
    loadMovies();
    super.initState();
  }

  loadMovies() async {
    rootRef.onChildAdded.listen((event) {
      var data = event.snapshot.value;
      Movie movie =
          Movie(data['name'], data['director'], data['imageUrl'], data['key']);
      setState(() {
        movieItems.add(movie);
      });
      debugPrint("name : " + movie.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movies"),
        leading: Container(),
        leadingWidth: 0,
      ),
      body: ListView.builder(
        itemCount: movieItems.length,
        itemBuilder: (context, index) => movieItem(movieItems[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dialog(context);
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget movieItem(Movie movie) {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black26,
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(2.5, 2.2))
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              movie.imageUrl,
              height: 160,
              width: 130,
              fit: BoxFit.fill,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.name,
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: 7,
                    ),
                    Text('By ' + movie.director,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                          onPressed: () {
                            rootRef.child(movie.key).remove().whenComplete(() {
                              setState(() {
                                movieItems.remove(movie);
                              });
                              Fluttertoast.showToast(
                                  msg: movie.name + ' is deleted', backgroundColor: Colors.red);
                            });
                          },
                          icon: Icon(Icons.delete, color: Colors.blue)),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  dialog(context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                children: [
                  Image.asset(
                    'assets/icon.png',
                    height: 85,
                    width: 250,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                      onTap: () async {
                        // ignore: invalid_use_of_visible_for_testing_member
                        PickedFile? im = await ImagePicker.platform
                            .pickImage(source: ImageSource.gallery);
                        if (im != null)
                          setState(() {
                            image = File(im.path);
                            Navigator.pop(context);
                          });
                      },
                      child: image == null
                          ? Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 100,
                            )
                          : Image.file(
                              image!,
                              width: 300,
                              height: 150,
                            )),

                  SizedBox(
                    height: 25,
                  ),
                  TextField(
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        labelText: 'Movie Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: director,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Movie Director Name',
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // ignore: deprecated_member_use
                  FlatButton(
                    onPressed: () async {
                      if (image != null &&
                          name.text != '' &&
                          director.text != '') {
                        String key = rootRef.push().key;
                        storage.TaskSnapshot upload = await storage
                            .FirebaseStorage.instance
                            .ref(key)
                            .putFile(image!);
                        if (upload.state == storage.TaskState.success) {
                          rootRef.child(key).set({
                            'key': key,
                            'name': name.text,
                            'director': director.text,
                            'imageUrl': await upload.ref.getDownloadURL()
                          }).whenComplete(() {
                            image = null;
                            name.clear();
                            director.clear();
                            Navigator.pop(context);
                            Fluttertoast.showToast(msg: 'Upload Successful');
                          });
                        }
                      }
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(fontSize: 20),
                    ),
                    padding: const EdgeInsets.all(10),
                  )
                ],
              ),
            ));
  }
}
