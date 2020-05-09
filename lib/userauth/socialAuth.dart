import 'package:Snapshot/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButtons extends StatefulWidget {
  @override
  _SocialButtonsState createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  Future<Null> _ensureLoggedIn(BuildContext context) async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      user = await googleSignIn.signInSilently();
    }
    if (user == null) {
      await googleSignIn.signIn();
      await tryCreateUserRecord(context);
    }

    if (await auth.currentUser() == null) {
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

  void login() async {
    await _ensureLoggedIn(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          FlatButton(
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            onPressed: () {
              print("User wants to reset password");
            },
          ),
          Row(children: <Widget>[
            Expanded(child: LoginDiv()),
            Text("OR"),
            Expanded(child: LoginDiv()),
          ]),
          RaisedButton(
            color: Colors.blue[900],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            disabledColor: Colors.blue[200],
            child: Container(
              width: double.infinity,
              height: 60,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FaIcon(
                      FontAwesomeIcons.facebook,
                      color: Colors.white,
                    ),
                    Text(
                      'Login with Facebook',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onPressed: () {
              print("FB login pressed");
            },
          ),
          SizedBox(height: 20),
          RaisedButton(
            // onPressed: _loginGoogle(),
            onPressed: login,
            color: Colors.red[700],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            disabledColor: Colors.red[200],
            child: Container(
              width: double.infinity,
              height: 60,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                    ),
                    Text(
                      'Login with Google',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginDiv extends StatelessWidget {
  const LoginDiv({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 50,
      thickness: 1,
      indent: 10,
      endIndent: 10,
      color: Colors.grey[600],
    );
  }
}
