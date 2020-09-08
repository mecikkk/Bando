part of 'group_bloc.dart';

@immutable
abstract class GroupState extends Equatable {
  @override
  List<Object> get props => [];
}

class GroupInitialState extends GroupState {
  final GroupConfigurationType configurationType;

  GroupInitialState({@required this.configurationType});

  @override
  List<Object> get props => [configurationType];
}

class GroupByQRCodeNotFoundState extends GroupState {}

class GroupFailureState extends GroupState {
  final GroupConfigurationType configurationType;

  GroupFailureState({@required this.configurationType});

  @override
  List<Object> get props => [configurationType];
}

class GroupByQRCodeFoundState extends GroupState {
  final Group group;

  GroupByQRCodeFoundState({@required this.group});

  @override
  List<Object> get props => [group];
}

class GroupByQRCodeLoadingState extends GroupState {}

class GroupLoadingState extends GroupState {
  final GroupConfigurationType loadingType;

  GroupLoadingState({@required this.loadingType});

  @override
  List<Object> get props => [loadingType];
}

class GroupConfigurationSuccessState extends GroupState {
  final GroupConfigurationType configurationType;
  final Group group;

  GroupConfigurationSuccessState({@required this.configurationType, @required this.group});

  @override
  List<Object> get props => [configurationType, group];
}