import 'package:flutter/material.dart';
import 'package:flutter_app/AddEvent.dart';
import 'package:flutter_app/Details.dart';

class AdminEventPage extends StatefulWidget {
  //Class Constructor
  AdminEventPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _AdminEventPageState createState() => _AdminEventPageState();
}

class _AdminEventPageState extends State<AdminEventPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text('Add Volunteering Event',
                  style: TextStyle(fontSize: 25)),
              trailing: IconButton(
                  icon: Icon(Icons.add, size: 30),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddEventPage(title: 'Add Event')));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
