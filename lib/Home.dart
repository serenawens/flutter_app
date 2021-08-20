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

  @override
  Widget build(BuildContext context) {
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
                        child: Text("All Events", style: TextStyle(fontSize: 25)),
                      ),
                      ListView.separated(
                      shrinkWrap: true, physics: ScrollPhysics(),
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
                                          child:
                                              Text('${events[key]?['name']}', style: TextStyle(fontSize: 22))),
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
                                                    builder: (context) => EditEventPage(
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
                                              builder: (context) => DetailsPage(
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
                    ],
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true, physics: ScrollPhysics(),
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
                                  child:
                                  Text('${events[key]?['name']}', style: TextStyle(fontSize: 22))),
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
                                      builder: (context) => DetailsPage(
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
              ListView.separated(
                shrinkWrap: true, physics: ScrollPhysics(),
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
                                  child:
                                  Text('${events[key]?['name']}', style: TextStyle(fontSize: 22))),
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
                                      builder: (context) => DetailsPage(
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
            ],
          ),
        ),
      ),
    );
  }
}
