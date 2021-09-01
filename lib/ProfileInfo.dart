import 'package:flutter/material.dart';
import 'Login.dart';
import 'User.dart';
import 'cmdb.dart';

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
  CMDB database = CMDB();

  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController newPConfirm = TextEditingController();

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

  List<Widget> changePasswordPopup() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      ),
    ];
  }

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
        child: ListView(
          children: <Widget>[
            Center(child: Text(titleCase(user.info!["name"]), style: TextStyle(fontSize: 40, decoration: TextDecoration.underline))),
            SizedBox(
              height: 50
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Username: " + user.info!["username"])),
            Align(alignment: Alignment.centerLeft, child: Text("Phone Number: " + user.info!["phoneNumber"].toString())),
            Align(alignment: Alignment.centerLeft, child: Text("Role: " + titleCase(user.info!["role"]))),
            SizedBox(height: 30),
            Text("Change Password"),
            TextField(
              obscureText: false,
              controller: oldPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter old password',
                labelStyle: new TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              obscureText: false,
              controller: newPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter new password',
                labelStyle: new TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              obscureText: false,
              controller: newPConfirm,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter new password again',
                labelStyle: new TextStyle(color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [ElevatedButton(
                  child: Text("Cancel"),
                  onPressed: (){
                    newPassword.text = "";
                    oldPassword.text = "";
                    newPConfirm.text = "";
                  },
                ),
                  ElevatedButton(
                    child: Text("Change Password"),
                    onPressed: (){
                      print(user.info);
                      print(oldPassword.text == user.info!['password'] );
                      print(newPConfirm.text == newPassword.text);
                      if (oldPassword.text == user.info!['password'] && newPConfirm.text == newPassword.text){
                        user.info!['password'] = newPassword.text;
                      database.get<Map<String, dynamic>>("Users/" + user.info!['username']).then((value) {
                          value!['password'] = newPassword.text;
                          database.update("Users/" + user.info!['username'] + "/",value ).then((value) {
                            if (value == true){
                              _showDialog("Password successfully changed", 'Success!', changePasswordPopup());
                              newPassword.text = "";
                              oldPassword.text = "";
                              newPConfirm.text = "";
                            }
                          });
                        });
                      }
                      else{
                        _showDialog("Incorrect, try again", 'Password Change', changePasswordPopup());

                      }
                    },
                  )]

              ),
            ),
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
