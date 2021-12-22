import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


  late User loggedInUser;
class ResetPassword extends StatefulWidget {
 // const ResetPassword({Key key}) : super(key: key);
  static const String id= 'reset_password';
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _auth = FirebaseAuth.instance;
  String? newPassword;
  @override
  void initState(){
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser() async{
    try{
      final user =_auth.currentUser;
      if(user!=null){
        loggedInUser=user;
      }
    }
    catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Re-set password'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20.0,),
          TextField(
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.center,
            onChanged: (value){
              newPassword=value;
            },
           // decoration: kTextFieldDecoration.copyWith(hintText:'Enter new password'),
          ),
          ElevatedButton(onPressed: (){
            loggedInUser.updatePassword(newPassword!);
            Navigator.pop(context);


          }, child: Text('set password'),
          )
        ],
      ),
    );
  }
}




