import 'package:bando/models/deleted_files_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseRepository {
  Future<void> addDeletionInfo(String groupId, String userName, List<Map<String, dynamic>> deletedFilesInfo) async {
    DateTime currentDate = DateTime.now();
    var milliseconds = Timestamp.fromDate(currentDate).millisecondsSinceEpoch;
    String dateId =
        "${currentDate.day}-${currentDate.month}-${currentDate.year}x${currentDate.hour}:${currentDate.minute}:${currentDate.second}";

    return FirebaseDatabase.instance.reference().child(groupId).child("deleted").child(dateId).set(new DeletedFiles(
          time: milliseconds,
          whoDeleted: userName,
          files: deletedFilesInfo,
        ).toJson());
  }

  Future<List<DeletedFiles>> getDeletedFiles(String groupId, int lastUpdate) async {
    List<Map<dynamic, dynamic>> snapshots = List();
    List<DeletedFiles> updates = List();

    try {
      await FirebaseDatabase.instance
          .reference()
          .child(groupId)
          .child("deleted")
          .orderByChild('time')
          .startAt(lastUpdate + 1)
          .once()
          .then((value) => snapshots.add(value.value));

      snapshots.forEach((element) {
        if (element != null) {
          element.values.toList().forEach((element) {
            Map<dynamic, dynamic> snap = element;
            updates.add(DeletedFiles.fromMap(snap));
          });
        }
      });
    } catch (e) {
      print("-- RealtimeDatabaseRepository | Getting deletes info error : $e");
    }

    return updates;
  }

  // TODO : Utowrzyc nowego bloca ? Zeby w czasie rzeczywistym obserwowac zmiany, kto jest leaderem, kto moze zmieniac teksty
  Future<DatabaseReference> getCurrentLeader(String groupId) async =>
      FirebaseDatabase.instance.reference().child(groupId).child('current_leader');

  Future<void> setCurrentLeader(String groupId, String uid) async {
    return await FirebaseDatabase.instance.reference().child(groupId).child('current_leader').set({
      'currentLeader' : uid
    });
  }
}
