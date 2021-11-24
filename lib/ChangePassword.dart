import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'User.dart';
import 'cmdb.dart';

class ChangePasswordPage extends StatefulWidget {
  //Class Constructor
  ChangePasswordPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
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
           padding: const EdgeInsets.only(top: 40),
           child: Column(
             children: [
               Padding(
                 padding: const EdgeInsets.only(bottom: 5, top: 10, left:20),
                 child: Align(
                   alignment: Alignment.topLeft,
                   child:
                   Text("Enter your old password:",
                       style:
                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
               ),
               Padding(
                 padding:
                 const EdgeInsets.only(left: 20, right: 30, bottom: 10),
                 child: TextField(
                   obscureText: false,
                   controller: oldPassword,
                   decoration: InputDecoration(
                     border: OutlineInputBorder(),
                     // labelText: 'Old password',
                     labelStyle: new TextStyle(color: Colors.grey),
                   ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(bottom: 5, top: 10, left:20),
                 child: Align(
                   alignment: Alignment.topLeft,
                   child:
                   Text("Enter your new password:",
                       style:
                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
               ),
               Padding(
                 padding:
                 const EdgeInsets.only(left: 20, right: 30, bottom: 10),
                 child: TextField(
                   obscureText: false,
                   controller: newPassword,
                   decoration: InputDecoration(
                     border: OutlineInputBorder(),
                     // labelText: ' new password',
                     labelStyle: new TextStyle(color: Colors.grey),
                   ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(bottom: 5, top: 10, left:20),
                 child: Align(
                   alignment: Alignment.topLeft,
                   child:
                   Text("Enter your new password again:",
                       style:
                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
               ),
               Padding(
                 padding:
                 const EdgeInsets.only(left: 20, right: 30, bottom: 10),
                 child: TextField(
                   obscureText: false,
                   controller: newPConfirm,
                   decoration: InputDecoration(
                     border: OutlineInputBorder(),
                     // labelText: 'Enter new password again',
                     labelStyle: new TextStyle(color: Colors.grey),
                   ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       ElevatedButton(
                         child: Text("Cancel"),
                         onPressed: () {
                           newPassword.text = "";
                           oldPassword.text = "";
                           newPConfirm.text = "";
                           Navigator.pop(context);
                         },
                       ),
                       ElevatedButton(
                         child: Text("Change Password"),
                         onPressed: () {
                           print(user.info);
                           print(oldPassword.text == user.info!['password']);
                           print(newPConfirm.text == newPassword.text);
                           if (oldPassword.text == user.info!['password'] &&
                               newPConfirm.text == newPassword.text) {
                             user.info!['password'] = newPassword.text;
                             database
                                 .get<Map<String, dynamic>>(
                                 "Users/" + user.info!['username'])
                                 .then((value) {
                               value!['password'] = newPassword.text;
                               database
                                   .update(
                                   "Users/" + user.info!['username'] + "/",
                                   value)
                                   .then((value) {
                                 if (value == true) {
                                   _showDialog("Password successfully changed",
                                       'Success!', changePasswordPopup());
                                   newPassword.text = "";
                                   oldPassword.text = "";
                                   newPConfirm.text = "";
                                 }
                               });
                             });
                           } else {
                             _showDialog("Incorrect, try again",
                                 'Password Change', changePasswordPopup());
                           }
                         },
                       )
                     ]),
               ),
             ],
           ),
         ),
       ),
    );
  }
}
