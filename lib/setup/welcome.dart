
import 'package:final_done/setup/sign_up.dart';
import 'package:final_done/setup/signin.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
 // const WelcomePage({required Key key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WELCOME!'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton(onPressed: navigatetoSignIn,
              child: Text('sign in')),
          ElevatedButton(onPressed: navigatetoSignUp,
              child: Text('sign up')),
        ],
      ),
    );
  }
  void navigatetoSignIn(){
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage(),fullscreenDialog: true));
  }
  void navigatetoSignUp(){
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Login(),fullscreenDialog: true));
  }
}
