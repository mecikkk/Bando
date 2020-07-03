import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FileManagerState extends Equatable {

  @override
  List<Object> get props {

  }
}

class InitialFileManagerState extends FileManagerState {}
