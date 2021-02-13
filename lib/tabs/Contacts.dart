import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/UserCredential.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  String _userId;
  String _userEmail;

  Future<List<UserCredential>> _getContacts() async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot = await db.collection("users").getDocuments();

    List<UserCredential> listUser = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var data = item.data;
      if (data["email"] == _userEmail) continue;

      UserCredential user = UserCredential();
      user.idUser         = item.documentID;
      user.email          = data["email"];
      user.name           = data["name"];
      user.urlImage       = data["urlImage"];

      listUser.add(user);
    }

    return listUser;
  }

  _getUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _userId = loggedUser.uid;
    _userEmail = loggedUser.email;
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserCredential>>(
      future: _getContacts(),
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Loading contacts"),
                  CircularProgressIndicator()
                ],
              ),
            // ignore: missing_return
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  List<UserCredential> listItems = snapshot.data;
                  UserCredential user = listItems[index];
                  return ListTile(
                    onTap: (){
                      Navigator.pushNamed(
                          context,
                          "/messages",
                          arguments: user
                      );
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: user.urlImage != null
                            ? NetworkImage(user.urlImage)
                            : null),
                    title: Text(
                      user.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                });
            break;
        }
      },
    );
  }
}
