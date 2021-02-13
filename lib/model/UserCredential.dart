
class UserCredential {

  String _idUser;
  String _name;
  String _email;
  String _password;
  String _urlImage;

  String get urlImage => _urlImage;

  set urlImage(String value) {
    _urlImage = value;
  }

  UserCredential();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "name"  : this.name,
      "email" : this.email
    };

    return map;
  }


  String get idUser => _idUser;

  set idUser(String value) {
    _idUser = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  } // ignore: unnecessary_getters_setters
  String get email => _email;

  // ignore: unnecessary_getters_setters
  set email(String value) {
    _email = value;
  }

  // ignore: unnecessary_getters_setters
  String get name => _name;

  // ignore: unnecessary_getters_setters
  set name(String value) {
    _name = value;
  }
}