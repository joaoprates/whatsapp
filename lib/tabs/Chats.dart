import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Chat.dart';
import 'package:whatsapp/model/UserCredential.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {

  List<Chat> _listChats = List();
  // ignore: close_sinks
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
  String _userId;

  @override
  void initState() {

    _getUserData();
    Chat chat = Chat();
    chat.name = "Ana Clara";
    chat.message = "Olá tudo bem?";
    chat.pathPhoto = "https://firebasestorage.googleapis.com/v0/b/whatsapp-36cd8.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=97a6dbed-2ede-4d14-909f-9fe95df60e30";

    _listChats.add(chat);
  }

  Stream<QuerySnapshot> _addChatListener(){

    final stream = db.collection("chats")
        .document( _userId )
        .collection("last_chat")
        .snapshots();

    stream.listen((data){
      _controller.add( data );
    });

  }

  _getUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _userId = loggedUser.uid;

    _addChatListener();

  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        // ignore: missing_return
        builder: (context, snapshot){
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("Loading chats"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text("Error to load data!");
              }else {
                QuerySnapshot querySnapshot = snapshot.data;

                if (querySnapshot.documents.length == 0) {
                  return Center(
                    child: Text(
                      "You do not have any chat yet :( ",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                }
                ListView.builder(
                    itemCount: _listChats.length,
                    itemBuilder: (context, index) {
                      List<DocumentSnapshot> chat = querySnapshot.documents.toList();
                      DocumentSnapshot item = chat[index];

                      String urlImage   = item["pathPhoto"];
                      String type       = item["typeMessage"];
                      String message    = item["message"];
                      String name       = item["name"];
                      String idDestiny  = item["idDestiny"];

                      UserCredential user = UserCredential();
                      user.name           = name;
                      user.urlImage       = urlImage;
                      user.idUser         = idDestiny;


                      return ListTile(
                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: urlImage !=null
                              ? NetworkImage( urlImage )
                              : null,
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                        subtitle: Text(
                            type == "text" ? message : "Image...",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14
                            )
                        ),
                      );
                    }
                );
              }
          }
        },
    );

  }
}