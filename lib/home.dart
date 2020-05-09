import 'package:Snapshot/userauth/LoginSignup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'feed.dart';
import 'upload_page.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'activity_feed.dart';
import 'create_account.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;
import 'models/user.dart';

final auth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();
final ref = Firestore.instance.collection('insta_users');
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

User currentUserModel;

Future<Null> _silentLogin(BuildContext context) async {
  GoogleSignInAccount user = googleSignIn.currentUser;

  if (user == null) {
    user = await googleSignIn.signInSilently();
    await tryCreateUserRecord(context);
  }

  if (await auth.currentUser() == null && user != null) {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await auth.signInWithCredential(credential);
  }
}

Future<Null> _setUpNotifications() async {
  if (Platform.isAndroid) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: " + token);

      Firestore.instance
          .collection("insta_users")
          .document(currentUserModel.id)
          .updateData({"androidNotificationToken": token});
    });
  }
}

Future<void> tryCreateUserRecord(BuildContext context) async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    return null;
  }
  DocumentSnapshot userRecord = await ref.document(user.id).get();
  if (userRecord.data == null) {
    // no user record exists, time to create

    String userName = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Center(
                child: Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      leading: Container(),
                      title: Text('Fill out missing data',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.white,
                    ),
                    body: ListView(
                      children: <Widget>[
                        Container(
                          child: CreateAccount(),
                        ),
                      ],
                    )),
              )),
    );

    if (userName != null || userName.length != 0) {
      ref.document(user.id).setData({
        "id": user.id,
        "username": userName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "followers": {},
        "following": {},
      });
    }
    userRecord = await ref.document(user.id).get();
    Navigator.of(context).pushReplacementNamed(HomePage.id);
    print("New user created in Firestore!");
  } else if (userRecord.exists) {
    Navigator.of(context).pushReplacementNamed(HomePage.id);
    print("Welcome old user!");
  }

  currentUserModel = User.fromDocument(userRecord);
  return null;
}

bool triedSilentLogin = false;

class HomePage extends StatefulWidget {
  static const id = 'HomePage';

  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;
  bool setupNotifications = false;
  // var _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    print("init");
  }

  @override
  void dispose() {
    pageController.dispose();
    print('disp');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (triedSilentLogin == false) {
      silentLogin(context);
    }

    if (setupNotifications == false && currentUserModel != null) {
      setUpNotifications();
    }

    return (googleSignIn.currentUser == null || currentUserModel == null)
        ? LoginSignup()
        : Scaffold(
            // key: _scaffoldKey,
            body: PageView(
              children: [
                Container(
                  color: Colors.white,
                  child: Feed(),
                ),
                Container(color: Colors.white, child: SearchPage()),
                Container(
                  color: Colors.white,
                  child: Uploader(),
                ),
                Container(color: Colors.white, child: ActivityFeedPage()),
                Container(
                    color: Colors.white,
                    child: ProfilePage(
                      userId: googleSignIn.currentUser.id,
                    )),
              ],
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: onPageChanged,
            ),
            bottomNavigationBar: CupertinoTabBar(
              backgroundColor: Colors.white,
              currentIndex: _page,
              onTap: navigationTapped,
              activeColor: Colors.black,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home)),
                BottomNavigationBarItem(icon: Icon(Icons.search)),
                BottomNavigationBarItem(icon: Icon(Icons.add_box)),
                BottomNavigationBarItem(icon: Icon(Icons.notifications)),
                BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
              ],
            ),
          );
  }

  void setUpNotifications() {
    _setUpNotifications();
    setState(() {
      setupNotifications = true;
    });
  }

  void silentLogin(BuildContext context) async {
    await _silentLogin(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  navigationTapped(int page) {
    //Animating Page
    // page = _page;
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
