import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/InvitationView.dart';
import 'package:intl/intl.dart';
import 'User.dart';
import 'cmdb.dart';
import 'package:url_launcher/url_launcher.dart';

class PastDetailsPage extends StatefulWidget {
  //Class Constructor
  PastDetailsPage(
      {Key? key,
        required this.title,
        required this.event,
        required this.eventKey})
      : super(key: key);

  //Class instance variable
  final String title;

  final Map<String, dynamic>? event;

  final String eventKey;

  @override
  _PastDetailsPageState createState() => _PastDetailsPageState();
}

class _PastDetailsPageState extends State<PastDetailsPage> {
  bool joinedEvent = false;
  User user = User();
  CMDB database = CMDB();
  List volunteerList = [];
  String eventOfficer = "";
  bool hasEventOfficer = false;
  bool isEventOfficer = false;
  String eventOfficerPhone = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVolunteers();
  }

  final ScrollController _controllerOne = ScrollController(initialScrollOffset: 50.0);

  String formatPhoneNumber(String number) {
    String temp = number.trim();
    String prettify = '';

    if (temp.startsWith("+1") || temp.startsWith("*1")) {
      temp = temp.trim().substring(2);
    }

    for (int i = 0; i < temp.length; i++) {
      if (!(temp[i] == '+' ||
          temp[i] == '*'||
          temp[i] == ' ' ||
          temp[i] == '-' ||
          temp[i] == '(' ||
          temp[i] == ')')) {
        prettify += temp[i];
      }
    }
    print(prettify);

    return "(" +
        prettify.substring(0, 3) +
        ")" +
        " " +
        prettify.substring(3, 6) +
        "-" +
        prettify.substring(6);
  }

  String getDateWordForm(String date) {
    final DateFormat formatter = DateFormat('MM-dd-yyyy');
    DateTime dt = formatter.parse(date);
    int weekday = dt.weekday;
    int month = dt.month;
    int day = dt.day;

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
    return (strWeekday + ", " + strMonth + " " + day.toString());
  }

  String titleCase(String s) {
    if (s == '') {
      return s;
    }
    return s
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  bool flag = false;

  void getVolunteers() {
    database
        .get<Map<String, dynamic>>("PastEvents/" + widget.eventKey + "/volunteers/")
        .then((value) {
      flag = true;
      setState(() {});
      if (value != null) {
        setState(() {
          value.forEach((key, info) {
            //Current user is a volunteer
            if (user.info!['name'] == info['name']) {
              joinedEvent = true;
            }

            //Volunteer is not an event officer
            if (info['eventOfficer'] == null) {
              volunteerList.add(info['name']);
            }
            //Volunteer IS an event officer
            else if (info['eventOfficer'] != null) {
              //Current user is that volunteer
              if (user.info!['name'] == info['name']) {
                isEventOfficer = true;
              }
              eventOfficer = info['name'];
              hasEventOfficer = true;
            }
          });
        });
      }
    });

    if (widget.event!['hasEventOfficer'] != null) {
      String username = widget.event!['hasEventOfficer']['true'];
      database
          .get<Map<String, dynamic>>("Users/" + username + '/')
          .then((userInfo) {
        setState(() {
          if (userInfo != null) {
            eventOfficerPhone = formatPhoneNumber(userInfo['phoneNumber']);
          }
        });
      });
    }
  }

  SizedBox getEventOfficerInfo() {
    return SizedBox(
        height: 45,
        child: Column(
          children: [
            SelectableText(titleCase(eventOfficer)),
            SizedBox(height: 4),
            SelectableText(eventOfficerPhone),
          ],
        ));
  }

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

    void _showDiffDialog(Widget message) {
      showDialog(
          context: context,
          builder: (BuildContext) {
            return AlertDialog(
              content: message,
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: flag
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                title: SelectableText(titleCase(widget.event?["name"]),
                    style: TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold)),
                subtitle: SelectableText(
                    "\n" +
                        getDateWordForm(widget.event?["date"]) +
                        "\n" +
                        widget.event?['time'],
                    style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Location:",
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold))),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                          titleCase(widget.event?['location']),
                          style: TextStyle(
                              fontSize: 19, color: Colors.black87)))),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Details:",
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold))),
              ),
              Padding(
                  padding:
                  const EdgeInsets.only(left: 18, right: 18, top: 3),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(widget.event?['details'],
                          style: TextStyle(
                              fontSize: 17, color: Colors.black87)))),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      hasEventOfficer?
                      Text("Event Officer: ",
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)):
                          SizedBox(),

                      hasEventOfficer?
                      Text("${titleCase(eventOfficer)}",
                          style: TextStyle(fontSize: 17)):
                          SizedBox(),

                      widget.event!['hasEventOfficer'] != null
                          ? Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: TextButton(
                            onPressed: () {
                              _showDiffDialog(
                                  getEventOfficerInfo());
                            },
                            child: Text("[Contact Info]",
                                style: TextStyle())),
                      )
                          : SizedBox()
                      // IconButton(onPressed: (){
                      // }, icon: Icon(Icons.info_outlined, size: 18))
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Volunteers:",
                    style: TextStyle(
                        fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 5),
              volunteerList.length < 7?
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: SizedBox(
                  child: ListView.builder(
                      itemCount: volunteerList.length,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Text(
                            titleCase('- ${volunteerList[index]}'),
                            style: TextStyle(fontSize: 16));
                      }),
                ),
              ):
              Padding(
                padding: const EdgeInsets.only(left: 8, right:8),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                       BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        spreadRadius: -2,
                        blurRadius: 1,
                        offset: Offset(0,-1)
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 22-8, top: 8),
                    child: SizedBox(
                      child: ListView.builder(
                          itemCount: volunteerList.length,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Text(
                                titleCase('- ${volunteerList[index]}'),
                                style: TextStyle(fontSize: 16));
                          }),
                    ),
                  ),
                ),
              ),
                SizedBox(height: 20),
            ],
          )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
