import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:flutter/foundation.dart';

class EmailAddressModel extends EmailAddress {
  EmailAddressModel({
    @required String emailAddress,
  }) : super(email: emailAddress) {
    _validation(emailAddress);
  }

  _validation(String email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(email)) throw EmailAddressFailure(message: 'Invalid email');
  }
}
