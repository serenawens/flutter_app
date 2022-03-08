import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChangePassword.dart';
import 'User.dart';
import 'cmdb.dart';

class EditProfilePage extends StatefulWidget {
  //Class Constructor
  EditProfilePage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  User user = User();
  CMDB database = CMDB();

  TextEditingController oldPassword = TextEditingController();

  String formatPhoneNumber(String number) {
    String temp = number.trim();
    String prettify = '';

    if (temp.startsWith("+1") || temp.startsWith("*1")) {
      temp = temp.trim().substring(2);
    }

    for (int i = 0; i < temp.length; i++) {
      if (!(temp[i] == '+' ||
          temp[i] == '*'||
          temp[i] == ' ' ||
          temp[i] == '-' ||
          temp[i] == '(' ||
          temp[i] == ')')) {
        prettify += temp[i];
      }
    }
    print(prettify);

    return "(" +
        prettify.substring(0, 3) +
        ")" +
        " " +
        prettify.substring(3, 6) +
        "-" +
        prettify.substring(6);
  }

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

  Future<void> removeUserPrefKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("username");
  }

  List<Widget> changePasswordPopup() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
        ],
      ),
    ];
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
          padding: const EdgeInsets.only(top: 8.0, left: 20),
          child: Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Username:",
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 7),
                    Text("Name:",
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 7),
                    Text("Grade:",
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 7),
                    user.info!["role"].toString() == "admin"
                        ? Row(children: [
                      Text("Role:",
                          style: TextStyle(fontSize: 18)),

                    ])
                        : SizedBox(),
                    SizedBox(height: 7),
                    Text("Phone Number:", style: TextStyle(fontSize: 18)),
                  ]
                ),
                Column(
                  children:[
                    Text(user.info!["username"],
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 17)),
                    SizedBox(height: 7),
                    Text(titleCase(user.info!["name"].toString()),
                        style: TextStyle(fontSize: 18)),

                    SizedBox(height: 7),
                    Text(titleCase(user.info!['grade']),
                        style: TextStyle(fontSize: 18)),

                    SizedBox(height: 7),
                    user.info!["role"].toString() == "admin"
                        ?Text(titleCase(user.info!['role']),
                        style: TextStyle(fontSize: 18)):
                        SizedBox(),
                    SizedBox(height: 7),
                    Text(
                        formatPhoneNumber(user.info!['phoneNumber'].toString()),
                        style: TextStyle(fontSize: 18)),

                  ]
                )
              ]
            )
          )
        ),

          ),
    );
  }
}
