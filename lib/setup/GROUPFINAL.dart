// import 'dart:html';
import 'package:final_done/setup/test.dart';
import 'package:final_done/setup/trisha.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_done/setup/location.dart';
import 'package:final_done/setup/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'final group map.dart';
class Groups extends StatefulWidget {
  final String username;
  const Groups({Key? key, required this.username}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();

}

class _GroupsState extends State<Groups> {
  Location location = Location();
  bool _isloading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final String uid;
  late final User user;


  // late String username;
  // late String _fetchEntry;
  // List<String> _todoList = <String>[];
  @override
  void initState() {
    super.initState();
    user = auth.currentUser!;
    uid = user.uid;
  }

  addUsers(String username, List users, String grpid) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AddUsers(
            username: username,
            users: users,
            userid: uid,
            grpid: grpid,
          )),
    );
    setState(
          () {
        _isloading = false;
      },
    );
  }
  leaveGroup(String username, List users, String grpid){
    users.remove(widget.username);
    FirebaseFirestore.instance
        .collection('groups')
        .doc(grpid)
        .update(
      {'data': users},
    );
    Navigator.of(context).pop();
  }

  getLoc(String username, List users, String grpid) async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          _isloading = false;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isloading = false;
        });
        return;
      }
    }
    LocationData _currentPosition = await location.getLocation();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => MyLocation(
            username: username,
            users: users,
            userid: uid,
            grpid: grpid,
            userlat: _currentPosition.latitude!,
            userlong: _currentPosition.longitude!,
          )),
    );
    setState(
          () {
        _isloading = false;
      },
    );

  }



  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> cs = FirebaseFirestore.instance
        .collection('groups')
        .where('data', arrayContains: widget.username)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Choose a group',
            style: TextStyle(
                color: Colors.white,
                letterSpacing: 2,
                //fontStyle: FontStyle.italic
            )),
        centerTitle: true,
        //backgroundColor: Colors.brown,


        elevation: 0.0,

      ),

      body: StreamBuilder<QuerySnapshot>(
          stream: cs,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            var _todoList = snapshot.data!.docs;
            if (snapshot.connectionState == ConnectionState.active) {

              return ListView.builder(
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 4.0),

                        child: new Column( children: [
                          Card(
                            child: ListTile(
                              onTap: () {addUsers(widget.username,
                                  _todoList[index]['data'],
                                  _todoList[index].id);},
                              title: Text(_todoList[index]['groupname'].toString(),style: TextStyle(
                                color: Colors.amber,
                                letterSpacing: 2,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                decoration:TextDecoration.underline,
                              )
                              ),

                              subtitle: Text(
                                  _todoList[index]['data'].join(','),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    letterSpacing: 2,
                                  )
                              ),

                            ),
                          ),
                          MaterialButton(
                            elevation: 0,
                            minWidth: double.maxFinite,
                            height: 20,
                            onPressed: () {
                              getLoc(
                                  widget.username,
                                  _todoList[index]['data'],
                                  _todoList[index].id);
                            },
                            color: Colors.pink,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 10),
                                Text('Location data',
                                    style: TextStyle(color: Colors.white, fontSize: 20)),
                              ],
                            ),
                          ),
                         /* MaterialButton(
                            child: Text('Click here to exit the above group',style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              letterSpacing: 2,
                            )),
                            onPressed: () {
                              leaveGroup(widget.username,
                                  _todoList[index]['data'],
                                  _todoList[index].id);
                            },
                          ),*/

                        ]));
                  });
            } else {
              return Container();
            }

          }
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      MainPage(
                        name: widget.username,
                      )),
            ),
      ),


    );
  }




  @override
  bool get wantKeepAlive => true;
}