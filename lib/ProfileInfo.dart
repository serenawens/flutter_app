import 'package:flutter/material.dart';
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
          if(eventID != null){

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
              padding: const EdgeInsets.only(top: 10),
              child: Text(titleCase(user.info!["name"]),
                  style: TextStyle(
                    fontSize: 40,
                  )),
            )),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Username: " + user.info!["username"],
                    style: TextStyle(fontSize: 20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "Phone Number: " + user.info!["phoneNumber"].toString(),
                      style: TextStyle(fontSize: 19))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Grade: " + titleCase(user.info!["grade"]),
                      style: TextStyle(fontSize: 20))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Role: " + titleCase(user.info!["role"]),
                      style: TextStyle(fontSize: 20))),
            ),
            SizedBox(height: 15),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
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
            //     child:
            Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 10),
                  child: Text("Change Password",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: TextField(
                    obscureText: false,
                    controller: oldPassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter old password',
                      labelStyle: new TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: TextField(
                    obscureText: false,
                    controller: newPassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter new password',
                      labelStyle: new TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: TextField(
                    obscureText: false,
                    controller: newPConfirm,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter new password again',
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
            //   ),
            // ),
            SizedBox(height: 10),
            TextButton(
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
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
