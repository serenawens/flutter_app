import 'package:flutter/material.dart';
import 'package:simple_time_range_picker/simple_time_range_picker.dart';
import 'package:intl/intl.dart';

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
  TextEditingController eventDetails = TextEditingController();

  void setEventValues() {
    eventName.text = widget.events[widget.eventKey]?["name"];
    eventDate.text = widget.events[widget.eventKey]?["date"];
    eventTime.text = widget.events[widget.eventKey]?["time"];
    eventLocation.text = widget.events[widget.eventKey]?["location"];
    eventDetails.text = widget.events[widget.eventKey]?["details"];
  }

  @override
  void initState() {
    super.initState();
    setEventValues();
  }

  Future<void> addEvent() async {
    widget.events[widget.eventKey]?["name"] = eventName.text;
    widget.events[widget.eventKey]?["date"] = eventDate.text;
    widget.events[widget.eventKey]?["time"] = eventTime.text;
    widget.events[widget.eventKey]?["location"] = eventLocation.text;
    widget.events[widget.eventKey]?["details"] = eventDetails.text;
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
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      side: BorderSide(color: Colors.black45)),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: TextField(
                            obscureText: false,
                            enabled: false,
                            controller: eventDate,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        side: BorderSide(color: Colors.black45)),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: eventTime,
                              obscureText: false,
                              enabled: false,
                              decoration: InputDecoration(
                                disabledBorder: InputBorder.none,
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
                  child: Text('Save Changes', style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    if (eventName.text == null ||
                        eventDate.text == null ||
                        eventTime.text == null ||
                        eventLocation.text == null ||
                        eventDetails.text == null) {
                      Navigator.pop(context);
                    } else {
                      addEvent().then(
                          (value) => Navigator.pop(context, widget.events));
                    }
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
