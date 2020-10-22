import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class EmailAddress extends Equatable {
  final String email;

  EmailAddress({@required this.email});

  @override
  List<Object> get props => [email];

}