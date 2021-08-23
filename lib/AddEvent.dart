import 'package:flutter/material.dart';
import 'package:simple_time_range_picker/simple_time_range_picker.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  //Class Constructor
  AddEventPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  TextEditingController eventName = TextEditingController();
  TextEditingController eventDate = TextEditingController();
  TextEditingController eventTime = TextEditingController();
  TextEditingController eventLocation = TextEditingController();
  TextEditingController eventDetails = TextEditingController();

  Map<String, Map<String, String>> addEvent() {
    Map<String, Map<String, String>> events = {
      "Volunteer Opportunity #4": {
        "name": eventName.text,
        'date': eventDate.text,
        'time': eventTime.text,
        'location': eventLocation.text,
        'details': eventDetails.text,
      }
    };
    return events;
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
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
                  'Enter New Event Info',
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
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.black45, width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.black45, width: 2.0),
                            ),
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
                                if (date.toString().length >= 10) {
                                  eventDate.text =
                                      date.toString().substring(0, 10);
                                }
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
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black45, width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black45, width: 2.0),
                            ),
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
                                    formatTimeOfDay(value.startTime) +
                                        " - " +
                                        formatTimeOfDay(value.endTime);
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
                    controller: eventDetails,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      labelText: 'Details',
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Text('Create Event', style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
