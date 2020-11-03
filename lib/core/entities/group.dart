import 'package:bando/core/entities/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Group extends Equatable {
  final String name;
  final String leaderId;
  final List<User> members;

  Group({@required this.name, @required this.leaderId, @required this.members});

  @override
  List<Object> get props => [name, leaderId, members];
}
