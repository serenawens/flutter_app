// Flutter code sample for BottomNavigationBar
//
// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has four [BottomNavigationBarItem]
// widgets, which means it defaults to [BottomNavigationBarType.shifting], and
// the [currentIndex] is set to index 0. The selected item is amber in color.
// With each [BottomNavigationBarItem] widget, backgroundColor property is
// also defined, which changes the background color of [BottomNavigationBar],
// when that item is selected. The `_onItemTapped` function changes the
// selected item's index and displays a corresponding message in the center of
// the [Scaffold].

import 'package:flutter/material.dart';
import 'package:flutter_app/Home.dart';
import 'package:flutter_app/PendingInvites.dart';
import 'AdminEventAdd.dart';
import 'ProfileInfo.dart';
import 'User.dart';
import 'cmdb.dart';

/// This is the stateful widget that the main application instantiates.
class RouteScreen extends StatefulWidget {
  const RouteScreen({Key? key}) : super(key: key);

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _RouteScreenState extends State<RouteScreen> {
  User user = User();
  CMDB database = CMDB();
  bool pending = false;

  void getUserInfo() {
    setState(() {});
    database.get("Users/" + user.info!['username'] + "/pending/").then((value) {
      setState(() {
        if (value != null) {
          print("not null");
          pending = true;
        } else {
          pending = false;
          print("it's null");
        }
      });
      print("getting info");
      print(pending);
    });
  }

  @override
  initState() {
    getUserInfo();
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(title: "Home"),
    InvitesPage(title: "Event Invites"),
    ProfilePage(title: "My Profile")
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      getUserInfo();
    });
  }

  static BottomNavigationBarItem invites = BottomNavigationBarItem(
    icon: Icon(Icons.mail),
    label: 'Invites',
    backgroundColor: Colors.red,
  );

  BottomNavigationBar getNavigationBar(String role) {
    if (role == "member") {
      return BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          pending
              ? BottomNavigationBarItem(
                  icon: Icon(Icons.mark_email_unread),
                  label: 'Invites',
                  backgroundColor: Colors.red,
                )
              : BottomNavigationBarItem(
                  icon: Icon(Icons.mail),
                  label: 'Invites',
                  backgroundColor: Colors.red,
                ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      );
    } else {
      _widgetOptions.add(AdminEventPage(title: "Add Volunteering Event"));
      return BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          pending
              ? BottomNavigationBarItem(
            icon: Icon(Icons.mark_email_unread),
            label: 'Invites',
            backgroundColor: Colors.red,
          )
              : BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Invites',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Event',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: getNavigationBar(user.info!['role']));
  }
}
