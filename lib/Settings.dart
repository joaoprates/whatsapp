import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _controllerName = TextEditingController();
  File _image;
  String _userId;
  bool _uploadingImage = false;
  String _urlImage;

  Future _getImage(String sourceImage) async {
    File selectedImage;
    switch (sourceImage) {
      case "camera":
        selectedImage =
            await ImagePicker.pickImage(source: ImageSource.camera) as File;
        break;
      case "gallery":
        selectedImage =
            await ImagePicker.pickImage(source: ImageSource.gallery) as File;
        break;
    }

    setState(() {
      _image = selectedImage;
      if (_image != null) {
        _uploadingImage = true;
        _uploadImage();
      }
    });
  }

  Future _uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference sourcePath = storage.ref();
    StorageReference file = sourcePath.child("profile").child(_userId + ".jpg");

    //Image upload
    StorageUploadTask task = file.putFile(_image);

    //Progress upload
    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _uploadingImage = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _uploadingImage = false;
        });
      }
    });

    //Get URL image
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _getUrlImage(snapshot);
    });
  }

  Future _getUrlImage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _updateUrlImage(url);
    setState(() {
      _urlImage = url;
    });
  }

  _updateName() {
    String name = _controllerName.text;
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"name": name};

    db.collection("users").document(_userId).updateData(updateData);
  }

  _updateUrlImage(String url) {
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"urlImage": url};

    db.collection("users").document(_userId).updateData(updateData);
  }

  _getUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _userId = loggedUser.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_userId).get();

    Map<String, dynamic> data = snapshot.data;
    _controllerName.text = data["name"];

    if (data["urlImage"] != null) {
      _urlImage = data["urlImage"];
    }
    _getImage(_urlImage);
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  child: _uploadingImage
                      ? CircularProgressIndicator()
                      : Container(),
                ),
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage: _urlImage != null
                        ? NetworkImage(_urlImage) : null
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text("Camera"),
                      onPressed: () {
                        _getImage("camera");
                      },
                    ),
                    FlatButton(
                      child: Text("Gallery"),
                      onPressed: () {
                        _getImage("gallery");
                      },
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerName,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Name",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _updateName();
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/home", (route) => false);
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
