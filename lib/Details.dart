import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/InvitationView.dart';
import 'package:intl/intl.dart';
import 'User.dart';
import 'cmdb.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {
  //Class Constructor
  DetailsPage(
      {Key? key,
      required this.title,
      required this.event,
      required this.eventKey})
      : super(key: key);

  //Class instance variable
  final String title;

  final Map<String, dynamic>? event;

  final String eventKey;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool joinedEvent = false;
  User user = User();
  CMDB database = CMDB();
  List volunteerList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVolunteers();
  }

  bool eventFull() {
    int limit = int.parse(widget.event!['volunteerLimit']);
    if (volunteerList.length == limit) {
      return true;
    } else {
      return false;
    }
  }

  ElevatedButton disableButton(String disabledButtonText) {
    if (disabledButtonText == "Event Full") {
      print("Event full");
      return ElevatedButton(
          child: Text(disabledButtonText),
          onPressed: null,
          style: ElevatedButton.styleFrom(primary: Colors.orange));
    } else {
      return ElevatedButton(
          child: Text(disabledButtonText),
          onPressed: null,
          style: ElevatedButton.styleFrom(primary: Colors.black87));
    }
  }

  String getDateWordForm(String date) {
    final DateFormat formatter = DateFormat('MM-dd-yyyy');
    DateTime dt = formatter.parse(date);
    int weekday = dt.weekday;
    int month = dt.month;
    int day = dt.day;

    String strWeekday;
    String strMonth;

    switch (weekday) {
      case 1:
        {
          strWeekday = "Monday";
        }
        break;

      case 2:
        {
          strWeekday = "Tuesday";
        }
        break;

      case 3:
        {
          strWeekday = "Wednesday";
        }
        break;

      case 4:
        {
          strWeekday = "Thursday";
        }
        break;

      case 5:
        {
          strWeekday = "Friday";
        }
        break;

      case 6:
        {
          strWeekday = "Saturday";
        }
        break;

      case 7:
        {
          strWeekday = "Sunday";
        }
        break;

      default:
        {
          strWeekday = " ";
        }
        break;
    }

    switch (month) {
      case 1:
        {
          strMonth = "January";
        }
        break;

      case 2:
        {
          strMonth = "February";
        }
        break;

      case 3:
        {
          strMonth = "March";
        }
        break;

      case 4:
        {
          strMonth = "April";
        }
        break;

      case 5:
        {
          strMonth = "May";
        }
        break;

      case 6:
        {
          strMonth = "June";
        }
        break;

      case 7:
        {
          strMonth = "July";
        }
        break;

      case 8:
        {
          strMonth = "August";
        }
        break;

      case 9:
        {
          strMonth = "September";
        }
        break;

      case 10:
        {
          strMonth = "October";
        }
        break;

      case 11:
        {
          strMonth = "November";
        }
        break;

      case 12:
        {
          strMonth = "December";
        }
        break;

      default:
        {
          strMonth = " ";
        }
        break;
    }

    // print(strWeekday + ", " + strMonth + " " + day.toString());
    return (strWeekday + ", " + strMonth + " " + day.toString());
  }

  String titleCase(String s) {
    return s
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  bool flag = false;

  void getVolunteers() {
    database
        .get<Map<String, dynamic>>("Events/" + widget.eventKey + "/volunteers/")
        .then((value) {
      flag = true;
      setState(() {});
      if (value != null) {
        setState(() {
          value.forEach((key, name) {
            if (user.info!['name'] == name['name']) {
              joinedEvent = true;
            }
            volunteerList.add(name['name']);
          });
        });
      }
    });
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

    List<Widget> returnJoinActions() {
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
                child: Text('Confirm Sign Up'),
                onPressed: () {
                  joinedEvent = true;
                  //add your name to the volunteer list
                  volunteerList.add(user.info!['name']);

                  //add your name into the Event volunteer list database
                  database.update(
                      "/Events/" +
                          widget.eventKey +
                          "/volunteers/" +
                          user.info!['username'],
                      {"name": user.info!['name']});

                  //Adding event to your events in database
                  database.update(
                      "Users/" +
                          user.info!['username'] +
                          "/events/" +
                          widget.eventKey +
                          '/',
                      {"eventID": widget.eventKey});

                  //Delete the event from your pending events list
                  database.delete("Users/" +
                      user.info!['username'] +
                      "/pending/" +
                      widget.eventKey +
                      "/");

                  //Delete your name off the event database pending list
                  database.delete("Events/" +
                      widget.eventKey +
                      "/pending/" +
                      user.info!['username']);

                  setState(() {});

                  Navigator.of(context).pop();
                })
          ],
        ),
      ];
    }

    List<Widget> returnCancelActions() {
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
                child: Text('Confirm'),
                onPressed: () {
                  joinedEvent = false;
                  volunteerList.remove(user.info!['name']);

                  database.delete("/Events/" +
                      widget.eventKey +
                      "/volunteers/" +
                      user.info!['username'] +
                      "/");

                  database.delete("/Users/" +
                      user.info!['username'] +
                      "/events/" +
                      widget.eventKey +
                      "/");
                  setState(() {});
                  Navigator.of(context).pop();
                })
          ],
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: flag
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      title: SelectableText(titleCase(widget.event?["name"]),
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      subtitle: SelectableText(
                          "\n" +
                              getDateWordForm(widget.event?["date"]) +
                              "\n" +
                              widget.event?['time'],
                          style: TextStyle(fontSize: 20)),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Location:",
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold))),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 18, right: 18),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(
                                titleCase(widget.event?['location']),
                                style: TextStyle(
                                    fontSize: 19, color: Colors.black87)))),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Details:",
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold))),
                    ),
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 18, right: 18, top: 3),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(widget.event?['details'],
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black87)))),
                    SizedBox(height: 10),
                    widget.event?['link'] != null && widget.event?['link'] != ''
                        ? Padding(
                            padding: const EdgeInsets.only(left: 18, right: 18),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                  child: new Text(
                                    "Website Sign Up Link",
                                    style: new TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline),
                                  ),
                                  onTap: () => launch(widget.event?['link'])),
                            ))
                        : SizedBox(),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Members Signed Up (${volunteerList.length}/${widget.event!['volunteerLimit']})",
                          style: TextStyle(fontSize: 23),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: ListView.builder(
                          itemCount: volunteerList.length,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Text(titleCase('- ${volunteerList[index]}'),
                                style: TextStyle(fontSize: 15));
                          }),
                    ),
                    SizedBox(height: 20),
                    joinedEvent == false
                        ? eventFull()
                            ? disableButton("Event Full")
                            : ElevatedButton(
                                child: Text('Join Event'),
                                onPressed: () {
                                  setState(() {
                                    _showDialog(
                                        "Confirm your sign up?",
                                        "Sign Up Confirmation",
                                        returnJoinActions());
                                  });
                                  //Add name to event
                                },
                              )
                        : Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                eventFull()
                                    ? disableButton("Invite Friends")
                                    : ElevatedButton(
                                        child: Text('Invite Friends'),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  InvitationPage(
                                                      title: "Invite a Friend",
                                                      eventKey:
                                                          widget.eventKey),
                                            ),
                                          );
                                        },
                                      ),
                                ElevatedButton(
                                  child: Text('Cancel Sign Up'),
                                  onPressed: () {
                                    setState(() {
                                      _showDialog(
                                          "Are you sure you want to cancel your sign up?",
                                          "Cancel Confirmation",
                                          returnCancelActions());
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
