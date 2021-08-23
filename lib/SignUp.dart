import 'package:flutter/material.dart';
import 'package:flutter_app/Login.dart';
import 'Route.dart';

class SignUpPage extends StatefulWidget {
  //Class Constructor
  SignUpPage({Key? key, required this.title}) : super(key: key);

  //Class instance variable
  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Sign Up for an Account:", style: TextStyle(fontSize: 30)),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: firstName,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'First Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: lastName,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Last Name',
                  ),
                ),
              ),
              SizedBox(
                width: 384,
                height: 60,
                child: Card(
                  shape: RoundedRectangleBorder(
                      side: new BorderSide(color: Colors.black12, width: 2),
                      borderRadius: BorderRadius.circular(4.0)),
                  child: DropdownButton<String>(
                    underline: SizedBox(),
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 30,
                    elevation: 10,
                    style: const TextStyle(color: Colors.black54, fontSize: 17),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    hint: Text('  Select Grade'),
                    items: <String>[
                      'Freshman',
                      'Sophomore',
                      'Junior',
                      'Senior'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(value),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: email,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
              ),
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
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              SizedBox(),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Sign Up', style: TextStyle(fontSize: 20)),
                    onPressed: () {
                      print("Name: " + firstName.text + " " + lastName.text);
                      print("Grade: " + username.text);
                      print("Email: " + email.text);
                      print("Password: " + password.text);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RouteScreen()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('Back to Login Page',
                        style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(
                            right: 10, left: 10, top: 2, bottom: 2)),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage(title: "Login")),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
