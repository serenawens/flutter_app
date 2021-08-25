import 'package:flutter/material.dart';
import 'package:flutter_app/SignUp.dart';
import 'package:flutter_app/User.dart';
import 'Route.dart';
import 'cmdb.dart';

class LoginPage extends StatefulWidget {
  //Class Constructor
  LoginPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  User user = User();
  CMDB database = CMDB();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    database.initialize("serena-test");
  }

  Future<bool> checkLoginInfo() async {
    Map<String, dynamic>? response =
        await database.get<Map<String, dynamic>>('Users');

    for (var key in response!.keys) {
      print(key == username.text);
      print(response[key]['password'] == password.text);
      if (key == username.text && response[key]['password'] == password.text) {
        user.info = response[key];
        return true;
      }
    }
    return false;
  }

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

  List<Widget> returnLoginError() {
    return [
      ElevatedButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Enter Your Login Info:',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: username,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              ElevatedButton(
                child: Text('Login', style: TextStyle(fontSize: 20)),
                onPressed: () {
                  checkLoginInfo().then((value) {
                    if (value == true) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RouteScreen()),
                      );
                    } else {
                      _showDialog("Wrong username or passcode, try again",
                          "ERROR", returnLoginError());
                    }
                  });
                },
              ),
              ElevatedButton(
                child: Text('Sign Up Here', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.only(
                        right: 10, left: 10, top: 2, bottom: 2)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignUpPage(title: 'Sign Up')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
