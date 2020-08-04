import 'package:bando/auth/models/update_info_model.dart';
import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseRepository {

  Future<void> addUpdateInfo(String groupId, String userName, List<Map<String, dynamic>> updatedFiles) async {
    DateTime currentDate = DateTime.now();
    String dateId = "${currentDate.day}-${currentDate.month}-${currentDate.year}x${currentDate.hour}:${currentDate.minute}:${currentDate.second}";
    return FirebaseDatabase.instance
        .reference()
        .child(groupId)
        .child("updates")
        .child(dateId)
        .set(new UpdateInfo(
          time: currentDate.toString(),
          whoUpdated: userName,
          operation: "ADD",
          files: updatedFiles,
        ).toEntity().toJson());
  }
}
