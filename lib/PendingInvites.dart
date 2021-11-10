import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_app/Details.dart';
import 'package:intl/intl.dart';

import 'User.dart';
import 'cmdb.dart';

import 'package:crypt/crypt.dart';

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

  // bool pendingInvitesCollapsed = false;
  // Icon collapsePending = Icon(Icons.arrow_drop_down_outlined);

  bool isDone = false;

  Map<String, dynamic> eventInviters = {};

  Map<String, Map<String, dynamic>> allEvents = {};
  Map<String, Map<String, dynamic>> pendingInvites = {};

  List<Icon> iconList = [];
  List<bool> collapsedList = [];

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

  List<Widget> returnIgnoreActions(String eventKey) {
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
              child: Text('Ignore'),
              onPressed: () {
                //Remove from database's event pending list
                database.delete("Events/" +
                    eventKey +
                    "/pending/" +
                    user.info!['username'] +
                    "/");

                //Remove from YOUR event pending list
                database.delete(
                    "Users/" + user.info!['username'] + "/pending/" + eventKey);

                setState(() {});
                getAllEvents();
                Navigator.of(context).pop();
              })
        ],
      ),
    ];
  }

  List<Widget> returnEventIsFullActions(String eventKey) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              child: Text('Delete Invite'),
              onPressed: () {
                //Remove from database's event pending list
                database.delete("Events/" +
                    eventKey +
                    "/pending/" +
                    user.info!['username'] +
                    "/");

                //Remove from YOUR event pending list
                database.delete(
                    "Users/" + user.info!['username'] + "/pending/" + eventKey);

                setState(() {});
                getAllEvents();
                Navigator.of(context).pop();
              }),
          ElevatedButton(
              child: Text('Go To Event Details'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(
                            title: "Event Info",
                            event: pendingInvites[eventKey],
                            eventKey: eventKey,
                          )),
                ).then((value) {
                  getAllEvents();
                });
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
    pendingInvites = {};

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
      } else {
        setState(() {
          isDone = true;
        });
      }
    });
  }

  Future<void> getPendingInvites() async {
    isDone = false;
    database
        .get<Map<String, dynamic>>(
            'Users/' + user.info!['username'] + "/pending/")
        .then((invites) {
      if (invites != null) {
        setState(() {
          pendingInvites = {};
          invites.forEach((eventkey, userEventInfo) {
            pendingInvites[eventkey] = allEvents[eventkey]!;
            eventInviters[eventkey] = userEventInfo["inviters"];

            iconList.add(Icon(Icons.arrow_right_outlined));
            collapsedList.add(true);
          });
        });
        pendingInvites = sortEvents(pendingInvites);
        print(eventInviters);
        isDone = true;
      } else {
        setState(() {
          isDone = true;
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
          strWeekday = "Mon";
        }
        break;

      case 2:
        {
          strWeekday = "Tues";
        }
        break;

      case 3:
        {
          strWeekday = "Wed";
        }
        break;

      case 4:
        {
          strWeekday = "Thurs";
        }
        break;

      case 5:
        {
          strWeekday = "Fri";
        }
        break;

      case 6:
        {
          strWeekday = "Sat";
        }
        break;

      case 7:
        {
          strWeekday = "Sun";
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
          strMonth = "Jan";
        }
        break;

      case 2:
        {
          strMonth = "Feb";
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
          strMonth = "Aug";
        }
        break;

      case 9:
        {
          strMonth = "Sept";
        }
        break;

      case 10:
        {
          strMonth = "Oct";
        }
        break;

      case 11:
        {
          strMonth = "Nov";
        }
        break;

      case 12:
        {
          strMonth = "Dec";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: (){
      //     // Default rounds and random salt generated
      //     final c1 = Crypt.sha256('p@ssw0rd');
      //
      //     // Random salt generated
      //     final c2 = Crypt.sha256('p@ssw0rd', rounds: 10000);
      //
      //     // Default rounds
      //     final c3 = Crypt.sha256('p@ssw0rd', salt: 'abcdefghijklmnop');
      //
      //     // No defaults used
      //     final c4 = Crypt.sha256('p@ssw0rd', rounds: 10000,
      //         salt: 'abcdefghijklmnop');
      //
      //     // SHA-512
      //     final d1 = Crypt.sha512('p@ssw0rd');
      //
      //     for (final hashString in [
      //       r'$5$zQUCjEzs9jnrRdCK$dbo1i9WjQjbUwOC4JCRAZHpfd31Dh676vI0L6w0dZw1',
      //       c1.toString(),
      //       c2.toString(),
      //       c3.toString(),
      //       c4.toString(),
      //       d1.toString(),
      //     ]) {
      //       // Parse the crypt string: this extracts the type, rounds and salt
      //       final h = Crypt(hashString);
      //
      //       final correctValue = 'p@ssw0rd';
      //       final wrongValue = '123456';
      //
      //       if (!h.match(correctValue)) {
      //         print('Error: unexpected non-match: $correctValue');
      //       }
      //
      //       if (h.match(wrongValue)) {
      //         print('Error: unexpected match: $wrongValue');
      //       }
      //
      //     }
      //
      //   },
      // ),
      backgroundColor: Colors.white,
      body: isDone
          ? pendingInvites.isNotEmpty
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: pendingInvites.length,
                  itemBuilder: (BuildContext context, int index) {
                    String eventKey = pendingInvites.keys.elementAt(index);
                    return Container(
                      child: ListView(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                            '${pendingInvites[eventKey]?['name']}',
                                            style: TextStyle(fontSize: 22))),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          getDateWordForm(
                                              '${pendingInvites[eventKey]?['date']}'),
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.black45)),
                                    ),
                                    // Align(
                                    //   alignment: Alignment.centerLeft,
                                    //   child: ListTile(
                                    //     leading: IconButton(
                                    //       icon: iconList[index],
                                    //       onPressed: () {
                                    //         setState(() {
                                    //           if (collapsedList[index] ==
                                    //               false) {
                                    //             collapsedList[index] = true;
                                    //             iconList[index] = Icon(Icons
                                    //                 .arrow_right_outlined);
                                    //           } else {
                                    //             collapsedList[index] = false;
                                    //             iconList[index] = Icon(Icons
                                    //                 .arrow_drop_down_outlined);
                                    //           }
                                    //         });
                                    //       },
                                    //     ),
                                    //     title: Text(
                                    //         "Inviters  (${eventInviters[eventKey].length})",
                                    //         style: TextStyle(fontSize: 17)),
                                    //   ),
                                    // ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: iconList[index],
                                            onPressed: () {
                                              setState(() {
                                                if (collapsedList[index] ==
                                                    false) {
                                                  collapsedList[index] = true;
                                                  iconList[index] = Icon(Icons
                                                      .arrow_right_outlined);
                                                } else {
                                                  collapsedList[index] = false;
                                                  iconList[index] = Icon(Icons
                                                      .arrow_drop_down_outlined);
                                                }
                                              });
                                            },
                                          ),
                                          Text(
                                              "Inviters (${eventInviters[eventKey].length})",
                                              style: TextStyle(fontSize: 17)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 50, left: 4),
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.red)),
                                      child: Text("Ignore",
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        setState(() {
                                          _showDialog(
                                              "Do you want to ignore event invite?",
                                              "Ignore Event Invite",
                                              returnIgnoreActions(eventKey));
                                        });
                                      },
                                    ),
                                  )),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 50, left: 4),
                                  child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          side:
                                              BorderSide(color: Colors.green)),
                                      child: Text("Accept",
                                          style:
                                              TextStyle(color: Colors.green)),
                                      onPressed: () {
                                        // if (pendingInvites[eventKey]!['volunteers'].size() ==
                                        //     int.parse(pendingInvites[eventKey]![
                                        //         'volunteerLimit'])) {
                                        //   _showDialog(
                                        //       "The volunteer spots for this event have been filled",
                                        //       "Event Full",
                                        //       returnEventIsFullActions(
                                        //           eventKey));
                                        // } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailsPage(
                                                      title: "Event Info",
                                                      event: pendingInvites[
                                                          eventKey],
                                                      eventKey: eventKey,
                                                    )),
                                          ).then((value) {
                                            getAllEvents();
                                          });


                                      }),
                                ),
                              ),
                            ],
                          ),
                          collapsedList[index]
                              ? SizedBox()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemCount: eventInviters[eventKey].length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String username = eventInviters[eventKey]
                                        .keys
                                        .elementAt(index);
                                    print(eventInviters[eventKey][username]
                                        ['name']);
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 53),
                                      child: Text(titleCase(
                                          eventInviters[eventKey][username]
                                              ['name'])),
                                    );
                                  }),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(color: Colors.black26),
                )
              : Center(
                  child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text("No Invites Yet",
                      style: TextStyle(fontSize: 20, color: Colors.grey)),
                ))
          : Center(child: CircularProgressIndicator()),
    );
  }
}
