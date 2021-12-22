import 'package:final_done/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
   late String _email, _password;
   late String _username;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('sign in'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (input) {
                  if (input!.isEmpty) {
                    return 'please type an email';
                  }
                },
                onSaved: (input) => _email = input!,
                decoration: InputDecoration(
                    labelText: 'Email'
                ),
              ),
              TextFormField(
                validator: (input) {
                  if (input!.length < 6) {
                    return 'YOUR PASSWORD NEEDS TO BE OF ATLEAST 6 CHARS';
                  }
                },
                onSaved: (input) => _password = input!,
                decoration: InputDecoration(
                    labelText: 'password'
                ),
                obscureText: true,
              ),
              ElevatedButton(onPressed: signIn,
                  child: Text('sign in'))

            ],
          ),
        )
    );
  }

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if (formState!.validate()) {
      //TODO login to firebase
      formState.save();
      try {
        UserCredential user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password
        )) ;

       User? updateUser = FirebaseAuth.instance.currentUser;
       // updateUser!.updateProfile(displayName: _username);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home(userCredential: user)));
      } catch (e) {
        print(e);
      }
    }
  }


}

