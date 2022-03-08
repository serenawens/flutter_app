//source (serach bar): https://medium.com/codechai/a-simple-search-bar-in-flutter-f99aed68f523

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'AdminViewUserEvents.dart';
import 'User.dart';
import 'cmdb.dart';

class AdminViewUsersPage extends StatefulWidget {
  //Class Constructor
  AdminViewUsersPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _AdminViewUsersPageState createState() => _AdminViewUsersPageState();
}

class _AdminViewUsersPageState extends State<AdminViewUsersPage> {
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

  void _showDiffDialog(Widget message) {
    showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            content: message,
          );
        });
  }

  SizedBox getUserInfo(String username) {
    return SizedBox(
        height: filteredNames[username]!['totalEvents']! != "0"?
        160: 115,
        child: Center(
          child: Column(
            children: [
              SelectableText(titleCase(filteredNames[username]!['name']!),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              SelectableText(username,
                  style: TextStyle(fontStyle: FontStyle.italic)),
              SizedBox(height: 4),
              SelectableText(titleCase(filteredNames[username]!['grade']!)),
              SizedBox(height: 4),
              SelectableText(filteredNames[username]!['phoneNumber']!),
              SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SelectableText(
                    titleCase(filteredNames[username]!['totalEvents']!) +
                        " events |  "),
                SelectableText(
                    titleCase(filteredNames[username]!['totalHours']!) +
                        " hours"),
              ]),
              filteredNames[username]!['totalEvents']! != "0"?
              Transform.translate(
                offset: Offset(0,10),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AdminViewUserEventsPage(title: "${filteredNames[username]!['name']!}'s Events", username: username,)),
                      );
                    },
                    child: Text(
                        titleCase(filteredNames[username]!['name']!.split(" ")[0]) + "'s Events")),
              ):
                  SizedBox(),
            ],
          ),
        ));
  }

  final TextEditingController _filter = new TextEditingController();

  String _searchText = "";
  Map<String, Map<String, String>> names = {}; // names we get from API

  Map<String, Map<String, String>> filteredNames =
      {}; // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget? _appBarTitle;

  _AdminViewUsersPageState() {
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

  Future<void> _getNames() async {
    Map<String, Map<String, String>> tempMap = {};

    database.get<Map<String, dynamic>>('Users').then((users) {
      users!.forEach((key, userInfo) {
        tempMap[key] = {
          "name": titleCase(userInfo['name']),
          'username': userInfo['username'],
          'grade': userInfo['grade'],
          'phoneNumber': formatPhoneNumber(userInfo['phoneNumber'].toString()),
          'totalEvents': userInfo['statistics']['eventCount'],
          'totalHours': userInfo['statistics']['totalHours']
        };
      });
      print(tempMap);

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
          title: Text(filteredNames[username]!['name']!,
              style: TextStyle(fontSize: 22)),
          onTap: () {
            _showDiffDialog(getUserInfo(username));

            print(filteredNames[username]);
          },
          subtitle: Row(
            children: [
              Text(username,
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
              Text(" | " +
                      titleCase(filteredNames[username]!['grade']!),
                  style: TextStyle(fontSize: 16)),
            ],
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
