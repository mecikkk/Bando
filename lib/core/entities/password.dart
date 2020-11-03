import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Password extends Equatable {
  final String value;

  Password({@required this.value});

  @override
  List<Object> get props => [value];
}
