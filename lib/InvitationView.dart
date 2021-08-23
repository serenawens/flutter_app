//source (serach bar): https://medium.com/codechai/a-simple-search-bar-in-flutter-f99aed68f523

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InvitationPage extends StatefulWidget {
  //Class Constructor
  InvitationPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _InvitationPageState createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
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

  void _getNames() async {
    Map<String, Map<String, String>> tempMap = {
      'user1': {'name': 'Serena'},
      'user2': {'name': 'Bob'},
      'user3': {'name': 'John'}
    };
    var sortedKeys = tempMap.keys.toList(growable: false)
      ..sort(
          (k1, k2) => tempMap[k1]!['name']!.compareTo(tempMap[k2]!['name']!));
    LinkedHashMap<String, Map<String, String>?> sortedMap =
        new LinkedHashMap<String, Map<String, String>?>.fromIterable(sortedKeys,
            key: (k) => k, value: (k) => tempMap[k]);
    print(sortedMap);

    setState(() {
      names = sortedMap as Map<String, Map<String, String>>;
      filteredNames = names;
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
        String key = filteredNames.keys.elementAt(index);
        return new ListTile(
          title: Text(filteredNames[key]!['name']!),
          onTap: () => print(filteredNames[key]),
          trailing: ElevatedButton(
            onPressed: () {},
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
