import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    this.icon,
    this.hint,
    this.validator,
    this.onSaved,
    this.autoValidate,
  });
  final FormFieldSetter<String> onSaved;
  final Icon icon;
  final String hint;
  final FormFieldValidator<String> validator;
  final bool autoValidate;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Icon _suffixIcon = Icon(Icons.visibility);
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      print("pressed");
      _obscureText = !_obscureText;
      if (_obscureText == false) {
        _suffixIcon = Icon(Icons.visibility_off);
      } else
        _suffixIcon = Icon(Icons.visibility);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        onSaved: widget.onSaved,
        validator: widget.validator,
        autovalidate: widget.autoValidate==true ? true : false,
        // autofocus: true,
        obscureText: widget.hint == "Password" ? _obscureText : false,
        // style: TextStyle(
        //   fontSize: 20,
        // ),
        decoration: InputDecoration(
          // hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          labelText: widget.hint,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          prefixIcon: Padding(
            child: IconTheme(
              data: IconThemeData(color: Colors.grey[700]),
              child: widget.icon,
            ),
            padding: EdgeInsets.only(left: 20, right: 15),
          ),
          suffixIcon: Padding(
            child: widget.hint == "Password"
                ? IconButton(
                  color: Colors.grey[700],
                    icon: _suffixIcon,
                    onPressed: _toggle,
                  )
                : null,
            padding: EdgeInsets.only(left: 15, right: 7),
          ),
        ),
      ),
    );
  }
}
