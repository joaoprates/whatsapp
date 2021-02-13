import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'Login.dart';

final ThemeData iosTheme = ThemeData(
    primaryColor: Colors.grey[200],
    accentColor: Color(0xff25D366)
);

final ThemeData defaultTheme = ThemeData(
  primaryColor: Color(0xff075E54),
  accentColor: Color(0xff25D366)
);

void main(){
  runApp(MaterialApp(
    home: Login(),
    theme: Platform.isIOS ? iosTheme : defaultTheme,
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
  ));

}

