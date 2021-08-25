import 'package:flutter/material.dart';
import 'package:flutter_app/Details.dart';
import 'EditEvent.dart';
import "User.dart";
import 'cmdb.dart';

class HomePage extends StatefulWidget {
  //Class Constructor
  HomePage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    getAllEvents();
  }

  User user = new User();
  CMDB database = new CMDB();

  Future<void> getAllEvents() async {
    database.get<Map<String, dynamic>>('Events').then((value) {
      setState(() {
        value!.forEach((key, value) {
          allEvents[key] = value as Map<String, dynamic>;
        });
      });
    });
  }

  Map<String, Map<String, dynamic>> allEvents = {};
  Map<String, Map<String, dynamic>> userEvents = {};
  Map<String, Map<String, dynamic>> pendingInvites = {};

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
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                    border: Border.all(
                      width: 3,
                      color: Colors.green,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                          title: Text("All Events",
                              style: TextStyle(fontSize: 28)),
                          trailing: IconButton(
                            icon: collapse,
                            onPressed: () {
                              setState(() {
                                if (allEventsCollapsed == false) {
                                  allEventsCollapsed = true;
                                  collapse = Icon(Icons.arrow_left_outlined);
                                } else {
                                  allEventsCollapsed = false;
                                  collapse =
                                      Icon(Icons.arrow_drop_down_outlined);
                                }
                              });
                            },
                          )),
                      allEventsCollapsed
                          ? SizedBox()
                          : Container(
                              //change size of the box around event list
                              height: MediaQuery.of(context).size.height / 3.5,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                padding: const EdgeInsets.all(20),
                                itemCount: allEvents.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String key = allEvents.keys.elementAt(index);
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
                                                      '${allEvents[key]?['name']}',
                                                      style: TextStyle(
                                                          fontSize: 24))),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    '${allEvents[key]?['time']}' +
                                                        "  |  " +
                                                        '${allEvents[key]?['date']}',
                                                    style: TextStyle(
                                                        fontSize: 15)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        user.info!["role"] == "admin"
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
                                                                  title:
                                                                      "Edit Event",
                                                                  events:
                                                                      allEvents,
                                                                  eventKey: key,
                                                                )),
                                                      ).then((value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            allEvents = value;
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
                                                print(key);
                                                print(allEvents);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailsPage(
                                                            title: "Event Info",
                                                            event:
                                                                allEvents[key],
                                                            eventKey: key,
                                                          )),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
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
                          itemCount: userEvents.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key = userEvents.keys.elementAt(index);
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
                                                '${userEvents[key]?['name']}',
                                                style:
                                                    TextStyle(fontSize: 22))),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${userEvents[key]?['time']}' +
                                                  "  |  " +
                                                  '${userEvents[key]?['date']}',
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
                                                      event: userEvents[key],
                                                      eventKey: key,
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
                          itemCount: pendingInvites.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key = pendingInvites.keys.elementAt(index);
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
                                                '${pendingInvites[key]?['name']}',
                                                style:
                                                    TextStyle(fontSize: 22))),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${pendingInvites[key]?['time']}' +
                                                  "  |  " +
                                                  '${pendingInvites[key]?['date']}',
                                              style: TextStyle(fontSize: 17)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Expanded(
                                  //     flex: 3,
                                  //     child: OutlinedButton(
                                  //       style: OutlinedButton.styleFrom(
                                  //           side: BorderSide(
                                  //               color: Colors.orange)),
                                  //       child: Text("ACCEPT"),
                                  //       onPressed: () {
                                  //         setState(() {
                                  //           _showDialog(
                                  //               "Do you want to accept event invite?",
                                  //               "Sign Up Confirmation",
                                  //               returnJoinActions());
                                  //         }
                                  //             //REMOVE EVENT FROM PENDING + ADD TO 'YOUR EVENTS'
                                  //             );
                                  //       },
                                  //     )),
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
                                                      event:
                                                          pendingInvites[key],
                                                      eventKey: key,
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
