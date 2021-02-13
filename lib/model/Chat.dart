import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String _idSender;
  String _idDestiny;
  String _name;
  String _message;
  String _pathPhoto;
  String _typeMessage;

  Chat();

  save() async {
    Firestore db = Firestore.instance;
    await db
        .collection("chats")
        .document(this._idSender)
        .collection("last_chat")
        .document(this.idDestiny)
        .setData(this.toMap());
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idSender"   : this.idSender,
      "idDestiny"  : this.idDestiny,
      "name"       : this.name,
      "message"    : this.message,
      "pathPhoto"  : this.pathPhoto,
      "typeMessage": this.typeMessage,
    };

    return map;
  }

  String get name => _name;

  String get idSender => _idSender;

  set idSender(String value) {
    _idSender = value;
  }

  set name(String value) {
    _name = value;
  }

  String get message => _message;

  String get pathPhoto => _pathPhoto;

  set pathPhoto(String value) {
    _pathPhoto = value;
  }

  set message(String value) {
    _message = value;
  }

  String get idDestiny => _idDestiny;

  String get typeMessage => _typeMessage;

  set typeMessage(String value) {
    _typeMessage = value;
  }

  set idDestiny(String value) {
    _idDestiny = value;
  }
}
