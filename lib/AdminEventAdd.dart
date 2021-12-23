import 'package:flutter/material.dart';
import 'package:flutter_app/AddEvent.dart';
import 'package:intl/intl.dart';

import 'User.dart';
import 'cmdb.dart';

class AdminEventPage extends StatefulWidget {
  //Class Constructor
  AdminEventPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _AdminEventPageState createState() => _AdminEventPageState();
}

class _AdminEventPageState extends State<AdminEventPage> {
  CMDB database = CMDB();
  User user = new User();

  void checkEventVolunteersAndUpdateUsers(String theEventKey) {
    database
        .get<Map<String, dynamic>>("Events/" + theEventKey + "/volunteers/")
        .then((value) {
      value!.forEach((user, name) {
        database.update("Users/" + user + "/events/" + theEventKey + '/',
            {"eventID": theEventKey});
      });
    });
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

  List<Widget> returnOK() {
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

  void moveVolunteerEventToPastFromPastEvents(String eventKey){

    //Move volunteer-related stuff to PAST EVENTS
    database
        .get<Map<String, dynamic>>(
        "PastEvents/" + eventKey + "/volunteers/")
        .then((value) {

      if (value != null) {

        print("YES VOLUNTEERS");

        value.forEach((user, name) {
          database.update(
              "Users/" + user + "/pastEvents/" + eventKey + '/',
              {"eventID": eventKey});

          database.delete("Users/" + user + "/events/" + eventKey);

          // database.get<Map<String,dynamic>>("Users/" + user + "statistics/").then((userStats) {
          //
          //   if(userStats != null){
          //
          //     print('yes user stats');
          //
          //     int newUserHours = int.parse(userStats['totalHours']) + eventHours;
          //     int newEventCount = int.parse(userStats['eventCount']) + 1;
          //
          //     database.update("Users/" + user + "/statistics", {
          //       "totalHours": newUserHours.toString(),
          //       'eventCount': newEventCount.toString()
          //     });
          //   }
          //
          //   else{
          //     print('no userstats? ERROR');
          //   }
          //
          // });

        });
      }
      else{
        // value!.forEach((user, name) {
        //   database.update(
        //       "Users/" + user + "/pastEvents/" + eventKey + '/',
        //       {"eventID": eventKey});
        //
        //   database.delete("Users/" + user + "/events/" + eventKey);
        //
        // });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //
      //   onPressed: () {
      //   moveVolunteerEventToPastFromPastEvents("-MpiXZZKSX5uwQgRoefR");
      // },
      //
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Add Volunteering', style: TextStyle(fontSize: 35)),
            Text('Event', style: TextStyle(fontSize: 35)),
            SizedBox(height: 30),
            RawMaterialButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddEventPage(title: 'Create Event')));
              },
              fillColor: Colors.orangeAccent,
              child: Icon(Icons.add, size: 30.0),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            ),
          ],
        ),
      ),
    );
  }
}
