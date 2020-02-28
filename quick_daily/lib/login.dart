import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/background.jpg"))),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CircleAvatar(
                    radius: 58.0,
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.android, size: 50),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        hintStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.black45,
                        hintText: 'Username'),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.black45,
                        hintText: 'Password'),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  FlatButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot your Password?',
                        style: TextStyle(color: Colors.white),
                      )),
                  SizedBox(
                    height: 15.0,
                  ),
                  RaisedButton(
                    onPressed: () {},
                    child: Padding(
                        padding: EdgeInsets.all(15.0), child: Text('LOGIN')),
                    color: Colors.redAccent,
                    textColor: Colors.white,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  RaisedButton(
                    onPressed: () {},
                    child: Padding(
                        padding: EdgeInsets.all(15.0), child: Text('REGISTER')),
                    color: Colors.grey,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


