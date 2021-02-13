import 'package:flutter/material.dart';
import 'package:whatsapp/Messages.dart';
import 'package:whatsapp/Register.dart';
import 'package:whatsapp/Settings.dart';
import 'Home.dart';
import 'Login.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;
    switch( settings.name ){
      case "/" :
        return MaterialPageRoute(
          builder: (_) => Login()
        );
      case "/login" :
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/register" :
        return MaterialPageRoute(
            builder: (_) => Register()
        );
      case "/home" :
        return MaterialPageRoute(
            builder: (_) => Home()
        );
      case "/settings" :
      return MaterialPageRoute(
          builder: (_) => Settings()
      );
      case "/messages" :
        return MaterialPageRoute(
            builder: (_) => Messages( args )
        );
      default:
        _errorRoute();
    }

  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(title: Text("Tab not found!"),),
          body: Center(
            child: Text("Tab not found!"),
          ),
        );
      }
    );
  }

}