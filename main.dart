import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(ImagePickerApp());

class ImagePickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VTR',
      home: ImagePickerWidget(),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  ImagePickerWidget({Key key}) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State {
  File record;
  @override
  void initState() {
    super.initState();
  }

  Future Open_camera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image != null) {
    _uploadImageToFirebase(image);
    setState(() {
      record = image;
    });
  }
  }

  Future Open_gallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image != null) {
    _uploadImageToFirebase(image);
    setState(() {
      record = image;
    });
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("VTR"),
          backgroundColor: Colors.black45,
        ),
        body: Center(
          child: Container(
            child: Column(
              children: [
                Container(
                  color: Colors.black87,
                  height: 300.0,
                  width: 900.0,
                  child: record == null
                      ? Center(
                        child: Padding(
                          padding: new EdgeInsets.all(20.0),
                          child:Text(
                        "Are You Ready for Virtual Trailer Room??..",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 25.0),
                        )))
                      : Image.file(record),
                ),
                FlatButton(
                  color: Colors.deepOrangeAccent,
                  child: Text(
                    "Open Camera",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Open_camera();
                  },
                ),
                FlatButton(
                  color: Colors.limeAccent,
                  child: Text(
                    "Open Gallery",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Open_gallery();
                  },
                )
              ],
            ),
          ),
        ));
  }
  
//Backend Part where we store data to firebase

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      // Make random image name.
      int randomNumber = Random().nextInt(100000);
      String imageLocation = 'images/image$randomNumber.jpg';

      // Upload image to firebase.
      final StorageReference storageReference = FirebaseStorage().ref().child(imageLocation);
      final StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;
      _addPathToDatabase(imageLocation);
    }catch(e){
      print(e.message);
    }
  }

  Future<void> _addPathToDatabase(String text) async {
    try {
      // Get image URL from firebase
      final ref = FirebaseStorage().ref().child(text);
      var imageString = await ref.getDownloadURL();

      // Add location and url to database
      await Firestore.instance.collection('storage').document().setData({'url':imageString , 'location':text});
    }catch(e){
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          }
      );
    }
  }

}

//modelling the data base

class Record {
  final String location;
  final String url;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['location'] != null),
        assert(map['url'] != null),
        location = map['location'],
        url = map['url'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$location:$url>";
}
