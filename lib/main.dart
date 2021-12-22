

import 'package:final_done/pages/home.dart';
import 'package:final_done/setup/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Demo',
      theme: new ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: WelcomePage()
    );
  }


}

