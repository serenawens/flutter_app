//source (serach bar): https://medium.com/codechai/a-simple-search-bar-in-flutter-f99aed68f523

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'User.dart';
import 'cmdb.dart';

class AddVolunteerPage extends StatefulWidget {
  //Class Constructor
  AddVolunteerPage({Key? key, required this.title, required this.eventKey, required this.volunteerLimit})
      : super(key: key);

  //Class instance variable
  final String title;

  final String eventKey;

  final String volunteerLimit;

  @override
  _AddVolunteerPageState createState() => _AddVolunteerPageState();
}

class _AddVolunteerPageState extends State<AddVolunteerPage> {
  CMDB database = CMDB();
  User user = User();

  String volunteerCount = "";

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

  List<Widget> returnAddVolunteerActions(String username) {
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
              child: Text('Yes, Add'),
              onPressed: () {
                database.update(
                    "Events/" +
                        widget.eventKey +
                        "/volunteers/" +
                        username +
                        "/",
                    {
                      "name":
                      filteredNames[username]!['name']!.toLowerCase()
                    });

                //Adding event to your events in database
                database.update(
                    "Users/" +
                        username +
                        "/events/" +
                        widget.eventKey +
                        '/',
                    {"eventID": widget.eventKey});

                //Delete the event from your pending events list
                database.delete("Users/" +
                    username +
                    "/pending/" +
                    widget.eventKey +
                    "/");

                //Delete your name off the event database pending list
                database.delete("Events/" +
                    widget.eventKey +
                    "/pending/" +
                    username);

                setState(() {
                  names.remove(username);
                  filteredNames = names;
                  getVolunteerCount();
                });
                Navigator.of(context).pop();
              })
        ],
      ),
    ];
  }

  final TextEditingController _filter = new TextEditingController();

  String _searchText = "";
  Map<String, Map<String, String>> names = {}; // names we get from API

  Map<String, Map<String, String>> filteredNames =
  {}; // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget? _appBarTitle;

  _AddVolunteerPageState() {
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
    getVolunteerCount();
  }

  String titleCase(String s) {
    return s
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> getVolunteerCount() async {

    database.get<Map<String,dynamic>>("Events/" + widget.eventKey + "/volunteers").then((value) {
      
      volunteerCount = value!.keys.length.toString();
    });

  }

  Future<void> _getNames() async {

    Map<String, Map<String, String>> tempMap = {};

    database.get<Map<String, dynamic>>('Users').then((users) {
      users!.forEach((username, userInfo) {

          if (!users[username].containsKey('events') ||
              (users[username].containsKey('events') &&
                  !users[username]['events'].containsKey(widget.eventKey))) {

            if(username == user.info!['username']){
              print("dont add me");
            } else{
              tempMap[username] = {
                'username': userInfo['username'],
                'name': titleCase(userInfo['name'])
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
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        String username = filteredNames.keys.elementAt(index);
        return new ListTile(
          title: Text(filteredNames[username]!['name']!),
          onTap: () => print(filteredNames[username]),
          trailing:  volunteerCount != widget.volunteerLimit?
          ElevatedButton(
            onPressed: () {

              if(volunteerCount != widget.volunteerLimit){

                _showDialog("Add this person", 'Add Volunteer Confirmation', returnAddVolunteerActions(username));
              }
              else{
                _showDialog("Event is full", "Can't Add", returnOKAction());
              }

            },
            child: Text('Add'),
          ):
              ElevatedButton(
                onPressed: null, child: Text("Add"),
              ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _appBarTitle, actions: [
        IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        ),
      ]),
      backgroundColor: Colors.white,
      body: _buildList(),
    );
  }
}
