import 'package:flutter/material.dart';
import 'Login.dart';
import 'User.dart';

class ProfilePage extends StatefulWidget {
  //Class Constructor
  ProfilePage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User user = User();

  String titleCase(String s){
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(titleCase(user.info!["name"]), style: TextStyle(fontSize: 40)),
            Text(user.info!["username"]),
            Text(user.info!["phoneNumber"].toString()),
            Text(user.info!["role"]),
            SizedBox(height: 30),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                user.info = {};
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(title: "Login")),
                );
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
