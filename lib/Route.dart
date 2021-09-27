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

  List<BottomNavigationBarItem> bottomNavigationBarItemList = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.mail,
      ),
      label: 'Invites',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'My Profile',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add),
      label: 'Add Event',
    ),
  ];

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(title: "Home"),
    InvitesPage(title: "Event Invites"),
    ProfilePage(title: "My Profile")
  ];

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  initState() {
    getUserInfo();
  }

  void getUserInfo() {
    setState(() {});
    database
        .get<Map<String, dynamic>>(
            "Users/" + user.info!['username'] + "/pending/")
        .then((value) {
      setState(() {
        if (value != null) {
          bottomNavigationBarItemList[1] = BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
               Icon(Icons.mail),
               Positioned(
                  right: 0,
                  child: new Container(
                    padding: EdgeInsets.all(1),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      "${value.length}",
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
            label: 'Invites',
          );
        } else {
          bottomNavigationBarItemList[1] = BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Invites',
          );
        }
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      getUserInfo();
    });
  }

  BottomNavigationBar getNavigationBar(String role) {
    if (role == "member") {
      setState(() {
        if (bottomNavigationBarItemList.length > 3)
          bottomNavigationBarItemList.removeLast();
      });

      return BottomNavigationBar(
        items: bottomNavigationBarItemList,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      );
    } else {
      _widgetOptions.add(AdminEventPage(title: "Create Event"));
      return BottomNavigationBar(
        items: bottomNavigationBarItemList,
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
