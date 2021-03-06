import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nudge/utils/baseAuth.dart';
import 'package:nudge/utils/persistence.dart';
import 'package:nudge/views/controller.dart';

class LoginProvider extends ChangeNotifier {
  BaseAuth auth = new Auth();

  FocusNode emailFocus = new FocusNode();
  FocusNode passFocus = new FocusNode();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final TextEditingController emailTEC = new TextEditingController();
  final TextEditingController passwordTEC = new TextEditingController();

  var formKey = GlobalKey<FormState>();

  void onFocusChange() {
    debugPrint("Focus: " + emailFocus.hasFocus.toString());
    debugPrint("Focus: " + passFocus.hasFocus.toString());
  }

  set isLoading(val) {
    _isLoading = val;
    notifyListeners();
  }

  login(context) async {
    try {
      if (formKey.currentState.validate()) {
        _isLoading = true;
        notifyListeners();

        var user = await auth.signIn(emailTEC.text, passwordTEC.text);

        if (user != null) {
          emailTEC.text = '';
          passwordTEC.text = '';

          var studentModel = await auth.getStudentProfileData(user.uid);
          saveItem(
              item: json.encode(studentModel.toJson()).toString(),
              key: 'userModel');
          isLoading = false;

          if (studentModel != null) {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Controller(
                  studentModel: studentModel,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      isLoading = false;
      print(e.toString());
      if (e.toString().contains('ERROR_WRONG_PASSWORD')) {
        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  title: new Text("Invalid Password"),
                  content: new Text(
                      "The password is invalid or the user does not have a password."),
                ));
      } else if (e.toString().contains('ERROR_TOO_MANY_REQUESTS')) {
        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  title: new Text("Error"),
                  content: new Text(
                      "Too many unsuccessful login attempts. Try again later"),
                ));
      } else if (e.toString().contains('ERROR_USER_NOT_FOUND')) {
        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  title: new Text("Error"),
                  content: new Text("This User does not exist."),
                ));
      } else if (e.toString().contains('not a')) {
        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  title: new Text("Error"),
                  content: new Text(e.toString() ?? ''),
                ));
      } else {
        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  title: new Text("Error"),
                  content: new Text("An Error Occurred"),
                ));
      }
    }
  }
}
