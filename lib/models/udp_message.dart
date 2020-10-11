import 'package:flutter/material.dart';

class UdpMessage {
  String fileName;
  String songbookPath;

  UdpMessage({@required this.fileName, @required this.songbookPath});

  @override
  int get hashCode => fileName.hashCode ^ songbookPath.hashCode;

  @override
  bool operator == (other) =>
      identical(this, other) ||
          other is UdpMessage &&
              runtimeType == other.runtimeType &&
              fileName == other.fileName &&
              songbookPath == other.songbookPath;


  @override
  String toString() {
    return "UdpMessage(fileName : $fileName, songbookPath : $songbookPath)";
  }

  Map<String, Object> toJson() {
    return {
      "fileName" : fileName,
      "songbookPath" : songbookPath
    };
  }

  static UdpMessage fromJson(Map<String, Object> json) {
    return UdpMessage(
        fileName : json["fileName"] as String,
        songbookPath : json["songbookPath"] as String,
    );
  }

}