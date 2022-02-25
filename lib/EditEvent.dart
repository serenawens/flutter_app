import 'package:flutter/material.dart';
import 'package:simple_time_range_picker/simple_time_range_picker.dart';
import 'package:intl/intl.dart';

import 'cmdb.dart';

class EditEventPage extends StatefulWidget {
  //Class Constructor
  EditEventPage(
      {Key? key,
      required this.title,
      required this.events,
      required this.eventKey})
      : super(key: key);

  //Class instance variable
  final String title;

  Map<String, Map<String, dynamic>> events;

  String eventKey;

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  TextEditingController eventName = TextEditingController();
  TextEditingController eventDate = TextEditingController();
  TextEditingController eventTime = TextEditingController();
  TextEditingController eventLocation = TextEditingController();
  TextEditingController eventLimit = TextEditingController();
  TextEditingController eventDetails = TextEditingController();
  TextEditingController signUpLink = TextEditingController();

  void setEventValues() {
    eventName.text = widget.events[widget.eventKey]?["name"];
    eventDate.text = widget.events[widget.eventKey]?["date"];
    eventTime.text = widget.events[widget.eventKey]?["time"];
    eventLocation.text = widget.events[widget.eventKey]?["location"];
    eventLimit.text = widget.events[widget.eventKey]?["volunteerLimit"];
    eventDetails.text = widget.events[widget.eventKey]?["details"];
    if(widget.events[widget.eventKey]?["link"] != null){
      signUpLink.text = widget.events[widget.eventKey]?["link"];
    }
  }

  @override
  void initState() {
    super.initState();
    setEventValues();
  }

  Future<void> addEvent() async {
    widget.events[widget.eventKey]?["name"] = eventName.text.trim();
    widget.events[widget.eventKey]?["date"] = eventDate.text.trim();
    widget.events[widget.eventKey]?["time"] = eventTime.text.trim();
    widget.events[widget.eventKey]?["location"] = eventLocation.text.trim();
    widget.events[widget.eventKey]?["volunteerLimit"] = eventLimit.text.trim();
    widget.events[widget.eventKey]?["details"] = eventDetails.text.trim();
    widget.events[widget.eventKey]?["link"] = signUpLink.text.trim();
    widget.events[widget.eventKey]?['eventHours'] = calculateEventHours();
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  String timeOfDayToString(TimeOfDay tod) {
    String time = tod.toString();
    return time.substring(10, 15);
  }

  String calculateEventHours() {
    String eventTimeRange = eventTime.text;

    TimeOfDay st = stringToTimeOfDay(eventTimeRange.split(' - ')[0]);
    TimeOfDay et = stringToTimeOfDay(eventTimeRange.split(' - ')[1]);

    var format = DateFormat("HH:mm");
    var start = format.parse(timeOfDayToString(st));
    var end = format.parse(timeOfDayToString(et));

    double time = (end.difference(start).inMinutes)/60;

    if(time.truncate() == time){
      return time.truncate().toString();
    }
    else{
      return time.toStringAsFixed(1);
    }

  }

  CMDB database = CMDB();

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

  List<Widget> returnChangesError() {
    return [
      Center(
        child: ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
    ];
  }

  List<Widget> returnDeleteActions() {
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
              child: Text('Delete'),
              onPressed: () {
                Map pendingInvitations =
                    widget.events[widget.eventKey]?['pending'];
                Map volunteers = widget.events[widget.eventKey]?['volunteers'];

                //Transfer event to "deleted events" section
                Map tempEvents = widget.events;
                String tempKey = widget.eventKey;
                database.update('DeletedEvents/' + tempKey + '/', tempEvents[tempKey]);

                if (pendingInvitations != null) {
                  //Remove the event from all member "pending" lists
                  pendingInvitations.forEach((users, value) {
                    database.delete(
                        "Users/" + users + "/pending/" + widget.eventKey);
                  });
                }

                print(volunteers != null);
                if (volunteers != null) {
                  print(volunteers);
                  //Remove the event from all member event lists
                  volunteers.forEach((users, value) {
                    database.delete(
                        "Users/" + users + "/events/" + widget.eventKey);
                  });
                }

                //Remove the event from the Event section
                database.delete("Events/" + widget.eventKey).then((value) {
                  widget.events.remove(widget.eventKey);
                  print(value);

                  setState(() {});
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                });
              })
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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Edit Event Info',
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: eventName,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Event Name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: TextField(
                          obscureText: false,
                          readOnly: true,
                          controller: eventDate,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Date',
                            labelStyle: new TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () {
                            showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2035))
                                .then((date) {
                              setState(() {
                                final DateFormat formatter =
                                DateFormat('MM-dd-yyyy');
                                eventDate.text = formatter.format(date!);

                                // if (date.toString().length >= 10) {
                                //   eventDate.text =
                                //       date.toString().substring(0, 10);
                                // }
                              });
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: eventTime,
                          obscureText: false,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Event Time',
                            labelStyle: new TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(Icons.more_time),
                          onPressed: () => TimeRangePicker.show(
                            context: context,
                            unSelectedEmpty: false,
                            startTime: TimeOfDay(hour: 19, minute: 45),
                            endTime: TimeOfDay(hour: 21, minute: 22),
                            onSubmitted: (TimeRangeValue value) {
                              setState(() {
                                eventTime.text =
                                    formatTimeOfDay(value.startTime!) +
                                        " - " +
                                        formatTimeOfDay(value.endTime!);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: eventLocation,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Event Location',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: eventLimit,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Volunteer Limit',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: eventDetails,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      labelText: 'Details',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: signUpLink,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      labelText: 'Sign Up Link (optional)',
                    ),
                  ),
                ),
                SizedBox(height:10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        child: Text("Delete Event",
                            style: TextStyle(fontSize: 20)),
                        onPressed: () {
                          print("Going to show dialog");
                          _showDialog(
                              "Are you sure you want to delete this event?",
                              "Delete Event",
                              returnDeleteActions());
                        }),
                    ElevatedButton(
                      child:
                          Text('Save Changes', style: TextStyle(fontSize: 20)),
                      onPressed: () {

                        if (eventName.text.isEmpty ||
                            eventDate.text.isEmpty ||
                            eventTime.text.isEmpty ||
                            eventLocation.text.isEmpty ||
                            eventLimit.text.isEmpty||
                            eventDetails.text.isEmpty) {
                          _showDialog("All fields must be filled out",
                              "Missing Information", returnChangesError());
                        } else {
                          addEvent().then((value) {
                            database.update("Events/" + widget.eventKey + "/",
                                widget.events[widget.eventKey]!);
                            Navigator.pop(context);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
