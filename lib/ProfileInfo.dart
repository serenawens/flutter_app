import 'package:flutter/material.dart';
import 'package:flutter_app/ChangePassword.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  int countHours() {
    //use user key to access events
    //iterate through events
    //IF event has already passsed (look at the date)
    //Look at TIME ranges of those events
    //Calculate the hours
    //Add hours in
    int totalHours = 0;
    String username = user.info!['username'];
    print(username);
    database
        .get<Map<String, dynamic>>('Users/' + username + '/' + 'events/')
        .then((eventID) {
      if (eventID != null) {
        eventID.forEach((key, value) {
          // Map<String, dynamic> event = database.get<Map<String, dynamic>>(key)
        });
      }
    });

    return 0;
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
                Navigator.of(context).pop();
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Center(
                child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(titleCase(user.info!["name"]),
                  style: TextStyle(
                    fontSize: 35,
                    // fontWeight: FontWeight.bold,
                  )),
            )),
            // SizedBox(height: 30),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 4, left: 4),
                child: Text(user.info!["username"],
                    style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54)),
              ),
            ),
            Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(titleCase(user.info!["grade"]),
                  style: TextStyle(fontSize: 18)),
              Text("  "),
              Icon(Icons.circle_rounded, size: 5),
              Text("  "),
              Text(titleCase(user.info!["role"]),
                  style: TextStyle(fontSize: 18))
            ])),
            Center(
                child: Text(user.info!["phoneNumber"].toString(),
                    style: TextStyle(fontSize: 19))),
            // Padding(
            //   padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.all(
            //         Radius.circular(10),
            //       ),
            //       border: Border.all(
            //         width: 3,
            //         color: Colors.orange,
            //         style: BorderStyle.solid,
            //       ),
            //     ),
            //     child: Column(children: [
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Align(
            //           alignment: Alignment.centerLeft,
            //           child:
            //               Text("Account Info", style: TextStyle(fontSize: 28)),
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: Text(
            //                 "Phone Number: " +
            //                     user.info!["phoneNumber"].toString(),
            //                 style: TextStyle(fontSize: 19))),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: Text("Grade: " + titleCase(user.info!["grade"]),
            //                 style: TextStyle(fontSize: 20))),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: Text("Role: " + titleCase(user.info!["role"]),
            //                 style: TextStyle(fontSize: 20))),
            //       ),
            //     ]),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  border: Border.all(
                    width: 3,
                    color: Colors.orange,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(children: []),
              ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChangePasswordPage(title: "Change Password")),
                );
              },
              child: Text('Change Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  removeUserPrefKey().then((value) {
                    user.info = {};
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage(title: "Login")),
                    );
                  });
                },
                child: Text('Sign Out',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
