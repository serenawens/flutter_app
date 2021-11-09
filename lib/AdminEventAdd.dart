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

  void sortPastEvents() {

    // List eventKeysToArchive = [];
    // DateTime now = DateTime.now();
    // final DateFormat formatter = DateFormat('MM-dd-yyyy');

    database.get<Map<String, dynamic>>('Events').then((event) {
        String eventKey = "";
        Map<String, dynamic> eventInfo = event![eventKey];
        database.update('PastEvents/' + eventKey + "/", eventInfo);
        database.delete("Events/" + eventKey);
        moveVolunteerEventToPast(eventKey);

        // event.forEach((eventKey, eventInfo) {
        //   DateTime dt = formatter.parse(eventInfo['date']);
        //   print(dt);
        //
        //   if (dt.isBefore(now)) {
        //     print("true");
        //     //adding new list to the PASTEVENTS section
        //     database.update('PastEvents/' + eventKey + "/", eventInfo);
        //
        //     eventKeysToArchive.add(eventKey);
        //   }
        // });


        //removing from the normal EVENTS section
        //ALSO moves events in volunteer section

      //   print(eventKeysToArchive);
      //   eventKeysToArchive.forEach((key) {
      //     database.delete("Events/" + key);
      //
      //     moveVolunteerEventToPast(key);
      //   });
      //   _showDialog("Events successfully moved to past events", 'Success', returnOK());
      // }
      // else{
      //   print("No events to sort into Past events");
      //   _showDialog("No events to sort into past events", "No Events", returnOK());
      // }
    });
  }

  
  void moveVolunteerEventToPast(String theEventKey){
    database
        .get<Map<String, dynamic>>("PastEvents/" + theEventKey + "/volunteers/")
        .then((value) {
          print(value);
      value!.forEach((user, name) {
        database.update(
            "Users/" + user + "/pastEvents/" + theEventKey + '/', {"eventID": theEventKey});

        database.delete("Users/" + user + "/events/" + theEventKey);
        
      });
    });
  }

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

  bool showFAB() {
    if(user.info!['username'] == 'serenaw'){
      print("Show FAB");
      return true;
    }
    print("Don't show FAB");
    return false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: showFAB() == true?
      FloatingActionButton(
        onPressed: () {
          // print("Floating Action pressed");
          // moveVolunteerEventToPast("-MlmWRe2I3J_iVqAnSdj");
          sortPastEvents();
        },
        child: Icon(Icons.cleaning_services_outlined, color: Colors.black54),
      ):
          SizedBox(),
      backgroundColor: Colors.white,
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
