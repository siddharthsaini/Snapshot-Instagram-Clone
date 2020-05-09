import 'package:Snapshot/info.dart';
import 'package:Snapshot/userauth/LoginSignup.dart';
import 'package:Snapshot/userauth/socialAuth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // after upgrading flutter this is now necessary

  // to enable timestamps in firebase
  Firestore.instance.settings().then((_) {
    print('[Main] Firestore timestamps in snapshots set');
  }, onError: (_) => print('[Main] Error setting timestamps in snapshots'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snapshot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonColor: Colors.pink,
        primaryColor: Colors.blue,
        // accentColor: Colors.white,
        // primaryIconTheme: IconThemeData(color: Colors.black),
      ),
      home: HomePage(title: 'Snapshot'),
      routes: {
        HomePage.id: (context) => HomePage(),
        // WelcomeScreen.id: (context) => WelcomeScreen(),
        // LoginPage.id: (context) => LoginPage(),
        // SignUpPage.id: (context) => SignUpPage(),
        // Home.id: (context) => Home(),
        LoginSignup.id: (context) => LoginSignup(),
        Info.id: (context) => Info(),
        // CreateAccount.id: (context) => CreateAccount(),
        // Search.id: (context) => Search(),
        // Upload.id: (context) => Upload(),
      },
    );
  }
}
