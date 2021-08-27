import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_app/AddEvent.dart';
import 'package:flutter_app/Details.dart';
import 'package:intl/intl.dart';

import 'User.dart';
import 'cmdb.dart';

class InvitesPage extends StatefulWidget {
  //Class Constructor
  InvitesPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _InvitesPageState createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
  User user = new User();
  CMDB database = new CMDB();

  bool pendingInvitesCollapsed = false;
  Icon collapsePending = Icon(Icons.arrow_drop_down_outlined);

  Map<String, Map<String, dynamic>> allEvents = {};
  Map<String, Map<String, dynamic>> pendingInvites = {};

  @override
  initState() {
    super.initState();
    getAllEvents();
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

                setState(() {});

                Navigator.of(context).pop();
              })
        ],
      ),
    ];
  }


  Map<String, Map<String, dynamic>> sortEvents(
      Map<String, Map<String, dynamic>> events) {
    var sortedKeys = events.keys.toList(growable: false)
      ..sort((k1, k2) => events[k1]!['date']!.compareTo(events[k2]!['date']!));
    LinkedHashMap<String, Map<String, dynamic>?> sortedMap =
        new LinkedHashMap<String, Map<String, dynamic>?>.fromIterable(
            sortedKeys,
            key: (k) => k,
            value: (k) => events[k]);

    return sortedMap as Map<String, Map<String, dynamic>>;
  }

  void getAllEvents() async {
    database.get<Map<String, dynamic>>('Events').then((value) {
      if (value != null) {
        setState(() {
          allEvents = {};
          value.forEach((key, value) {
            DateTime now = DateTime.now();
            String date = value['date'];
            final DateFormat formatter = DateFormat('MM-dd-yyyy');
            DateTime dt1 = formatter.parse(date);
            if (!dt1.isBefore(now) ||
                (dt1.day == now.day &&
                    dt1.year == now.year &&
                    dt1.month == now.month)) {
              allEvents[key] = value as Map<String, dynamic>;
            }
          });
          allEvents = sortEvents(allEvents);
          getPendingInvites();
        });
      }
    });
  }

  Future<void> getPendingInvites() async {
    database
        .get<Map<String, dynamic>>(
            'Users/' + user.info!['username'] + "/pending/")
        .then((value) {
      if (value != null) {
        setState(() {
          pendingInvites = {};
          value.forEach((eventkey, userEventInfo) {
            pendingInvites[eventkey] = allEvents[eventkey]!;
          });
        });
        pendingInvites = sortEvents(pendingInvites);
      }
    });
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
      body: allEvents.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                                title: Text("Pending Invites",
                                    style: TextStyle(fontSize: 28)),
                                trailing: IconButton(
                                  icon: collapsePending,
                                  onPressed: () {
                                    setState(() {
                                      if (pendingInvitesCollapsed == false) {
                                        pendingInvitesCollapsed = true;
                                        collapsePending =
                                            Icon(Icons.arrow_left_outlined);
                                      } else {
                                        pendingInvitesCollapsed = false;
                                        collapsePending = Icon(
                                            Icons.arrow_drop_down_outlined);
                                      }
                                    });
                                  },
                                )),
                            pendingInvitesCollapsed
                                ? SizedBox()
                                : Container(
                                    height:
                                        MediaQuery.of(context).size.height / 5,
                                    child: pendingInvites.isNotEmpty
                                        ? ListView.separated(
                                            shrinkWrap: true,
                                            physics: ScrollPhysics(),
                                            padding: const EdgeInsets.all(20),
                                            itemCount: pendingInvites.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              String key = pendingInvites.keys
                                                  .elementAt(index);
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
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                  '${pendingInvites[key]?['name']}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22))),
                                                          // Align(
                                                          //   alignment: Alignment
                                                          //       .centerLeft,
                                                          //   child: Text(
                                                          //       '${pendingInvites[key]?['time']}' +
                                                          //           "  |  " +
                                                          //           '${pendingInvites[key]?['date']}',
                                                          //       style: TextStyle(
                                                          //           fontSize:
                                                          //               17)),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 4,
                                                        child: OutlinedButton(
                                                          style: OutlinedButton.styleFrom(
                                                              side: BorderSide(
                                                                  color: Colors.orange)),
                                                          child: Text("ACCEPT"),
                                                          onPressed: () {
                                                            setState(() {
                                                              _showDialog(
                                                                  "Do you want to accept event invite?",
                                                                  "Sign Up Confirmation",
                                                                  returnJoinActions());
                                                            }
                                                                //REMOVE EVENT FROM PENDING + ADD TO 'YOUR EVENTS'
                                                                );
                                                          },
                                                        )),
                                                    Expanded(
                                                      flex: 1,
                                                      child: IconButton(
                                                          icon: Icon(
                                                              Icons.more_vert),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DetailsPage(
                                                                            title:
                                                                                "Event Info",
                                                                            event:
                                                                                pendingInvites[key],
                                                                            eventKey:
                                                                                key,
                                                                          )),
                                                            ).then((value) {
                                                              getAllEvents();
                                                            });
                                                          }),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            separatorBuilder:
                                                (BuildContext context,
                                                        int index) =>
                                                    const Divider(
                                                        color: Colors.black26),
                                          )
                                        : Center(
                                            child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            child: Text("No Invites Yet",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.grey)),
                                          ))),
                          ],
                        ),
                      ),
                    ),
                  ]),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
