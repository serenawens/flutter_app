import 'package:flutter/material.dart';

class InvitationPage extends StatefulWidget {
  //Class Constructor
  InvitationPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _InvitationPageState createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {

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
            Text(
              'My Demo App 1 - Screen No.1',
            ),
            Text(
              'You have clicked the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}