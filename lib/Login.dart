import 'package:flutter/material.dart';
import 'package:whatsapp/Register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/model/UserCredential.dart';
import 'Home.dart';



class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  String _messageError = "";

  _validateFields(){

    //Get data from fields
    String email = _controllerEmail.text;
    String password = _controllerPassword.text;

    if( email.isNotEmpty && email.contains("@") ){

      if( password.isNotEmpty ){

        setState(() {
          _messageError = "";
        });

        UserCredential user = UserCredential();
        user.email = email;
        user.password = password;

        _loginUser( user );

      }else{
        setState(() {
          _messageError = "Fill the gaps!";
        });
      }

    }else{
      setState(() {
        _messageError = "Fill e-mail with @";
      });
    }
  }

  _loginUser( UserCredential user ){

    FirebaseAuth auth = FirebaseAuth.instance;

    auth.signInWithEmailAndPassword(
        email: user.email,
        password: user.password
    ).then((firebaseUser){

      Navigator.pushReplacementNamed(context, "/home");

    }).catchError((error){

      setState(() {
        _messageError = "Error to authenticate, please check the information and try again!";
      });

    });

  }

  Future _checkLoggedUser() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();

    FirebaseUser loggedUser = await auth.currentUser();

    if( loggedUser != null ){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Home()
          )
      );
    }
  }

  @override
  void initState() {
    _checkLoggedUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075E54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                TextField(
                  controller: _controllerPassword,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Sign in",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)
                      ),
                      onPressed: () {
                        _validateFields();
                      }),
                ),
                Center(
                  child: GestureDetector(
                    child: Text(
                        "Do not have account? Sign up!",
                        style: TextStyle(
                            color: Colors.white
                        )
                    ),
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Register() )
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _messageError,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
