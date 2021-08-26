import 'package:flutter/material.dart';
import 'package:flutter_app/InvitationView.dart';
import 'User.dart';
import 'cmdb.dart';

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
      setState(() {
      });
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
                  database.delete(
                      "Users/" +
                          user.info!['username'] +
                          "/pending/" + widget.eventKey + "/");

                  //Delete your name off the event database pending list
                  database.delete(
                      "Events/" +
                          widget.eventKey + "/pending/" + user.info!['username']);

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
          padding: const EdgeInsets.only(top: 100),
          child: flag
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      title: Text(titleCase(widget.event?["name"]),
                          style: TextStyle(fontSize: 50)),
                      subtitle: Text(
                          widget.event?["date"] +
                              "\n" +
                              widget.event?['time'] +
                              "\n" +
                              titleCase(widget.event?['location']),
                          style: TextStyle(fontSize: 20)),
                    ),
                    ListTile(
                      title: Text(widget.event?['details']),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 170),
                      child: Text(
                        "Members Signed Up: ",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListView.builder(
                          itemCount: volunteerList.length,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Text(titleCase('${volunteerList[index]}'),
                                style: TextStyle(fontSize: 15));
                          }),
                    ),
                    SizedBox(height: 20),
                    joinedEvent == false
                        ? ElevatedButton(
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
                                ElevatedButton(
                                  child: Text('Invite Friends'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InvitationPage(
                                            title: "Invite a Friend",
                                            eventKey: widget.eventKey),
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
