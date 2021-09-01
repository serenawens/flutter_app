// import 'package:flutter/material.dart';
// import 'Login.dart';
// import 'cmdb.dart';
// import 'package:splashscreen/splashscreen.dart';
//
// void main() {
//   // print("Hello World");
//   // CMDB database = new CMDB();
//   // database.initialize("serena-test");
//   //Task 1: Sign Up a user (Create a new user)
//   // var user1 = {
//   //   "username": 'serenaw',
//   //   'password': '321abc',
//   //   'grade': 12,
//   //   'email': 'serenw@gmail.com',
//   //   'name': "serena wen",
//   //   'role': 'admin',
//   // };
//   //
//   // var eventOwned1 = {
//   //   '001': "leaf raking", '002': 'food sorting'
//   // };
//   // database.update("/Users/" + user1['username'].toString() + "/events owned/", eventOwned1);
//
//   // var user2 = {
//   //   "username": 'johndoe',
//   //   'password': 'abc123',
//   //   'grade': 11,
//   //   'email': 'jd@gmail.com',
//   //   'name': "john doe",
//   //   'role': 'member',
//   //   'events signed up': {
//   //     002: {"event name": 'food sorting', 'status': 'confirmed'},
//   //     001: {"event name" : "leaf raking", 'status' : 'confirmed'}
//   //   }
//   // };
//   // database.update("/Users/" + user2['username'].toString(), user2);
//
//   runApp(AnApp());
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/Login.dart';
import 'package:flutter_app/Route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';

import 'Home.dart';
import 'User.dart';
import 'cmdb.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
    theme: ThemeData(
      // This is the theme of your application.
      //
      // Try running your application with "flutter run". You'll see the
      // application has a blue toolbar. Then, without quitting the app, try
      // changing the primarySwatch below to Colors.green and then invoke
      // "hot reload" (press "r" in the console where you ran "flutter run",
      // or simply save your changes to "hot reload" in a Flutter IDE).
      // Notice that the counter didn't reset back to zero; the application
      // is not restarted.
      primarySwatch: Colors.orange,

      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CMDB database = CMDB();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    database.initialize("serena-test");
  }

  User user = User();

  Future<Widget> loadFromFuture() async {
    // <fetch data from server. ex. login>
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("username")) {
      String? username = prefs.getString('username');
      database
          .get<Map<String, dynamic>>('Users/' + username! + "/")
          .then((value) {
        user.info = value;
        return Future.value(new RouteScreen());

      });
    }
    else {
      return Future.value(
          Future.delayed(const Duration(milliseconds: 4000), () {
            return (new LoginPage(title: "Login"));
          }));
    }
    throw ("");
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 4,
        // navigateAfterFuture: loadFromFuture(),
        navigateAfterSeconds: LoginPage(title:"Login"),
        title: new Text(
          'Welcome In SplashScreen',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: new Image.network('https://i.imgur.com/TyCSG9A.png'),
        //change network to assets
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("Flutter Egypt"),
        loaderColor: Colors.red);
  }
}
