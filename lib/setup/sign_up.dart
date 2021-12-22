// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_showcase/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_done/pages/home.dart';
//import 'package:fireabse_demo/Pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<Login> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: new AppBar(
        title: Text('Sign in',style: TextStyle(
          color: Colors.amber,
          letterSpacing: 2,
        )),
        centerTitle: true,
        backgroundColor: Colors.brown,


        elevation: 0.0,
      ),
      body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                style: TextStyle(color: Colors.white),
                validator: (input) {
                  if(input!.isEmpty){
                    return 'Provide an email';
                  }
                },
                decoration: InputDecoration(
                    fillColor: Colors.grey,
                    filled: true,
                    border: new OutlineInputBorder(

                      borderRadius: const BorderRadius.all(

                        const Radius.circular(8.0),
                      ),
                      borderSide: new BorderSide(
                        color: Colors.black38,
                        width: 1.0,
                      ),),
                    labelText: 'Email'
                ),
                onSaved: (input) => _email = input!,
              ),
              TextFormField(
                style: TextStyle(color: Colors.white),
                validator: (input) {
                  if(input!.length < 6){
                    return 'Longer password please';
                  }
                },
                decoration: InputDecoration(
                    fillColor: Colors.grey,
                    filled: true,
                    border: new OutlineInputBorder(

                      borderRadius: const BorderRadius.all(

                        const Radius.circular(8.0),
                      ),
                      borderSide: new BorderSide(
                        color: Colors.black38,
                        width: 1.0,
                      ),),
                    labelText: 'Password'
                ),
                onSaved: (input) => _password = input!,
                obscureText: true,
              ),
              RaisedButton(
                onPressed: signIn,
                child: Text('Sign in'),
              ),
            ],
          )
      ),
    );
  }
  saveUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }
  void signIn() async {
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      try{
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
        FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: _email)
            .get()
            .then((snapshot) async {
          snapshot.docs.forEach((element) async {
            await saveUsername(element['displayName']);
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => Home(userCredential: userCredential)));
          });
        });}
      catch(e){
        print(e);
        // return "ERROR";

      }
    }
  }
}
