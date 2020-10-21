
part of 'udp_bloc.dart';

@immutable
abstract class UdpEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UdpStartListeningEvent extends UdpEvent {}

class UdpSendDataEvent extends UdpEvent {
  final UdpMessage udpMessage;

  UdpSendDataEvent({@required this.udpMessage});

  @override
  List<Object> get props => [udpMessage];
}

class UdpStopListeningEvent extends UdpEvent {

}

class UdpOnDataReceivedEvent extends UdpEvent {
  final UdpMessage udpMessage;

  UdpOnDataReceivedEvent({@required this.udpMessage});

  @override
  List<Object> get props => [udpMessage];
}

class UdpGetSyncModeEvent extends UdpEvent {}

class UdpChangeSyncModeEvent extends UdpEvent {
  final SyncMode syncMode;

  UdpChangeSyncModeEvent({@required this.syncMode});

  @override
  List<Object> get props => [syncMode];
}