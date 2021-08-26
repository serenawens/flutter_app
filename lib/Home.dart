import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_app/Details.dart';
import 'package:intl/intl.dart';
import 'EditEvent.dart';
import "User.dart";
import 'cmdb.dart';

class HomePage extends StatefulWidget {
  //Class Constructor
  HomePage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    getAllEvents().then((value) {
      getUserEvents();
      getPendingInvites();
    });
  }

  User user = new User();
  CMDB database = new CMDB();

  Future<void> getAllEvents() async {
    database.get<Map<String, dynamic>>('Events').then((value) {
      setState(() {
        value!.forEach((key, value) {
          DateTime now = DateTime.now();
          String date = value['date'];
          final DateFormat formatter = DateFormat('MM-dd-yyyy');
          DateTime dt1 = formatter.parse(date);
          if (!dt1.isBefore(now) ||
              (dt1.day == now.day &&
                  dt1.year == now.year &&
                  dt1.month == now.month)) {
            allEvents[key] = value as Map<String, dynamic>;
            allEventsList.add(value);
          }
        });

        // var sortedKeys = allEvents.keys.toList(growable: false)
        //   ..sort(
        //           (k1, k2) => allEvents[k1]!['date']!.compareTo(allEvents[k2]!['date']!));
        // LinkedHashMap<String, Map<String, dynamic?>> sortedMap =
        // new LinkedHashMap<String, Map<String, dynamic?>>.fromIterable(
        //     sortedKeys,
        //     key: (k) => k,
        //     value: (k) => allEvents[k]);
        // print(sortedMap);

        allEventsList.sort((a, b) {
          final DateFormat formatter = DateFormat('MM-dd-yyyy');
          DateTime adt = formatter.parse(a['date']);
          DateTime bdt = formatter.parse(b['date']);
          // using time to compare: if adt and bdt are the same , compare their start times
          return adt.compareTo(bdt);
        });
      });
    });
  }

  Future<void> getUserEvents() async {
    database
        .get<Map<String, dynamic>>(
            'Users/' + user.info!['username'] + "/events/")
        .then((value) {
      setState(() {
        value!.forEach((eventkey, userEventInfo) {
          userEvents[eventkey] = allEvents[eventkey]!;
        });
      });
    });
  }

  Future<void> getPendingInvites() async {
    database
        .get<Map<String, dynamic>>(
            'Users/' + user.info!['username'] + "/pending/")
        .then((value) {
      setState(() {
        value!.forEach((eventkey, userEventInfo) {
          pendingInvites[eventkey] = allEvents[eventkey]!;
        });
      });
    });
  }

  String titleCase(String s) {
    return s
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Map<String, Map<String, dynamic>> allEvents = {};
  List<Map<String, dynamic>> allEventsList = [];

  Map<String, Map<String, dynamic>> userEvents = {};
  List<Map<String, dynamic>> userEventsList = [];

  Map<String, Map<String, dynamic>> pendingInvites = {};

  bool allEventsCollapsed = false;
  Icon collapseAll = Icon(Icons.arrow_drop_down_outlined);

  bool yourEventsCollapsed = false;
  Icon collapseUsers = Icon(Icons.arrow_drop_down_outlined);

  bool pendingCollapsed = false;
  Icon collapsePending = Icon(Icons.arrow_drop_down_outlined);


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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
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
                  child: Column(
                    children: [
                      ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(left: 70, right: 0),
                            child: Text("Your Events",
                                style: TextStyle(fontSize: 28)),
                          ),
                          trailing: IconButton(
                            icon: collapseUsers,
                            onPressed: () {
                              setState(() {
                                if (yourEventsCollapsed == false) {
                                  yourEventsCollapsed = true;
                                  collapseUsers =
                                      Icon(Icons.arrow_left_outlined);
                                } else {
                                  yourEventsCollapsed = false;
                                  collapseUsers =
                                      Icon(Icons.arrow_drop_down_outlined);
                                }
                              });
                            },
                          )),
                      yourEventsCollapsed
                          ? SizedBox(
                              height: 0,
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height / 5,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                padding: const EdgeInsets.all(20),
                                itemCount: userEvents.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String key = userEvents.keys.elementAt(index);
                                  return Container(
                                    height: 50,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: Column(
                                            children: [
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                      titleCase(
                                                          '${userEvents[key]?['name']}'),
                                                      style: TextStyle(
                                                          fontSize: 22))),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    '${userEvents[key]?['time']}' +
                                                        "  |  " +
                                                        '${userEvents[key]?['date']}',
                                                    style: TextStyle(
                                                        fontSize: 17)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: IconButton(
                                              icon: Icon(Icons.more_vert),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsPage(
                                                            title: "Event Info",
                                                            event:
                                                                userEvents[key],
                                                            eventKey: key,
                                                          )),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(color: Colors.black26),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
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
                  child: Column(
                    children: [
                      ListTile(
                          title: Text("All Events",
                              style: TextStyle(fontSize: 28)),
                          trailing: IconButton(
                            icon: collapseAll,
                            onPressed: () {
                              setState(() {
                                if (allEventsCollapsed == false) {
                                  allEventsCollapsed = true;
                                  collapseAll = Icon(Icons.arrow_left_outlined);
                                } else {
                                  allEventsCollapsed = false;
                                  collapseAll =
                                      Icon(Icons.arrow_drop_down_outlined);
                                }
                              });
                            },
                          )),
                      allEventsCollapsed
                          ? SizedBox()
                          : Container(
                              //change size of the box around event list
                              height: MediaQuery.of(context).size.height / 5,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                padding: const EdgeInsets.all(20),
                                itemCount: allEventsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String key = allEvents.keys.elementAt(index);
                                  return Container(
                                    height: 50,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: Column(
                                            children: [
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                      titleCase(
                                                          '${allEventsList[index]['name']}'),
                                                      style: TextStyle(
                                                          fontSize: 24))),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    '${allEventsList[index]['time']}' +
                                                        "  |  " +
                                                        '${allEventsList[index]['date']}',
                                                    style: TextStyle(
                                                        fontSize: 15)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        user.info!["role"] == "admin"
                                            ? Expanded(
                                                flex: 1,
                                                child: IconButton(
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditEventPage(
                                                                  title:
                                                                      "Edit Event",
                                                                  events:
                                                                      allEvents,
                                                                  eventKey: key,
                                                                )),
                                                      ).then((value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            allEvents = value;
                                                          });
                                                        }
                                                      });
                                                    }),
                                              )
                                            : SizedBox(),
                                        Expanded(
                                          flex: 1,
                                          child: IconButton(
                                              icon: Icon(Icons.more_vert),
                                              onPressed: () {
                                                print(key);
                                                print(allEvents);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsPage(
                                                            title: "Event Info",
                                                            event:
                                                                allEvents[key],
                                                            eventKey: key,
                                                          )),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(color: Colors.black26),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
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
                  child: Column(
                    children: [
                      ListTile(
                          title: Text("Pending Invites",
                              style: TextStyle(fontSize: 28)),
                          trailing: IconButton(
                            icon: collapsePending,
                            onPressed: () {
                              setState(() {
                                if (pendingCollapsed == false) {
                                  pendingCollapsed = true;
                                  collapsePending =
                                      Icon(Icons.arrow_left_outlined);
                                } else {
                                  pendingCollapsed = false;
                                  collapsePending =
                                      Icon(Icons.arrow_drop_down_outlined);
                                }
                              });
                            },
                          )),
                      pendingCollapsed
                          ? SizedBox()
                          : Container(
                              height: MediaQuery.of(context).size.height / 5,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                padding: const EdgeInsets.all(20),
                                itemCount: pendingInvites.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String key =
                                      pendingInvites.keys.elementAt(index);
                                  print(pendingInvites.length);
                                  if (pendingInvites.length < 1) {
                                    return Container(
                                      height: 50,
                                      child: Text("No Pending Invites", style: TextStyle(color: Colors.black))
                                    );
                                  } else {
                                    print("hello world");
                                    return Container(
                                      height: 50,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 7,
                                            child: Column(
                                              children: [
                                                Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                        titleCase(
                                                            '${pendingInvites[key]?['name']}'),
                                                        style: TextStyle(
                                                            fontSize: 22))),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      '${pendingInvites[key]?['time']}' +
                                                          "  |  " +
                                                          '${pendingInvites[key]?['date']}',
                                                      style: TextStyle(
                                                          fontSize: 17)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Expanded(
                                          //     flex: 3,
                                          //     child: OutlinedButton(
                                          //       style: OutlinedButton.styleFrom(
                                          //           side: BorderSide(
                                          //               color: Colors.orange)),
                                          //       child: Text("ACCEPT"),
                                          //       onPressed: () {
                                          //         setState(() {
                                          //           _showDialog(
                                          //               "Do you want to accept event invite?",
                                          //               "Sign Up Confirmation",
                                          //               returnJoinActions());
                                          //         }
                                          //             //REMOVE EVENT FROM PENDING + ADD TO 'YOUR EVENTS'
                                          //             );
                                          //       },
                                          //     )),
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                                icon: Icon(Icons.more_vert),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailsPage(
                                                              title:
                                                                  "Event Info",
                                                              event:
                                                                  pendingInvites[
                                                                      key],
                                                              eventKey: key,
                                                            )),
                                                  );
                                                }),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(color: Colors.black26),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
