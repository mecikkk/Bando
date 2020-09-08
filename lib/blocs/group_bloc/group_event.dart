part of 'group_bloc.dart';

@immutable
abstract class GroupEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GroupQRCodeScannedEvent extends GroupEvent {
  final String groupId;

  GroupQRCodeScannedEvent({@required this.groupId});

  @override
  List<Object> get props => [groupId];
}

class GroupConfigurationTypeChangeEvent extends GroupEvent {
  final GroupConfigurationType configurationType;

  GroupConfigurationTypeChangeEvent({@required this.configurationType});

  @override
  List<Object> get props => [configurationType];
}

class GroupConfigurationSubmittingEvent extends GroupEvent {
  final GroupConfigurationType configurationType;
  final String groupName;
  final String groupId;

  GroupConfigurationSubmittingEvent({@required this.configurationType, this.groupName = "", this.groupId = ""});

  @override
  List<Object> get props => [configurationType, groupName, groupId];
}