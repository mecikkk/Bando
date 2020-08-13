import 'package:bando/auth/entities/update_info_entity.dart';
import 'package:bando/auth/models/update_info_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class RealtimeDatabaseRepository {
  Future<void> addUpdateInfo(String groupId, String userName, List<Map<String, dynamic>> updatedFiles) async {
    DateTime currentDate = DateTime.now();
    var milliseconds = Timestamp.fromDate(currentDate).millisecondsSinceEpoch;
    String dateId =
        "${currentDate.day}-${currentDate.month}-${currentDate.year}x${currentDate.hour}:${currentDate.minute}:${currentDate.second}";

    return FirebaseDatabase.instance.reference().child(groupId).child("updates").child(dateId).set(new UpdateInfo(
          time: milliseconds,
          whoUpdated: userName,
          operation: "ADD",
          files: updatedFiles,
        ).toEntity().toJson());
  }

  Future<List<UpdateInfo>> getUpdatedFiles(String groupId, int lastUpdate) async {
    List<Map<dynamic, dynamic>> snapshots = List();
    List<UpdateInfo> updates = List();

    await FirebaseDatabase.instance
        .reference()
        .child(groupId)
        .child("updates")
        .orderByChild('time')
        .startAt(lastUpdate + 1)
        .once()
        .then((value) => snapshots.add(value.value));

    snapshots.forEach((element) {
      if (element != null) {
        element.values.toList().forEach((element) {
          Map<dynamic, dynamic> snap = element;
          updates.add(UpdateInfo.fromEntity(UpdateInfoEntity.fromMap(snap)));
        });
      }
    });

    updates.forEach((element) {
      debugPrint("Element : $element");
    });

    return updates;
  }

}
