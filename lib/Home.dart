import 'package:flutter/material.dart';
import 'package:flutter_app/Details.dart';
import 'EditEvent.dart';

class HomePage extends StatefulWidget {
  //Class Constructor
  HomePage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, Map<String, dynamic>> events = {
    "Volunteer Opportunity #1": {
      "name": 'event #1',
      'date': '8/19/21',
      'time': '3:00 PM',
      'location': 'Park',
      'details': 'some details',
      "volunteers": ['serena', 'bob', 'joe']
    },
    "Volunteer Opportunity #2": {
      "name": 'event #2',
      'date': '8/20/21',
      'time': '2:30 pm',
      'location': 'LC',
      'details': 'some details',
      "volunteers": ['serena', 'bob', 'joe']
    },
    "Volunteer Opportunity #3": {
      "name": 'event #3',
      'date': '8/21/21',
      'time': '12:00 pm',
      'location': 'Second Harvest',
      'details': 'some details',
      "volunteers": ['serena', 'bob', 'joe']
    },
    "Volunteer Opportunity #4": {
      "name": 'Food Sorting',
      'date': '8/21/21',
      'time': '12:00 pm',
      'location': 'Second Harvest',
      'details': ' details',
      "volunteers": ['serena', 'bob', 'john']
    }
  };

  String role = "Admin";

  bool allEventsCollapsed = false;
  Icon collapse = Icon(Icons.arrow_drop_down_outlined);

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
                padding: const EdgeInsets.all(8),
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: ListTile(
                            title: Text("All Events",
                                style: TextStyle(fontSize: 25)),
                            trailing: IconButton(
                              icon: collapse,
                              onPressed: () {
                                setState(() {
                                  if (allEventsCollapsed == false) {
                                    allEventsCollapsed = true;
                                    collapse =
                                        Icon(Icons.arrow_drop_down_outlined);
                                  }
                                  else {
                                    allEventsCollapsed = false;
                                    collapse =
                                        Icon(Icons.arrow_left_outlined);
                                  }
                                }
                                );
                              },
                            )),
                      ),
                      allEventsCollapsed?
                      SizedBox():
                      Container(
                        //change size of the box around event list
                        height: MediaQuery.of(context).size.height / 3.5,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: events.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key = events.keys.elementAt(index);
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
                                                '${events[key]?['name']}',
                                                style:
                                                    TextStyle(fontSize: 22))),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${events[key]?['time']}' +
                                                  "  |  " +
                                                  '${events[key]?['date']}',
                                              style: TextStyle(fontSize: 17)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  role == "Admin"
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
                                                            title: "Edit Event",
                                                            events: events,
                                                            eventKey: key,
                                                          )),
                                                ).then((value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      events = value;
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailsPage(
                                                      title: "Event Info",
                                                      event: events[key],
                                                    )),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(color: Colors.black26),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Text("Your Events", style: TextStyle(fontSize: 25)),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 3,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: events.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key = events.keys.elementAt(index);
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
                                                '${events[key]?['name']}',
                                                style:
                                                    TextStyle(fontSize: 22))),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${events[key]?['time']}' +
                                                  "  |  " +
                                                  '${events[key]?['date']}',
                                              style: TextStyle(fontSize: 17)),
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
                                                      event: events[key],
                                                    )),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(color: Colors.black26),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Pending Invites",
                            style: TextStyle(fontSize: 25)),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 3,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: events.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key = events.keys.elementAt(index);
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
                                                '${events[key]?['name']}',
                                                style:
                                                    TextStyle(fontSize: 22))),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${events[key]?['time']}' +
                                                  "  |  " +
                                                  '${events[key]?['date']}',
                                              style: TextStyle(fontSize: 17)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      flex: 3,
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
                                        icon: Icon(Icons.more_vert),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailsPage(
                                                      title: "Event Info",
                                                      event: events[key],
                                                    )),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
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
