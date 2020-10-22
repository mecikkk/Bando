import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:flutter/foundation.dart';

class PasswordModel extends Password {
  PasswordModel({
    @required String password,
  }) : super(password: password) {
    _validation(password);
  }

  _validation(String password) {
    String pattern = r'^(?=.*[0-9])(?=.*[a-z]).{6,}$';

    RegExp regExp = RegExp(pattern);
    if (password.isEmpty) throw PasswordFailure(message: 'Password can\'t be empty');
    if (!regExp.hasMatch(password)) throw PasswordFailure(message: 'At least 6 characters, and one digit');
  }
}
