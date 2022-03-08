//source (serach bar): https://medium.com/codechai/a-simple-search-bar-in-flutter-f99aed68f523

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ManualAddVolunteers.dart';
import 'User.dart';
import 'cmdb.dart';

class VolunteerManagePage extends StatefulWidget {
  //Class Constructor
  VolunteerManagePage(
      {Key? key,
      required this.title,
      required this.eventKey,
      required this.volunteerLimit,
      required this.eventOfficerName})
      : super(key: key);

  //Class instance variable
  final String title;
  final String eventKey;
  final String volunteerLimit;
  final String eventOfficerName;

  @override
  _VolunteerManagePageState createState() => _VolunteerManagePageState();
}

class _VolunteerManagePageState extends State<VolunteerManagePage> {
  CMDB database = CMDB();
  User user = User();

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

  String formatPhoneNumber(String number) {
    String temp = number.trim();
    String prettify = '';

    if (temp.startsWith("+1") || temp.startsWith("*1")) {
      temp = temp.trim().substring(2);
    }

    for (int i = 0; i < temp.length; i++) {
      if (!(temp[i] == '+' ||
          temp[i] == '*' ||
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

  final TextEditingController _filter = new TextEditingController();

  String volunteerCount = "";

  String _searchText = "";
  Map<String, Map<String, String>> names = {}; // names we get from API

  Map<String, Map<String, String>> filteredNames =
      {}; // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget? _appBarTitle;

  _VolunteerManagePageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _appBarTitle = new Text(widget.title);
    _getNames();
  }

  String titleCase(String s) {
    return s
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> _getNames() async {
    Map<String, Map<String, String>> tempMap = {};

    database.get<Map<String, dynamic>>('Users').then((users) {
      users!.forEach((username, userInfo) {
        if (userInfo.containsKey('events') &&
            userInfo['events'].containsKey(widget.eventKey)) {
          if (widget.eventOfficerName == userInfo['name']) {
            tempMap[username] = {
              "name": titleCase(userInfo['name']),
              "username": userInfo['username'],
              'role': userInfo['role'],
              'isEventOfficer': 'true',
              "phoneNumber":
                  formatPhoneNumber(userInfo['phoneNumber'].toString())
            };
          } else {
            tempMap[username] = {
              "name": titleCase(userInfo['name']),
              "username": userInfo['username'],
              'role': userInfo['role'],
              "phoneNumber":
                  formatPhoneNumber(userInfo['phoneNumber'].toString())
            };
          }
        }
      });
      var sortedKeys = tempMap.keys.toList(growable: false)
        ..sort(
            (k1, k2) => tempMap[k1]!['name']!.compareTo(tempMap[k2]!['name']!));
      LinkedHashMap<String, Map<String, String>?> sortedMap =
          new LinkedHashMap<String, Map<String, String>?>.fromIterable(
              sortedKeys,
              key: (k) => k,
              value: (k) => tempMap[k]);
      print(sortedMap);

      setState(() {
        names = sortedMap as Map<String, Map<String, String>>;
        filteredNames = names;
        volunteerCount = filteredNames.length.toString();
      });
    });
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text(widget.title);
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  List<Widget> returnDeleteUserActions(String username) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              child: Text('Nevermind'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          ElevatedButton(
              child: Text('Confirm'),
              onPressed: () {

                database.delete("/Events/" +
                    widget.eventKey +
                    "/volunteers/" +
                    username +
                    "/");

                database.delete("/Users/" +
                    username +
                    "/events/" +
                    widget.eventKey +
                    "/");

                setState(() {
                  names.remove(username);
                  filteredNames = names;
                  volunteerCount = filteredNames.length.toString();

                });
                Navigator.of(context).pop();
              })
        ],
      ),
    ];
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      Map<String, Map<String, String>> tempMap = {};
      names.forEach((key, value) {
        if (names[key]!['name']!
            .toLowerCase()
            .contains(_searchText.toLowerCase())) tempMap[key] = names[key]!;
      });

      filteredNames = tempMap;
    }
    return ListView.separated(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        String username = filteredNames.keys.elementAt(index);
        return new ListTile(
          title: user.info!['username'] != username && filteredNames[username]!['isEventOfficer'] != 'true'
              ? Text(filteredNames[username]!['name']!,
                  style: TextStyle(fontSize: 20))
              : Row(
                  children: [
                    Text(filteredNames[username]!['name']!,
                        style: TextStyle(fontSize: 20)),
                    user.info!['username'] == username?
                    Text(" (you)",
                        style: TextStyle(color: Colors.grey, fontSize: 19)):
                        Text(" (EO)",
                            style: TextStyle(color: Colors.grey, fontSize: 19))
                  ],
                ),
          onTap: () {
            print(filteredNames[username]);
          },
          subtitle: Text(filteredNames[username]!['phoneNumber']!,
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
          trailing: user.info!['username'] == username ||
                  filteredNames[username]!['isEventOfficer'] == 'true'
              ? IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.grey,
                  ),
                )
              : IconButton(
                  color: Colors.redAccent,
                  onPressed: () {
                    _showDialog(
                        "Are you sure you want to delete " +
                            filteredNames[username]!['name']! +
                            " from this event?",
                        "Delete User",
                        returnDeleteUserActions(username));
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        thickness: 1,
        height: 3,
      ),
    );
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

    List<Widget> returnOKAction() {
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

    return Scaffold(
      appBar: AppBar(title: _appBarTitle, actions: [
        IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        ),
      ]),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Volunteers" +
                            " (${volunteerCount}/" +
                            widget.volunteerLimit +
                            ")",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
                Transform.translate(
                    offset: Offset(0, -3),
                    child: IconButton(
                        color: Colors.orange,
                        onPressed: () {
                          if (volunteerCount != widget.volunteerLimit) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddVolunteerPage(
                                    title: "Add Volunteers",
                                    eventKey: widget.eventKey,
                                    volunteerLimit: widget.volunteerLimit),
                              ),
                            ).then((value) {
                              _getNames();
                            });
                          } else {
                            _showDialog(
                                "This event is full, you can't add anymore volunteers",
                                "Event Full",
                                returnOKAction());
                          }
                        },
                        icon: Icon(Icons.add_circle_outlined)))
              ],
            ),
            Divider(
              thickness: 1,
              height: 3,
            ),
            _buildList(),
          ],
        ),
      ),
    );
  }
}
