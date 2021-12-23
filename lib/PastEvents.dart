import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'User.dart';
import 'cmdb.dart';

class PastEventsPage extends StatefulWidget {
  //Class Constructor
  PastEventsPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _PastEventsPageState createState() => _PastEventsPageState();
}

class _PastEventsPageState extends State<PastEventsPage> {
  User user = User();
  CMDB database = CMDB();

  void _showDialog(String message, String title, List<Widget> actions) {
    showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: actions,
          );
        });
  }

  String titleCase(String s) {
    return s
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Page Under', style: TextStyle(fontSize: 35, color: Colors.black54, fontStyle: FontStyle.italic)),
              Text('Construction', style: TextStyle(fontSize: 35, color: Colors.black54, fontStyle: FontStyle.italic)),
              IconButton(icon: Icon(Icons.construction_rounded), iconSize: 40, color: Colors.black54, onPressed: () {  },)
            ],
          ),
        ),
      ),
    );
  }
}
