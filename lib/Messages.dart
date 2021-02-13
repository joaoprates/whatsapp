import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/model/Chat.dart';
import 'package:whatsapp/model/Message.dart';
import 'package:whatsapp/model/UserCredential.dart';

class Messages extends StatefulWidget {
  UserCredential contact;

  Messages(this.contact);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  TextEditingController _controllerMessage = TextEditingController();
  File _image;
  bool _uploadingImage = false;
  String _userId;
  String _idDestiny;
  Firestore db = Firestore.instance;

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  _sendMessage() {
    String textMessage = _controllerMessage.text;
    if (textMessage.isNotEmpty) {
      Message messages = Message();
      messages.idUser = _userId;
      messages.message = textMessage;
      messages.urlImage = "";
      messages.type = "text";

      _saveMessage(_userId, _idDestiny, messages);
      _saveMessage(_idDestiny, _userId, messages);

      _saveChat( messages );
    }
  }

  _saveMessage(String idSender, String _idDestiny, Message msg) async {
    await db
        .collection("messages")
        .document(idSender)
        .collection(_idDestiny)
        .add(msg.toMap());

    //Limpa texto
    _controllerMessage.clear();
  }

  _saveChat(Message msg){

    //Salvar conversa remetente
    Chat cSender = Chat();
    cSender.idSender = _userId;
    cSender.idDestiny = _idDestiny;
    cSender.message = msg.message;
    cSender.name = widget.contact.name;
    cSender.pathPhoto = widget.contact.urlImage;
    cSender.typeMessage = msg.type;
    cSender.save();

    //Salvar conversa destinatario
    Chat cDestiny = Chat();
    cDestiny.idSender = _idDestiny;
    cDestiny.idDestiny = _userId;
    cDestiny.message = msg.message;
    cDestiny.name = widget.contact.name;
    cDestiny.pathPhoto = widget.contact.urlImage;
    cDestiny.typeMessage = msg.type;
    cDestiny.save();
  }

  _sendImage() async {
    File selectedImage;
    selectedImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    _uploadingImage = true;
    String nameImage = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference sourcePath = storage.ref();
    StorageReference file =
        sourcePath.child("messages").child(_userId).child(nameImage + ".jpg");

    //Upload da imagem
    StorageUploadTask task = file.putFile(selectedImage);

    //Controlar progresso do upload
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

    //Recuperar url da imagem
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _getUrlImage(snapshot);
    });
  }

  Future _getUrlImage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    Message messages = Message();
    messages.idUser = _userId;
    messages.message = "";
    messages.urlImage = url;
    messages.type = "image";

    _saveMessage(_userId, _idDestiny, messages);
    _saveMessage(_idDestiny, _userId, messages);
  }

  _getUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _userId = loggedUser.uid;
    _idDestiny = widget.contact.idUser;

    _addChatListener();
  }

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  Stream<QuerySnapshot> _addChatListener(){

    final stream = db.collection("messages")
        .document(_userId)
        .collection(_idDestiny)
        .snapshots();

        stream.listen((data){
        _controller.add( data );
        Timer(Duration(seconds: 1), (){
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          } );
    });

  }


  @override
  Widget build(BuildContext context) {
    var boxMessage = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMessage,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Type here...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)
                    ),
                    prefixIcon:
                    _uploadingImage
                        ? CircularProgressIndicator()
                        : IconButton(icon: Icon(Icons.camera_alt),
                        onPressed: _sendImage)
                ),
              ),
            ),
          ),
          Platform.isIOS
              ? CupertinoButton(
            child: Text("send"),
            onPressed: _sendMessage,
          )
              : FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _sendMessage,
          )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: _controller.stream,
      // ignore: missing_return
      builder: (context, snapshot) {
        // ignore: missing_return
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Loading messages"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return Expanded(
                child: Text("Error to load data!"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, index) {
                      //recupera mensagem
                      List<DocumentSnapshot> messages =
                          querySnapshot.documents.toList();
                      DocumentSnapshot item = messages[index];

                      double widthContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alinhamentos
                      Alignment alignment = Alignment.centerRight;
                      Color color = Color(0xffd2ffa5);
                      if (_userId != item["userId"]) {
                        alignment = Alignment.centerLeft;
                        color = Colors.white;
                      }

                      return Align(
                        alignment: alignment,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: widthContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))
                            ),
                            child: item["type"] == "text"
                                ? Text(
                                    item["message"],
                                    style: TextStyle(fontSize: 18),
                                  )
                                : Image.network(item["urlImage"]),
                          ),
                        ),
                      );
                    }),
              );
            }

            break;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contact.urlImage != null
                    ? NetworkImage(widget.contact.urlImage)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.contact.name),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("image/bg.png"),
                fit: BoxFit.cover)
        ),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              stream,
              boxMessage,
              //listview
            ],
          ),
        )),
      ),
    );
  }
}
