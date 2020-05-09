import 'dart:async';
import 'package:Snapshot/home.dart';
import 'package:Snapshot/models/user.dart';
import 'package:Snapshot/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../info.dart';
import 'customTextField.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'socialAuth.dart';

bool rememberme = false;

final timeStamp = DateTime.now();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');

// final GoogleSignIn googleSignIn = GoogleSignIn();
bool isAuth = false;

class LoginSignup extends StatefulWidget {
  static const id = 'LoginSignup';

  @override
  _LoginSignupState createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PersistentBottomSheetController _sheetController;
  String _email;
  String _password;
  String _displayName;
  String _username;
  bool _loading = false;
  bool _autoValidate = false;
  String errorMsg = "";

  DocumentReference docRef =
      Firestore.instance.collection('insta_users').document();

  // @override
  // void initState() {
  //   super.initState();
  //   // Detects when user signed in
  //   // googleSignIn.onCurrentUserChanged.listen((account) {
  //   //   handleSignIn(account);
  //   // }, onError: (e) {
  //   //   print('Error signing in: $e');
  //   // })
  //   //Reauthenticate user when app is opened again
  //   try {
  //     googleSignIn.signInSilently(suppressErrors: false).then((account) {
  //       handleSignIn(account);
  //     }).catchError((e) {
  //       print('Login to continue: $e');
  //     });
  //   } catch (e) {
  //     print("No user exists. Login to continue. Error: $e");
  //   }

  //   //ADD: Reauthenticate user (who signed in with email and password) when they reopen the app
  // }

