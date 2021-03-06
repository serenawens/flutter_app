import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_app/Details.dart';
import 'package:intl/intl.dart';
import 'EditEvent.dart';
import "User.dart";
import 'cmdb.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  //Class Constructor
  HomePage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User user = new User();
  CMDB database = new CMDB();
  Map<String, Map<String, dynamic>> allEvents = {};
  Map<String, Map<String, dynamic>> userEvents = {};
  Map<String, Map<String, dynamic>> pendingInvites = {};

  @override
  initState() {
    super.initState();
    getAllEvents();
    getCollapsedValues();
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
          strWeekday = "Tue";
        }
        break;

      case 3:
        {
          strWeekday = "Wed";
        }
        break;

      case 4:
        {
          strWeekday = "Thur";
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

  bool eventFull(Map event) {
    if (event['volunteers'] != null) {
      int limit = int.parse(event['volunteerLimit']);

      if (event['volunteers'].keys.length == limit) {
        return true;
      }
      if (event['hasEventOfficer'] == null &&
          limit - 1 == event['volunteers'].keys.length) {
        return true;
      }
    }
    return false;
  }

  int getEventSpotsFilled(Map event) {
    if (event['volunteers'] == null) {
      return 0;
    } else if (event['hasEventOfficer'] != null) {
      //Just the eventOfficer is signed up
      if (event['volunteers'].keys.length == 1) {
        return 0;
      } else {
        return event['volunteers'].keys.length - 1;
      }
    }

    return event['volunteers'].keys.length;
  }

  int getEventLimit(Map event) {
    return int.parse(event['volunteerLimit']) - 1;
  }

  bool oneSpotLeft(Map event, String key) {
    int spotsLeft =
        getEventLimit(event[key]!) - getEventSpotsFilled(event[key]!);

    if (spotsLeft == 1) return true;
    return false;
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

  void _resetEvents() {
    allEvents = {};
    userEvents = {};
    pendingInvites = {};
  }

  void moveFromPastBackToNormal() {
    String eventKey = "-Mo0a2LcliqHSUKR8TCd";

    database
        .get<Map<String, dynamic>>('PastEvents/' + eventKey + "/")
        .then((value) {
      if (value != null) {
        database.update('Events/' + eventKey + "/", value);
        database.delete("PastEvents/" + eventKey);
      }
    });

    database
        .get<Map<String, dynamic>>(
            'Events/' + eventKey + "/" + "volunteers" + "/")
        .then((value) {
      if (value != null) {
        value.forEach((user, name) {
          database.update("Users/" + user + "/events/" + eventKey + '/',
              {"eventID": eventKey});

          database.delete("Users/" + user + "/pastEvents/" + eventKey);
        });
      }
    });
  }

  void moveEventToPast(eventKey, value) {
    database.update('PastEvents/' + eventKey + "/", value);
    database.delete("Events/" + eventKey);
  }

  void deleteEventFromPending(eventKey) {
    //DELETE EVENT FROM PENDING INVITES
    database
        .get<Map<String, dynamic>>("Events/" + eventKey + "/pending/")
        .then((value) {
      if (value != null) {
        print("YES PENDING");

        value.forEach((username, name) {
          print(username);

          database.delete("Users/" + username + "/pending/" + eventKey);
        });
      } else {
        print("NO PENDING");
      }
    });
  }

  void moveVolunteerEventToPast(String eventKey, value) {
    int eventHours = calculateEventHours(eventKey, value);

    //Move volunteer-related stuff to PAST EVENTS
    database
        .get<Map<String, dynamic>>("Events/" + eventKey + "/volunteers/")
        .then((value) {
      if (value != null) {
        print("YES VOLUNTEERS");

        value.forEach((user, name) {
          database.update("Users/" + user + "/pastEvents/" + eventKey + '/',
              {"eventID": eventKey});

          database.delete("Users/" + user + "/events/" + eventKey);

          database.get<Map<String,dynamic>>("Users/" + user + "statistics/").then((userStats) {

            if(userStats != null){

              print('yes user stats');

              int newUserHours = int.parse(userStats['totalHours']) + eventHours;
              int newEventCount = int.parse(userStats['eventCount']) + 1;

              database.update("Users/" + user + "/statistics", {
                "totalHours": newUserHours.toString(),
                'eventCount': newEventCount.toString()
              });
            }

            else{
              print('no userstats? ERROR');
            }

          });
        });
      } else {
        value!.forEach((user, name) {
          database.update("Users/" + user + "/pastEvents/" + eventKey + '/',
              {"eventID": eventKey});

          database.delete("Users/" + user + "/events/" + eventKey);
        });
      }
    });

    deleteEventFromPending(eventKey);
    moveEventToPast(eventKey, value);
  }

  void getAllEvents() async {
    _resetEvents();
    database.get<Map<String, dynamic>>('Events').then((eventMap) {
      if (eventMap != null) {
        setState(() {
          allEvents = {};
          eventMap.forEach((eventKey, value) {
            DateTime now = DateTime.now();
            String date = value['date'];
            final DateFormat formatter = DateFormat('MM-dd-yyyy');
            DateTime dt1 = formatter.parse(date);

            print(dt1.toString());
            print(now.toString());

            if (dt1.isBefore(now) &&
                !(dt1.day == now.day &&
                    dt1.year == now.year &&
                    dt1.month == now.month)) {

              moveVolunteerEventToPast(eventKey, value);

            } else {
              allEvents[eventKey] = value as Map<String, dynamic>;
            }
          });

          allEvents = sortEvents(allEvents);
          getUserEvents();
        });
      } else {
        setState(() {
          isDone = true;
        });
      }
    });
  }

  Future<void> getUserEvents() async {
    isDone = false;
    database
        .get<Map<String, dynamic>>(
            'Users/' + user.info!['username'] + "/events/")
        .then((value) {
      if (value != null) {
        setState(() {
          userEvents = {};
          value.forEach((eventkey, userEventInfo) {
            userEvents[eventkey] = allEvents[eventkey]!;
          });
        });
        userEvents = sortEvents(userEvents);
        isDone = true;
      } else {
        setState(() {
          isDone = true;
        });
      }
    });
  }

  int calculateEventHours(String eventKey, value) {
    String eventTimeRange = value!["time"];

    TimeOfDay st = stringToTimeOfDay(eventTimeRange.split(' - ')[0]);
    TimeOfDay et = stringToTimeOfDay(eventTimeRange.split(' - ')[1]);

    var format = DateFormat("HH:mm");
    var start = format.parse(timeOfDayToString(st));
    var end = format.parse(timeOfDayToString(et));

    return end.difference(start).inHours;
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  String timeOfDayToString(TimeOfDay tod) {
    String time = tod.toString();
    return time.substring(10, 15);
  }

  String titleCase(String s) {
    return s
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  bool userEventsCollapsed = false;
  Icon collapseUsers = Icon(Icons.arrow_drop_down_outlined);

  bool allEventsCollapsed = false;
  Icon collapseAll = Icon(Icons.arrow_drop_down_outlined);

  bool isDone = false;

  void saveCollapsedValues(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<void> getCollapsedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.containsKey(user.info!['username'] + '/userEventsCollapsed')) {
        userEventsCollapsed =
            prefs.getBool(user.info!['username'] + "/userEventsCollapsed")!;
        collapseUsers = setCollapseIcons(userEventsCollapsed);
      }
      if (prefs.containsKey(user.info!['username'] + '/allEventsCollapsed')) {
        allEventsCollapsed =
            prefs.getBool(user.info!['username'] + "/allEventsCollapsed")!;
        collapseAll = setCollapseIcons(allEventsCollapsed);
      }
    });
  }

  Icon setCollapseIcons(bool isCollapsed) {
    if (isCollapsed == false) {
      return Icon(Icons.arrow_drop_down_outlined);
    } else {
      return Icon(Icons.arrow_left_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //
      //   String eventKey = '-MurhY2gIwiiQrrzQNsz';
      //   database.get<Map<String,dynamic>>("Events/" + eventKey).then((value) {
      //     moveVolunteerEventToPast(eventKey, value);
      //   });
      //
      // }),
      backgroundColor: Colors.white,
      body: isDone
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 10, right: 10),
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
                              title: Text("My Events",
                                  style: TextStyle(fontSize: 28)),
                              trailing: IconButton(
                                icon: collapseUsers,
                                onPressed: () {
                                  setState(() {
                                    if (userEventsCollapsed == false) {
                                      userEventsCollapsed = true;
                                      collapseUsers =
                                          Icon(Icons.arrow_left_outlined);
                                    } else {
                                      userEventsCollapsed = false;
                                      collapseUsers =
                                          Icon(Icons.arrow_drop_down_outlined);
                                    }
                                  });
                                  saveCollapsedValues(
                                      user.info!['username'] +
                                          "/userEventsCollapsed",
                                      userEventsCollapsed);
                                },
                              )),
                          // Divider(
                          //   color: Colors.deepOrange,
                          //   indent: 20,
                          //   endIndent: 20
                          // ),
                          //IF MY EVENTS BOX IS COLLAPSED
                          userEventsCollapsed
                              ? SizedBox()
                              : //MY EVENTS BOX IS NOT COLLAPSED
                              //AND IF MORE THAN 3 EVENTS, KEEP CONTAINER SIZE AT CERTAIN LIMIT
                              userEvents.length > 3
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3.35,
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        physics: ScrollPhysics(),
                                        padding: const EdgeInsets.all(20),
                                        itemCount: userEvents.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          String key =
                                              userEvents.keys.elementAt(index);
                                          return InkWell(
                                              child: Container(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 7,
                                                      child: Column(
                                                        children: [
                                                          eventFull(userEvents[
                                                                  key]!)
                                                              ? Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                          '${userEvents[key]?['name']}',
                                                                          style:
                                                                              TextStyle(fontSize: 22)),
                                                                      Text(
                                                                          '(FULL)',
                                                                          style:
                                                                              TextStyle(fontSize: 15))
                                                                    ],
                                                                  ))
                                                              : Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                          '${userEvents[key]?['name']}',
                                                                          style:
                                                                              TextStyle(fontSize: 22)),
                                                                      oneSpotLeft(
                                                                              userEvents,
                                                                              key)
                                                                          ? Text(
                                                                              ' (1 spot left)',
                                                                              style: TextStyle(fontSize: 15))
                                                                          : Text(' (${getEventLimit(userEvents[key]!) - getEventSpotsFilled(userEvents[key]!)} spots left)', style: TextStyle(fontSize: 15))
                                                                    ],
                                                                  )),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                                '${userEvents[key]?['time']}' +
                                                                    "  |  " +
                                                                    getDateWordForm(
                                                                        '${userEvents[key]?['date']}'),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
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
                                                ).then((value) {
                                                  getAllEvents();
                                                });
                                              });
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                const Divider(
                                                    color: Colors.black26),
                                      ),
                                    )
                                  : //IF EVENT COUNT IS LESS THAN 3 -- CONTAINER SIZE IS FLEXIBLE
                                  Container(

                                      //IF THE NUM OF EVENTS ISN"T 0
                                      child: userEvents.isNotEmpty
                                          ? ListView.separated(
                                              shrinkWrap: true,
                                              physics: ScrollPhysics(),
                                              padding: const EdgeInsets.all(20),
                                              itemCount: userEvents.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                String key = userEvents.keys
                                                    .elementAt(index);
                                                return InkWell(
                                                    child: Container(
                                                      height: 50,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 7,
                                                            child: Column(
                                                              children: [
                                                                eventFull(userEvents[
                                                                        key]!)
                                                                    ? Align(
                                                                        alignment:
                                                                            Alignment
                                                                                .topLeft,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text('${userEvents[key]?['name']}',
                                                                                style: TextStyle(fontSize: 22)),
                                                                            Text(' (FULL)',
                                                                                style: TextStyle(fontSize: 15))
                                                                          ],
                                                                        ))
                                                                    : Align(
                                                                        alignment:
                                                                            Alignment
                                                                                .topLeft,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text('${userEvents[key]?['name']}',
                                                                                style: TextStyle(fontSize: 22)),
                                                                            oneSpotLeft(userEvents, key)
                                                                                ? Text(' (1 spot left)', style: TextStyle(fontSize: 17))
                                                                                : Text(' (${getEventLimit(allEvents[key]!) - getEventSpotsFilled(allEvents[key]!)} spots left)', style: TextStyle(fontSize: 15))
                                                                          ],
                                                                        )),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                      '${userEvents[key]?['time']}' +
                                                                          "  |  " +
                                                                          getDateWordForm(
                                                                              '${userEvents[key]?['date']}'),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          // Expanded(
                                                          //   flex: 1,
                                                          //   child: IconButton(
                                                          //       icon: Icon(Icons
                                                          //           .more_vert),
                                                          //       onPressed: () {
                                                          //         Navigator.push(
                                                          //           context,
                                                          //           MaterialPageRoute(
                                                          //               builder:
                                                          //                   (context) =>
                                                          //                       DetailsPage(
                                                          //                         title: "Event Info",
                                                          //                         event: userEvents[key],
                                                          //                         eventKey: key,
                                                          //                       )),
                                                          //         ).then((value) {
                                                          //           getAllEvents();
                                                          //         });
                                                          //       }),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    DetailsPage(
                                                                      title:
                                                                          "Event Info",
                                                                      event: userEvents[
                                                                          key],
                                                                      eventKey:
                                                                          key,
                                                                    )),
                                                      ).then((value) {
                                                        getAllEvents();
                                                      });
                                                    });
                                              },
                                              separatorBuilder:
                                                  (BuildContext context,
                                                          int index) =>
                                                      const Divider(
                                                          color:
                                                              Colors.black26),
                                            )
                                          : // IF NO EVENTS MY EVENTS SECTION WILL SAY "NO EVENTS YET"
                                          Center(
                                              child: Container(
                                              alignment: Alignment.center,
                                              height: 100,
                                              child: Text("No Events Yet",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.grey)),
                                            ))),
                        ],
                      ),
                    ),
                  ),

                  // ALL EVENTS CONTAINER
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20, right: 10, left: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.white.withOpacity(.7),
                        //   boxShadow: [BoxShadow(
                        //       color: Colors.grey.withOpacity(.95),
                        //       spreadRadius: -4,
                        //       blurRadius: 7,
                        //       offset: Offset(0, 3)
                        //   ),],
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
                              title: Text("Upcoming Events",
                                  style: TextStyle(fontSize: 28)),
                              trailing: IconButton(
                                icon: collapseAll,
                                onPressed: () {
                                  setState(() {
                                    if (allEventsCollapsed == false) {
                                      allEventsCollapsed = true;
                                      collapseAll =
                                          Icon(Icons.arrow_left_outlined);
                                    } else {
                                      allEventsCollapsed = false;
                                      collapseAll =
                                          Icon(Icons.arrow_drop_down_outlined);
                                    }
                                  });
                                  saveCollapsedValues(
                                      user.info!['username'] +
                                          "/allEventsCollapsed",
                                      allEventsCollapsed);
                                },
                              )),

                          //IF ALL EVENTS IS COLLAPSED
                          allEventsCollapsed
                              ? SizedBox()
                              : //IF ALL EVENTS SECTION IS NOT COLLAPSED
                              // AND HAS MORE THAN 3 EVENTS --> MAKE IT LIMITED CONTAINER SIZE
                              allEvents.length > 3
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3.0,
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        physics: ScrollPhysics(),
                                        padding: const EdgeInsets.all(20),
                                        itemCount: allEvents.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          String key =
                                              allEvents.keys.elementAt(index);
                                          return InkWell(
                                            child: Container(
                                              height: 50,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 7,
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          flex: 7,
                                                          child: Column(
                                                            children: [
                                                              Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                          '${allEvents[key]?['name']}',
                                                                          style:
                                                                              TextStyle(fontSize: 20)),
                                                                      eventFull(allEvents[
                                                                              key]!)
                                                                          ? Text(
                                                                              " (FULL)",
                                                                              style: TextStyle(fontSize: 17))
                                                                          : oneSpotLeft(allEvents, key)
                                                                              ? Text(' (1 spot left)', style: TextStyle(fontSize: 14))
                                                                              : Text(' (${getEventLimit(allEvents[key]!) - getEventSpotsFilled(allEvents[key]!)} spots left)', style: TextStyle(fontSize: 14))
                                                                    ],
                                                                  )),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                    '${allEvents[key]?['time']}' +
                                                                        "  |  " +
                                                                        getDateWordForm(
                                                                            '${allEvents[key]?['date']}'),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  user.info!["role"] == "admin"
                                                      ? Expanded(
                                                          flex: 1,
                                                          child: IconButton(
                                                              icon: Icon(
                                                                  Icons.edit),
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              EditEventPage(
                                                                                title: "Edit Event",
                                                                                events: allEvents,
                                                                                eventKey: key,
                                                                              )),
                                                                ).then((value) {
                                                                  getAllEvents();
                                                                });
                                                              }),
                                                        )
                                                      : SizedBox(),
                                                  // Expanded(
                                                  //   flex: 1,
                                                  //   child: IconButton(
                                                  //       icon:
                                                  //       Icon(Icons.more_vert),
                                                  //       onPressed: () {
                                                  //         Navigator.push(
                                                  //           context,
                                                  //           MaterialPageRoute(
                                                  //               builder:
                                                  //                   (context) =>
                                                  //                   DetailsPage(
                                                  //                     title:
                                                  //                     "Event Info",
                                                  //                     event: allEvents[
                                                  //                     key],
                                                  //                     eventKey:
                                                  //                     key,
                                                  //                   )),
                                                  //         ).then((value) {
                                                  //           getAllEvents();
                                                  //         });
                                                  //       }),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailsPage(
                                                          title: "Event Info",
                                                          event: allEvents[key],
                                                          eventKey: key,
                                                        )),
                                              ).then((value) {
                                                getAllEvents();
                                              });
                                            },
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                const Divider(
                                                    color: Colors.black26),
                                      ))

                                  //IF THERE ARE 3 OR LESS EVENTS
                                  : Container(
                                      //change size of the box around event list
                                      child:

                                          // IF ALL EVENTS LIST ISN'T EMPTY
                                          allEvents.isNotEmpty
                                              ? ListView.separated(
                                                  shrinkWrap: true,
                                                  physics: ScrollPhysics(),
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  itemCount: allEvents.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    String key = allEvents.keys
                                                        .elementAt(index);
                                                    return InkWell(
                                                      child: Container(
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
                                                                    child:

                                                                        // IF THE EVENT IS FULL SHOW FULL
                                                                        eventFull(allEvents[key]!)
                                                                            ? Row(
                                                                                children: [
                                                                                  Text("${allEvents[key]!['name']}", style: TextStyle(fontSize: 22)),
                                                                                  Text(" (FULL)", style: TextStyle(fontSize: 17))
                                                                                ],
                                                                              )

                                                                            // IF EVENT IS NOT FULL, DISPLAY HOW MANY SPOTS ARE LEFT
                                                                            : Row(
                                                                                children: [
                                                                                  Text('${allEvents[key]!['name']}', style: TextStyle(fontSize: 22)),
                                                                                  oneSpotLeft(allEvents, key) ? Text(' (1 spot left)', style: TextStyle(fontSize: 14)) : Text(' (${getEventLimit(allEvents[key]!) - getEventSpotsFilled(allEvents[key]!)} spots left)', style: TextStyle(fontSize: 14)),
                                                                                ],
                                                                              ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                        '${allEvents[key]!['time']}' +
                                                                            "  |  " +
                                                                            getDateWordForm(
                                                                                '${allEvents[key]?['date']}'),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                13)),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            user.info!["role"] ==
                                                                    "admin"
                                                                ? Expanded(
                                                                    flex: 1,
                                                                    child: IconButton(
                                                                        icon: Icon(Icons.edit),
                                                                        onPressed: () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => EditEventPage(
                                                                                      title: "Edit Event",
                                                                                      events: allEvents,
                                                                                      eventKey: key,
                                                                                    )),
                                                                          ).then(
                                                                              (value) {
                                                                            getAllEvents();
                                                                          });
                                                                        }),
                                                                  )
                                                                : SizedBox(),
                                                            // Expanded(
                                                            //   flex: 1,
                                                            //   child: IconButton(
                                                            //       icon:
                                                            //           Icon(Icons.more_vert),
                                                            //       onPressed: () {
                                                            //         Navigator.push(
                                                            //           context,
                                                            //           MaterialPageRoute(
                                                            //               builder:
                                                            //                   (context) =>
                                                            //                       DetailsPage(
                                                            //                         title:
                                                            //                             "Event Info",
                                                            //                         event: allEvents[
                                                            //                             key],
                                                            //                         eventKey:
                                                            //                             key,
                                                            //                       )),
                                                            //         ).then((value) {
                                                            //           getAllEvents();
                                                            //         });
                                                            //       }),
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      DetailsPage(
                                                                        title:
                                                                            "Event Info",
                                                                        event: allEvents[
                                                                            key],
                                                                        eventKey:
                                                                            key,
                                                                      )),
                                                        ).then((value) {
                                                          getAllEvents();
                                                        });
                                                      },
                                                    );
                                                  },
                                                  separatorBuilder:
                                                      (BuildContext context,
                                                              int index) =>
                                                          const Divider(
                                                              color: Colors
                                                                  .black26),
                                                )
                                              : // IF NO EVENTS IN THE ALL EVENTS SECTION WILL SAY "NO EVENTS YET"
                                              Center(
                                                  child: Container(
                                                  alignment: Alignment.center,
                                                  height: 100,
                                                  child: Text("No Events Yet",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.grey)),
                                                )))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
