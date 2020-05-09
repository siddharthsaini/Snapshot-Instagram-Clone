import 'package:flutter/material.dart';

class Info extends StatelessWidget {
  static const id = 'info';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                    "As of now, GOOGLE AUTHENTICATION is the only way to LOGIN. Other authentication methods are in progress.", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    )),
              ),
              MaterialButton(
                color: Colors.red,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Back",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
