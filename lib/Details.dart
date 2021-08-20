import 'package:flutter/material.dart';
import 'package:flutter_app/InvitationView.dart';

class DetailsPage extends StatefulWidget {
  //Class Constructor
  DetailsPage({Key? key, required this.title, required this.event})
      : super(key: key);

  //Class instance variable
  final String title;

  final Map<String, dynamic>? event;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool joinedEvent = false;

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
        ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        ElevatedButton(
            child: Text('Confirm Sign Up'),
            onPressed: () {
              joinedEvent = true;
              widget.event?['volunteers'].add("New Member Name");
              setState(() {
              });
              Navigator.of(context).pop();
            })
      ];
    }

    List<Widget> returnCancelActions() {
      return [
        ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        ElevatedButton(
            child: Text('Confirm'),
            onPressed: () {
              joinedEvent = false;
              widget.event?['volunteers']
                  .remove("New Member Name");
              setState(() {
              });
              Navigator.of(context).pop();
            })
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                title:
                    Text(widget.event?["name"], style: TextStyle(fontSize: 50)),
                subtitle: Text(
                    widget.event?["date"] +
                        " " +
                        widget.event?['time'] +
                        "\n" +
                        widget.event?['location'],
                    style: TextStyle(fontSize: 20)),
              ),
              ListTile(
                title: Text(widget.event?['details']),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 170),
                child: Text(
                  "Members Signed Up: ",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ListView.builder(
                    itemCount: widget.event?['volunteers'].length,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Text('${widget.event?['volunteers'][index]}',
                          style: TextStyle(fontSize: 15));
                    }),
              ),
              SizedBox(height: 20),
              joinedEvent == false
                  ? ElevatedButton(
                      child: Text('Join Event'),
                      onPressed: () {
                        setState(() {
                          _showDialog("Confirm your sign up?",
                              "Sign Up Confirmation", returnJoinActions());
                        });
                        //Add name to event
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            child: Text('Invite Friends'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InvitationPage(
                                        title: "Invite a Friend")),
                              );
                            },
                          ),
                          ElevatedButton(
                            child: Text('Cancel Sign Up'),
                            onPressed: () {
                              setState(() {
                                _showDialog("Are you sure you want to cancel your sign up?",
                                    "Cancel Confirmation", returnCancelActions());

                              });
                            },
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
