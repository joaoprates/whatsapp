
class Message {

  String _idUser;
  String _message;
  String _urlImage;

  //Define o tipo da mensagem, que pode ser "texto" ou "imagem"
  String _type;
  String _date;


  Message();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUser": this.idUser,
      "message": this.message,
      "urlImage": this.urlImage,
      "type": this.type,
      "date": this.date,
    };

    return map;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get urlImage => _urlImage;

  set urlImage(String value) {
    _urlImage = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  String get idUser => _idUser;

  set idUser(String value) {
    _idUser = value;
  }
}