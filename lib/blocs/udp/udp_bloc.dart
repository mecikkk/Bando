import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bando/models/udp_message.dart';
import 'package:bando/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'udp_event.dart';

part 'udp_state.dart';

class UdpBloc extends Bloc<UdpEvent, UdpState> {
  Stream _udpStream;
  StreamSubscription _listener;
  RawDatagramSocket _listenerSocket;

  UdpBloc() : super(UdpInitial());

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
    }
  }

  Stream<UdpState> _mapUdpStartListeningEventToState() async* {
    yield UdpLaunchingListener();

    try {
      if (_listenerSocket == null) {
        _listenerSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, Constants.multicastPort);

        debugPrint('Datagram socket ready to receive');
        debugPrint('${_listenerSocket.address.address}:${_listenerSocket.port}');

        _listenerSocket.joinMulticast(Constants.multicastAddress);
      }
      debugPrint('Multicast group joined');

      if (_udpStream == null) {
        _udpStream = Stream.periodic(const Duration(milliseconds: 1000));

        _listener = _udpStream.listen((event) {
          print('Checking..');
          Datagram d = _listenerSocket.receive();
          if (d != null) {
            String receivedData = new String.fromCharCodes(d.data);

            debugPrint("Data : ${utf8.decode(receivedData.codeUnits)}");
            debugPrint("JSon : ${jsonDecode(receivedData)}");

            UdpMessage udpMessage = UdpMessage.fromJson(jsonDecode(utf8.decode(d.data)));

            debugPrint('Datagram from ${d.address.address}:${d.port}: $udpMessage');
            add(UdpOnDataReceivedEvent(udpMessage: udpMessage));
            // return UdpDataReceivedState(udpMessage: udpMessage);
          }
          // return UdpBlankState();
        });
      }

    } catch (e) {
      debugPrint("-- UdpBloc | MapUdpStartListeningEventToState error : $e");
      yield UdpFailureState();
    }
  }

  Stream<UdpState> _mapUdpSendDataEventToState(UdpMessage udpMessage) async* {
    try {
      RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      var jsonText = jsonEncode(udpMessage.toJson());
      var utf8JsonText = utf8.encode(jsonText);

      debugPrint("Sending $jsonText  \nSending UTF8 : $utf8JsonText\n");
      socket.send(utf8JsonText, Constants.multicastAddress, Constants.multicastPort);

      yield UdpMessageSendSuccess();
    } catch (e) {
      debugPrint("-- UdpBloc | MapUdpSendDataEventToState error : $e");
      yield UdpFailureState();
    }
  }

  Stream<UdpState> _mapUdpStopListeningEventToState() async* {
    _listenerSocket.close();
    _listener?.cancel();
    _udpStream = null;
  }

  Stream<UdpState> _mapUdpOnDataReceivedEventToState(UdpMessage udpMessage) async* {
    yield UdpDataReceivedState(udpMessage: udpMessage);
  }
}
