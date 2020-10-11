part of 'udp_bloc.dart';

@immutable
abstract class UdpState extends Equatable {
  @override
  List<Object> get props => [];
}

class UdpInitial extends UdpState {}

class UdpBlankState extends UdpState {}

class UdpDataReceivedState extends UdpState {
  final UdpMessage udpMessage;

  UdpDataReceivedState({@required this.udpMessage});

  @override
  List<Object> get props => [udpMessage];
}

class UdpMessageSendSuccess extends UdpState {}

class UdpLaunchingListener extends UdpState {}

class UdpFailureState extends UdpState {}