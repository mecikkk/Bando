import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class EmailAddress extends Equatable {
  final String value;

  EmailAddress({@required this.value});

  @override
  List<Object> get props => [value];
}
