import 'package:flutter/material.dart';
import 'package:flutter_app/ChangePassword.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'EditProfile.dart';
import 'Login.dart';
import 'PastEvents.dart';
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
  List<String> userStats = ["0", '0'];

  bool isDone = false;

  @override
  initState() {
    super.initState();
    getStats();
  }

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
                Navigator.of(context).pop();
              }),
        ],
      ),
    ];
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  String timeOfDayToString(TimeOfDay tod) {
    String time = tod.toString();
    return time.substring(10, 15);
  }

  void getStats() {
    List<String> stats = [];
    database
        .get<Map>("Users/" + user.info!['username'] + "/" + "statistics")
        .then((value) {
      if (value != null) {
        setState(() {
          stats.add(value['totalHours']);
          stats.add(value['eventCount']);
          print(stats);
          userStats = stats;
          isDone = true;
        });
      } else {
        setState(() {
          print('it didnt work / no stats yet');
          userStats = ['0', '0'];
          isDone = true;
        });
      }
    });
  }

  double calculateEventHours(String eventTimeRange) {

    TimeOfDay st = stringToTimeOfDay(eventTimeRange.split(' - ')[0]);
    TimeOfDay et = stringToTimeOfDay(eventTimeRange.split(' - ')[1]);

    var format = DateFormat("HH:mm");
    var start = format.parse(timeOfDayToString(st));
    var end = format.parse(timeOfDayToString(et));

    return (end.difference(start).inMinutes)/60;
  }

  void calcAllStats(String username) {

    List<double> hoursList = [];

    database.get<Map<String, dynamic>>("Users/" + username + "/pastEvents").then((pastEvents) {
      if (pastEvents != null){

        Iterable pastEventKeys = pastEvents.keys;

        pastEventKeys.forEach((eventKey) {

          database.get<Map<String, dynamic>>("PastEvents/" + eventKey).then((eventInfo) {
            double eventHours = double.parse(eventInfo!['eventHours']);
            hoursList.add(eventHours);

            if (hoursList.length == pastEventKeys.length) {
              print(hoursList);

              double totalHours = 0;

              for (int i = 0; i < hoursList.length; i++) {
                totalHours += hoursList[i];
              }
              print(totalHours);

              if(totalHours.truncate() == totalHours){
                database.update("Users/" + username + "/statistics", {
                  "totalHours": totalHours.truncate().toString(),
                  'eventCount': pastEventKeys.length.toString()
                });
              }
              else{
                database.update("Users/" + username + "/statistics", {
                  "totalHours": totalHours.toStringAsFixed(1),
                  'eventCount': pastEventKeys.length.toString()
                });
              }

            }
          });

        });
      }
    });

  }

  String titleCase(String s) {
    return s
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String formatPhoneNumber(String number) {
    String temp = number.trim();
    String prettify = '';

    if (temp.startsWith("+1")) {
      temp = temp.trim().substring(2);
    }

    for (int i = 0; i < temp.length; i++) {
      if (!(temp[i] == '+' ||
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

  @override
  Widget build(BuildContext context) {
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
    List<Widget> returnSignOutActions() {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            ElevatedButton(
                child: Text('Sign Out'),
                onPressed: () {
                  removeUserPrefKey().then((value) {
                    user.info = {};
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage(title: "Login")),
                    );
                  });
                })
          ],
        ),
      ];
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     database.get<Map<String,dynamic>>("Users").then((value) {
      //       if(value!= null){
      //         value.keys.forEach((username) {
      //           calculateStatistics(username);
      //         });
      //         print("Done calcualted");
      //       }
      //       else{
      //         print("something went wrong");
      //       }
      //     });
      //   }
      // ),
      backgroundColor: Colors.white,
      body: isDone
          ? Padding(
              padding: const EdgeInsets.only(top: 30, left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: ListView(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Account Information",
                          style: TextStyle(
                              fontSize: 27, fontWeight: FontWeight.bold)),
                      // TextButton(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) =>
                      //               EditProfilePage(title: "Edit Profile")),
                      //     );
                      //   },
                      //   child: Text("Edit", style: TextStyle(fontSize: 18)),
                      // ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(children: [
                    Text("Username:           ",
                        style: TextStyle(fontSize: 18)),
                    Text(user.info!["username"],
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 17))
                  ]),
                  SizedBox(height: 7),
                  Row(children: [
                    Text("Name:                  ",
                        style: TextStyle(fontSize: 18)),
                    Text(titleCase(user.info!["name"].toString()),
                        style: TextStyle(fontSize: 18))
                  ]),
                  SizedBox(height: 7),
                  Row(children: [
                    Text("Grade:                  ",
                        style: TextStyle(fontSize: 18)),
                    Text(titleCase(user.info!['grade']),
                        style: TextStyle(fontSize: 18))
                  ]),
                  SizedBox(height: 7),
                  user.info!["role"].toString() == "admin"
                      ? Row(children: [
                          Text("Role:                     ",
                              style: TextStyle(fontSize: 18)),
                          Text(titleCase(user.info!['role']),
                              style: TextStyle(fontSize: 18))
                        ])
                      : SizedBox(),
                  SizedBox(height: 7),
                  Row(children: [
                    Text("Phone Number:   ", style: TextStyle(fontSize: 18)),
                    Text(
                        formatPhoneNumber(user.info!['phoneNumber'].toString()),
                        style: TextStyle(fontSize: 18))
                  ]),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        border: Border.all(
                          width: 1,
                          color: Colors.orange,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(children: []),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: ListTile(
                      dense: true,
                      title: Text('Change Password',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.w400)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChangePasswordPage(title: "Change Password")),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        border: Border.all(
                          width: 1,
                          color: Colors.orange,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(children: []),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text("Statistics",
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                  ListTile(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PastEventsPage(title: "Past Events")),
                        );
                      },
                      leading: Icon(Icons.access_time_sharp,
                          size: 45, color: Colors.orange),
                      title: Text("${userStats[0]}",
                          style: TextStyle(fontSize: 20)),
                      subtitle: Text("hours volunteered",
                          style: TextStyle(color: Colors.black))),
                  ListTile(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PastEventsPage(title: "Past Events")),
                        );
                        },
                      leading:
                          Icon(Icons.equalizer, size: 45, color: Colors.orange),
                      title: Text("${userStats[1]}",
                          style: TextStyle(fontSize: 20)),
                      subtitle: Text("events attended",
                          style: TextStyle(color: Colors.black))),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        border: Border.all(
                          width: 1,
                          color: Colors.orange,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(children: []),
                    ),
                  ),
                  TextButton(
                    // style: TextButton.styleFrom(
                    //   textStyle: TextStyle(fontSize: 14),
                    // ),
                    onPressed: () {
                      // removeUserPrefKey().then((value) {
                      //   user.info = {};
                      //   Navigator.pop(context);
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => LoginPage(title: "Login")),
                      //   );
                      // });
                      _showDialog("Are you sure you want to sign out?", "Sign Out Confirmation", returnSignOutActions());
                    },
                    child: Text('Sign Out',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  user.info!['username'] == "serenaw"?
                  Padding(
                    padding: const EdgeInsets.only(left:270, top: 40),
                    child: RawMaterialButton(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(15.0),
                        fillColor: Colors.orangeAccent,
                      child: Icon(Icons.calculate_rounded, size: 40, color: Colors.white),
                        onPressed: (){

                          database.get<Map<String,dynamic>>("Users").then((value) {
                            if(value!= null){
                              value.keys.forEach((username) {

                                calcAllStats(username);

                              });
                              print("Done calcualted");
                            }
                            else{
                              print("something went wrong");
                            }
                          });
                        }
                    ),
                  ):
                      SizedBox(),
                ]),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
