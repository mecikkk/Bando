import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bando/models/udp_message.dart';
import 'package:bando/pages/home/lyrics_page.dart';
import 'package:bando/repositories/firestore_group_repository.dart';
import 'package:bando/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'udp_event.dart';
part 'udp_state.dart';

class UdpBloc extends Bloc<UdpEvent, UdpState> {
  final FirestoreGroupRepository _groupRepository;
  String _currentUserId;

  Stream _udpStream;
  StreamSubscription _listener;
  RawDatagramSocket _listenerSocket;

  UdpBloc({@required FirestoreGroupRepository groupRepository})
      : assert(groupRepository != null),
        _groupRepository = groupRepository,
        super(UdpInitial());

  @override
  Stream<UdpState> mapEventToState(
    UdpEvent event,
  ) async* {
    if (event is UdpStartListeningEvent) {
      yield* _mapUdpStartListeningEventToState();
    } else if (event is UdpSendDataEvent) {
      yield* _mapUdpSendDataEventToState(event.udpMessage);
    } else if (event is UdpStopListeningEvent) {
      yield* _mapUdpStopListeningEventToState();
    } else if (event is UdpOnDataReceivedEvent) {
      yield* _mapUdpOnDataReceivedEventToState(event.udpMessage);
    } else if (event is UdpGetSyncModeEvent) {
      yield* _mapUdpGetSyncModeEventToState();
    } else if (event is UdpChangeSyncModeEvent) {
      yield* _mapUdpChangeSyncModeEventToState(event.syncMode);
    }
  }

  Stream<UdpState> _mapUdpStartListeningEventToState() async* {
    yield UdpLaunchingListener();
    try {
      if (_currentUserId == null) {
        User fUser = FirebaseAuth.instance.currentUser;
        _currentUserId = fUser.uid;
      }

      String leaderId = await _groupRepository.getLeader();

      debugPrint("currentUserId ($_currentUserId) == leaderId ($leaderId)? ");

      if (leaderId != _currentUserId) {
        yield UdpMemberModeState();
        if (_listenerSocket == null) {
          _listenerSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, Constants.multicastPort);

          debugPrint('Datagram socket ready to receive');
          debugPrint('${_listenerSocket.address.address}:${_listenerSocket.port}');

          _listenerSocket.joinMulticast(Constants.multicastAddress);
          debugPrint('Multicast group joined');
        }

        if (_udpStream == null) {
          _udpStream = Stream.periodic(const Duration(milliseconds: 1000));

          _listener = _udpStream.listen((event) async {
            Datagram d = _listenerSocket.receive();
            if (d != null) {
              UdpMessage udpMessage = await compute(_decodeReceivedMessage, d.data);

              add(UdpOnDataReceivedEvent(udpMessage: udpMessage));
            }
          });
        }
      } else
        yield UdpLeaderModeState();
    } catch (e) {
      debugPrint("-- UdpBloc | MapUdpStartListeningEventToState error : $e");
      yield UdpFailureState();
    }
  }

  Stream<UdpState> _mapUdpSendDataEventToState(UdpMessage udpMessage) async* {
    try {
      await compute(_encodeAndSendMessage, udpMessage.toJson());

      yield UdpMessageSendSuccess();
    } catch (e) {
      debugPrint("-- UdpBloc | MapUdpSendDataEventToState error : $e");
      yield UdpFailureState();
    }
  }

  Stream<UdpState> _mapUdpStopListeningEventToState() async* {
    _listenerSocket?.close();
    _listener?.cancel();
    _udpStream = null;
  }

  Stream<UdpState> _mapUdpOnDataReceivedEventToState(UdpMessage udpMessage) async* {
    yield UdpDataReceivedState(udpMessage: udpMessage);
  }

  Stream<UdpState> _mapUdpChangeSyncModeEventToState(SyncMode syncMode) async* {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();

      int intSyncMode = (syncMode == SyncMode.MANUAL) ? 1 : 2;

      _pref.setInt('syncMode', intSyncMode);

      yield UdpGetSyncModeResultState(syncMode: syncMode);
    } on Exception catch (e) {
      debugPrint("--- UdpBloc | UdpChangeSyncModeEventToState error : $e");
    }
  }

  Stream<UdpState> _mapUdpGetSyncModeEventToState() async* {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      int intSyncMode = _pref.getInt('syncMode');

      if (intSyncMode == null) await _pref.setInt('syncMode', 1);

      SyncMode syncMode = (_pref.getInt('syncMode') == 1) ? SyncMode.MANUAL : SyncMode.AUTO;

      yield UdpGetSyncModeResultState(syncMode: syncMode);
    } on Exception catch (e) {
      debugPrint("--- UdpBloc | UdpGetSyncModeEventToState error : $e");
    }
  }
}

Future<void> _encodeAndSendMessage(Map udpMessage) async {
  RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

  var jsonText = jsonEncode(udpMessage);
  var utf8JsonText = utf8.encode(jsonText);

  socket.send(utf8JsonText, Constants.multicastAddress, Constants.multicastPort);
}

UdpMessage _decodeReceivedMessage(Uint8List data) {
  return UdpMessage.fromJson(jsonDecode(utf8.decode(data)));
}
