//import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_done/setup/change.dart';
import 'package:final_done/setup/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


late User loggedInUser;
class MemberInfo extends StatefulWidget {
  //const MemberInfo({Key key}) : super(key: key);

  @override
  _MemberInfoState createState() => _MemberInfoState();
}


class _MemberInfoState extends State<MemberInfo> {

  final _auth=FirebaseAuth.instance;
  final userCollection = FirebaseFirestore.instance.collection("data");
  late String name,email,uid;


    void initState(){
    super.initState();
    getUser();
  }

  Future<void> userdata() async{
    final uid= loggedInUser.uid;
    DocumentSnapshot ds= await userCollection.doc(uid).get();
    name=ds.get('name');
    email=ds.get('email');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   // throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text('profile page'),
      ),
      body: Padding (
       // mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        padding: EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
        child: Column( crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('USERNAME',style: TextStyle(
            color: Colors.pinkAccent,
            letterSpacing: 2.0,
          ),),
          FutureBuilder(
            future: userdata(),
            builder: (context,snapshot){
               if(snapshot.connectionState!=ConnectionState.done)
                 return Text("loading");
               SizedBox(width: 20,);

               return Text("$name",

               style: TextStyle(
                 color: Colors.pink,
                 fontSize: 21.0,
               ),);

          },

          ),
          SizedBox(height: 20.0,),
          Text('EMAIL ADDRESS',style: TextStyle(
            color: Colors.pinkAccent,
            letterSpacing: 2.0,
          ),),
          FutureBuilder(
            future: userdata(),
            builder: (context,snapshot){
              if(snapshot.connectionState!=ConnectionState.done)
                return Text("loading");
              SizedBox(width: 20,);
              return Text("$email",

                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 21.0,
                ),);

            },

          ),
          ElevatedButton(onPressed:(){ Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPassword()));},


            child: Text('EDIT PROFILE'),
           style: ButtonStyle(
             backgroundColor: MaterialStateProperty.all(Colors.pinkAccent)
           ),
          )

        ],
      )


      ));
}
  void getUser() async {
    try{
      final user =_auth.currentUser;
      if(user!=null){
        loggedInUser=user;
      }
    }
    catch(e){
      print(e);
    }
   // CollectionReference users = FirebaseFirestore.instance.collection('users');
   // late String name,email,uid;
    //Future<void> updateUser() {
      //return users
        //  .doc(uid)
          //.update({'name': name})
          //.then((value) => print("User Updated"))
          //.catchError((error) => print("Failed to update user: $error"));
  //  }
    final CollectionReference data= FirebaseFirestore.instance.collection('data');
    Future updateUser(email,name) async {
      return await data.doc(uid).set({
        'name': name,
        'email': email,
      }


      );
    }






  }


  }

