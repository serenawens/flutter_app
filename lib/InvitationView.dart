//source (serach bar): https://medium.com/codechai/a-simple-search-bar-in-flutter-f99aed68f523

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'User.dart';
import 'cmdb.dart';

class InvitationPage extends StatefulWidget {
  //Class Constructor
  InvitationPage({Key? key, required this.title, required this.eventKey})
      : super(key: key);

  //Class instance variable
  final String title;

  final String eventKey;

  @override
  _InvitationPageState createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  CMDB database = CMDB();
  User user = User();

  final TextEditingController _filter = new TextEditingController();

  String _searchText = "";
  Map<String, Map<String, String>> names = {}; // names we get from API

  Map<String, Map<String, String>> filteredNames =
      {}; // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget? _appBarTitle;

  _InvitationPageState() {
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
      users!.forEach((key, userInfo) {
        if (!users[key].containsKey('events') ||
            (users[key].containsKey('events') &&
                !users[key]['events'].containsKey(widget.eventKey))) {
          tempMap[key] = {
            "name": titleCase(userInfo['name']),
            "invitedByYou": 'false'
          };

          if (users[key].containsKey('pending') &&
              users[key]['pending'].containsKey(widget.eventKey) &&
              users[key]['pending'][widget.eventKey]['inviter'] ==
                  user.info!['username']) {
            tempMap[key]!["invitedByYou"] = 'true';
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
          trailing: filteredNames[username]!['invitedByYou'] == 'true'
              ? ElevatedButton(
                  onPressed: () {},
                  child: Text('Invited'),
                  style: ElevatedButton.styleFrom(primary: Colors.black12))
              : ElevatedButton(
                  onPressed: () {
                    database.update(
                        "Users/" +
                            username +
                            "/pending/" +
                            widget.eventKey +
                            "/",
                        {
                          "eventID": widget.eventKey,
                          "inviter": user.info!["username"]
                        });
                    database.update(
                        "Events/" +
                            widget.eventKey +
                            "/pending/" +
                            username +
                            "/",
                        {
                          "name":
                              filteredNames[username]!['name']!.toLowerCase()
                        });
                    setState(() {
                      names[username]!['invitedByYou'] = 'true';
                      filteredNames = names;
                    });
                  },
                  child: Text('Invite'),
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