  // handleSignIn(GoogleSignInAccount account) {
  //   if (account != null) {
  //     print('User signed in: $account');
  //     setState(() {
  //       // isAuth = true;
  //       // Navigator.of(context).pop();
  //       Navigator.of(context).pushReplacementNamed(HomePage.id);
  //     });
  //   } else {
  //     setState(() {
  //       isAuth = false;
  //     });
  //     print(isAuth);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    //button widgets
    filledButton(
        {String text,
        Color textColor,
        void function(),
        double high,
        double fontSize,
        EdgeInsets margin}) {
      return GestureDetector(
        onTap: () {
          // Navigator.pushNamed(context, LoginPage.id);
          function();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          margin: margin,
          width: double.infinity,
          height: high,
          child: Center(
            child: Text(text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: textColor,
                )),
          ),
        ),
      );
    }

    outlineButton({String text, Color textColor, void function()}) {
      return GestureDetector(
        onTap: () {
          function();
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(15, 7.5, 15, 15.5),
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                width: 5,
              )),
          child: Center(
            child: Text(text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: textColor,
                )),
          ),
        ),
      );
    }

    void _validateLoginInput() async {
      final FormState form = _formKey.currentState;
      if (_formKey.currentState.validate()) {
        form.save();
        _sheetController.setState(() {
          _loading = true;
        });
        try {
          FirebaseUser user = (await FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: _email, password: _password))
              .user;
          if (user != null) {
            // Navigator.of(context).pop();
            // var doc = usersRef.document().documentID;
            // var name = usersRef.document(doc).collection('username').toString();
            // snac(name);
            // Timer(Duration(seconds: 2), () {
            print("entered");
            Navigator.of(context).pushReplacementNamed(HomePage.id);
            // });
          }
        } catch (error) {
          switch (error.code) {
            case "ERROR_USER_NOT_FOUND":
              {
                _sheetController.setState(() {
                  errorMsg =
                      "There is no user with such entries. Please try again.";

                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            case "ERROR_WRONG_PASSWORD":
              {
                _sheetController.setState(() {
                  errorMsg = "Password doesn't match your email.";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            default:
              {
                _sheetController.setState(() {
                  errorMsg = "";
                });
              }
          }
        }
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    void _validateRegisterInput() async {
      // DocumentSnapshot doc = await usersRef.document(docRef.documentID).get();
      DocumentReference docRef =
          Firestore.instance.collection('users').document();
      //Firestore.instance.collection('insta_users') = ref
      DocumentSnapshot userRecord = await ref.document(docRef.documentID).get();

      final FormState form = _formKey.currentState;
      if (_formKey.currentState.validate()) {
        form.save();
        _sheetController.setState(() {
          _loading = true;
        });
        try {
          FirebaseUser user = (await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: _email, password: _password))
              .user;
          UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
          userUpdateInfo.displayName = _displayName;
          user.updateProfile(userUpdateInfo).then((onValue) {
            // Navigator.of(context).pop();
            // snac(_username);
            // Timer(Duration(seconds: 2), () {
            Navigator.of(context).pushReplacementNamed(HomePage.id);
            // });
            docRef.setData(
              {
                'username': _username,
                'displayName': _displayName,
                'email': _email,
                'id': docRef.documentID,
                'photoUrl':
                    "https://pngimage.net/wp-content/uploads/2018/06/no-user-image-png.png",
                'bio': "",
                // 'timeStamp': timeStamp,
                "followers": {},
                "following": {},
              },
            ).then((onValue) {
              currentUserModel = User.fromDocument(userRecord);
              _sheetController.setState(() {
                _loading = false;
              });
            });
          });
          // doc = await usersRef.document(docRef.documentID).get();
          // currentUser = User.fromDocument(doc);
          // print(currentUser);
          // print(currentUser.username);
        }

        // try{
        //   FirebaseAuth.instance
        //           .createUserWithEmailAndPassword(
        //               email: _email, password: _password)
        //       .then((signedInUser){
        //         UserManagement().storeNewUser(signedInUser, context);
        //         _sheetController.setState((){
        //           _loading = false;
        //         });
        //       }).catchError((e){
        //         print(e);
        //       });
        // }

        catch (error) {
          switch (error.code) {
            case "ERROR_EMAIL_ALREADY_IN_USE":
              {
                _sheetController.setState(() {
                  errorMsg = "This email is already in use.";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            case "ERROR_WEAK_PASSWORD":
              {
                _sheetController.setState(() {
                  errorMsg = "The password must be 6 characters long or more.";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            default:
              {
                _sheetController.setState(() {
                  errorMsg = "";
                });
              }
          }
        }
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    String emailValidator(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (value.isEmpty) return '*Required';
      if (!regex.hasMatch(value))
        return '*Enter a valid email';
      else
        return null;
    }

    // Widget _buildBar(BuildContext context) {
    //   return new AppBar(
    //     title: new Text(
    //       "Snapshot",
    //       style: TextStyle(
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     centerTitle: true,
    //   );
    // }

    // _loginGoogle() {
    //   googleSignIn.signIn();
    // }

    void _loginSheet() {
      _sheetController = _scaffoldKey.currentState.showBottomSheet<void>(
        (BuildContext context) {
          return SafeArea(
            child: Scaffold(
              // resizeToAvoidBottomPadding: false,
              bottomNavigationBar: FlatButton(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'Tap here to register.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: null,
              ),
              appBar:
                  buildBar(context, title: 'SNAPSHOT', weight: FontWeight.bold),
              body: Container(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    //SingleChildScrollView
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: Column(
                      //singlechildscrollview can also be implemented
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 25),
                        CustomTextField(
                          //signup email validation
                          icon: Icon(Icons.email),
                          hint: "Email",
                          onSaved: (input) {
                            _email = input;
                          },
                          validator: emailValidator,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          icon: Icon(Icons.lock),
                          // suffixIconButton: IconButton(
                          //   onPressed: _toggle,
                          //   icon: IconTheme(
                          //     data: IconThemeData(color: Colors.blue[400]),
                          //     child: _suffixIcon,
                          //   ),
                          // ),

                          onSaved: (input) => _password = input,
                          validator: (input) =>
                              input.isEmpty ? "*Required" : null,
                          hint: "Password",
                        ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        CheckBoxButton(),
                        _loading == true
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                ),
                              )
                            : filledButton(
                                text: 'Log In',
                                function: _validateLoginInput,
                                high: 60,
                                textColor: Colors.white,
                                fontSize: 20,
                              ),
                        SocialButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    void _signupSheet() {
      _sheetController = _scaffoldKey.currentState.showBottomSheet<void>(
        (BuildContext context) {
          return SafeArea(
            child: Scaffold(
              // resizeToAvoidBottomPadding: false,
              bottomNavigationBar: FlatButton(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'Tap here to Login.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () {},
              ),
              appBar:
                  buildBar(context, title: 'SNAPSHOT', weight: FontWeight.bold),
              body: Container(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    //Form -> SingleChildScrollView -> ListView
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 90),
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 25),
                        CustomTextField(
                          icon: Icon(Icons.account_circle),
                          hint: "Display name",
                          validator: (input) =>
                              input.isEmpty ? "*Required" : null,
                          onSaved: (input) => _displayName = input,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          icon: Icon(Icons.alternate_email),
                          hint: 'Username',
                          onSaved: (value) {
                            _username = value;
                          },
                          // autoValidate: true,
                          validator: (value) {
                            if (value.trim().length > 21) {
                              return "*Username too large";
                            } else if (value.isEmpty) {
                              return "*Username empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          //signup email validation
                          icon: Icon(Icons.email),
                          hint: "Email",
                          onSaved: (input) {
                            _email = input;
                          },
                          validator: emailValidator,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          icon: Icon(Icons.lock),
                          // suffixIconButton: IconButton(
                          //   onPressed: _toggle,
                          //   icon: IconTheme(
                          //     data: IconThemeData(color: Colors.blue[400]),
                          //     child: _suffixIcon,
                          //   ),
                          // ),
                          onSaved: (input) => _password = input,
                          validator: (input) =>
                              input.isEmpty ? "*Required" : null,
                          hint: "Password",
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // CheckBoxButton(),
                        _loading
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                ),
                              )
                            : filledButton(
                                text: 'Sign Up',
                                function: _validateRegisterInput,
                                high: 60,
                                textColor: Colors.white,
                                fontSize: 20,
                              ),
                      ],
                    ),
                    key: _formKey,
                    autovalidate: _autoValidate,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    void _loginAuth() {
      return isAuth ? Navigator.pushNamed(context, HomePage.id) : _loginSheet();
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        body: Container(
          // color: Colors.black,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.info,
                        size: 30,
                        color: Colors.black,
                      ),
                      onPressed: (){
                        Navigator.of(context).pushNamed(Info.id);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: 200,
                    width: 200,
                  ),
                  // child: Text(
                  //   'LOGO',
                  //   style: TextStyle(
                  //     fontSize: 30,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  filledButton(
                    text: 'LOG IN',
                    textColor: Colors.white,
                    function: _loginAuth,
                    high: 80,
                    fontSize: 30,
                    margin: EdgeInsets.fromLTRB(15, 15, 15, 7.5),
                  ),
                  // SizedBox(height: 20),
                  outlineButton(
                    text: 'SIGN UP',
                    textColor: Colors.black,
                    function: _signupSheet,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.lineTo(0.0, size.height + 5);
    var secondControlPoint = Offset(size.width - (size.width / 6), size.height);
    var secondEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CheckBoxButton extends StatefulWidget {
  @override
  _CheckBoxButtonState createState() => _CheckBoxButtonState();
}

class _CheckBoxButtonState extends State<CheckBoxButton> {
  void _boxChanged(bool newValue) {
    setState(() {
      rememberme = newValue;

      if (rememberme) {
        print('TRUE');
      } else {
        print('FALSE');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Container(
        height: 20.0,
        child: Row(
          children: <Widget>[
            Theme(
              data: ThemeData(
                  unselectedWidgetColor: Theme.of(context).primaryColor),
              child: Checkbox(
                value: rememberme,
                checkColor: Colors.white,
                onChanged: _boxChanged,
              ),
            ),
            GestureDetector(
              child: Text(
                'Remember Me',
                // style: TextStyle(
                //   fontWeight: FontWeight.bold,
                // )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
