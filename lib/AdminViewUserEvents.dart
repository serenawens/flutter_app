import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_app/Details.dart';
import 'package:intl/intl.dart';

import 'PastEventDetails.dart';
import 'User.dart';
import 'cmdb.dart';

import 'package:crypt/crypt.dart';

class AdminViewUserEventsPage extends StatefulWidget {
  //Class Constructor
  AdminViewUserEventsPage({Key? key, required this.title, required this.username}) : super(key: key);

  //Class instance variable
  final String title;

  final String username;

  @override
  _AdminViewUserEventsPageState createState() => _AdminViewUserEventsPageState();
}

class _AdminViewUserEventsPageState extends State<AdminViewUserEventsPage> {
  User user = new User();
  CMDB database = new CMDB();

  bool isDone = false;

  Map<String, Map<String, dynamic>> allPastEvents = {};
  Map<String, Map<String, dynamic>> pastEvents = {};

  Map<String, String> eventsAndHours = {};


  @override
  initState() {
    super.initState();
    getAllPastEvents();
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

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  Map<String, Map<String, dynamic>> sortEvents(
      Map<String, Map<String, dynamic>> events) {

    // List dateListBefore = [];
    //
    // events.keys.forEach((eventKey) {
    //   String date = events[eventKey]!['date'];
    //
    //   dateListBefore.add(date);
    //
    // });
    // print(dateListBefore);
    // print("");

    events.keys.forEach((eventKey) {
      String date = events[eventKey]!['date'];
      String temp = "03-21-2022";
      date = date.substring(6) + "-"+ date.substring(0,5);

      // date = date.substring(3,6) + date.substring(0,3) + date.substring(6);
      // print(date);

      events[eventKey]!['date'] = date;
    });

    var sortedKeys = events.keys.toList(growable: false)
      ..sort((k1, k2) => events[k1]!['date']!.compareTo(events[k2]!['date']!));

    LinkedHashMap<String, Map<String, dynamic>?> sortedMap =
    new LinkedHashMap<String, Map<String, dynamic>?>.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => events[k]);


    events.keys.forEach((eventKey) {
      String date = events[eventKey]!['date'];
      String temp = "2022-03-21";
      date = date.substring(5) + "-" + date.substring(0,4);

      // date = date.substring(3,6) + date.substring(0,3) + date.substring(6);

      events[eventKey]!['date'] = date;
    });

    // List dateListAfter = [];
    //
    // events.keys.forEach((eventKey) {
    //   String date = events[eventKey]!['date'];
    //
    //   dateListAfter.add(date);
    //
    // });
    // print(dateListAfter);
    // print("");


    return sortedMap as Map<String, Map<String, dynamic>>;
  }

  void getAllPastEvents() async {

    database.get<Map<String, dynamic>>('PastEvents').then((value) {
      if (value != null) {
        setState(() {
          allPastEvents = {};
          value.forEach((key, value) {
            allPastEvents[key] = value as Map<String, dynamic>;
          });
          // allPastEvents = sortEvents(allPastEvents);
          getUserPastEvents();
          isDone = true;
        });
      } else {
        setState(() {
          isDone = true;
        });
      }
    });
  }

  Future<void> getUserPastEvents() async {
    isDone = false;
    database
        .get<Map<String, dynamic>>(
        'Users/' + widget.username + "/pastEvents/")
        .then((invites) {
      if (invites != null) {
        setState(() {
          pastEvents = {};
          invites.forEach((eventkey, userEventInfo) {
            pastEvents[eventkey] = allPastEvents[eventkey]!;
          });
        });
        pastEvents = sortEvents(pastEvents);
        setEventHours();
      } else {
        setState(() {
          isDone = true;
        });
      }
    });
  }

  void setEventHours(){

    setState(() {
      pastEvents.forEach((eventKey, eventInfo){

        eventsAndHours[eventKey] = eventInfo['eventHours'];

      });

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
    int year = dt.year;

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
    return (strMonth + " " + day.toString() + ", " + year.toString() + " - " + strWeekday);
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  String timeOfDayToString(TimeOfDay tod) {
    String time = tod.toString();
    return time.substring(10, 15);
  }



  //Unused, only for mass calculation of event hours
  void doStuff(String eventKey) {
    database
        .get<Map<String, dynamic>>("Events/" + eventKey + "/")
        .then((eventInfo) {
      String eventTimeRange = eventInfo!['time'];

      String eventHours = calculateEventHours(eventTimeRange);

      eventInfo['eventHours'] = eventHours;

      database.update("Events/" + eventKey + "/", eventInfo);
    });
  }

  //Unused
  String calculateEventHours(String eventTimeRange) {

    TimeOfDay st = stringToTimeOfDay(eventTimeRange.split(' - ')[0]);
    TimeOfDay et = stringToTimeOfDay(eventTimeRange.split(' - ')[1]);

    var format = DateFormat("HH:mm");
    var start = format.parse(timeOfDayToString(st));
    var end = format.parse(timeOfDayToString(et));

    double eventHours = (end.difference(start).inMinutes)/60;
    print(eventHours);

    if(eventHours.truncate() == eventHours){
      return eventHours.truncate().toString();
    }
    else{
      return eventHours.toStringAsFixed(1);
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
      //   database.get<Map<String, dynamic>>("Events/").then((pastList) {
      //     if (pastList != null) {
      //       print('doing something');
      //       pastList.keys.forEach((eventKey) {
      //         doStuff(eventKey);
      //       });
      //     }
      //   });
      //
      // }),

      backgroundColor: Colors.white,
      body: isDone
          ? ListView.separated(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemCount: pastEvents.length,
        itemBuilder: (BuildContext context, int index) {
          String key = pastEvents.keys.elementAt(index);
          return InkWell(
              child: Container(
                height: 60,
                child: ListTile(
                    leading: Container(
                        height: 50,
                        // width: MediaQuery.of(context).size.width /
                        //     7.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("${eventsAndHours[key]}",
                                style: TextStyle(fontSize: 25, color: Colors.orange, fontWeight: FontWeight.bold)),
                            Text("hours",
                                style: TextStyle(fontSize: 11, color: Colors.orange,)),
                          ],
                        )),
                    title: Text('${pastEvents[key]?['name']}',
                        style: TextStyle(fontSize: 22)),
                    subtitle: Text(
                        getDateWordForm(
                            '${pastEvents[key]?['date']}'),
                        style: TextStyle(fontSize: 14)),
                    trailing: Icon(Icons.more_vert)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PastDetailsPage(
                        title: "Event Info",
                        event: pastEvents[key],
                        eventKey: key,
                      )),
                ).then((value) {
                  getAllPastEvents();
                });
              });
        },
        separatorBuilder: (BuildContext context, int index) =>
        const Divider(color: Colors.black26),
      )

          : Center(child: CircularProgressIndicator()),
    );
  }
}

// UNDER CONSTRUCTION
// Padding(
//   padding: const EdgeInsets.only(bottom: 90),
//   child: Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: <Widget>[
//       Text('Page Under', style: TextStyle(fontSize: 35, color: Colors.black54, fontStyle: FontStyle.italic)),
//       Text('Construction', style: TextStyle(fontSize: 35, color: Colors.black54, fontStyle: FontStyle.italic)),
//       IconButton(icon: Icon(Icons.construction_rounded), iconSize: 40, color: Colors.black54, onPressed: () {  },)
//     ],
//   ),
// ),
