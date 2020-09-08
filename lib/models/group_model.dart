
import 'package:bando/entities/group_entity.dart';

class Group {

  final String name;
  final String groupId;
  final List<Map<String, dynamic>> members;

  Group(this.groupId, {this.name = 'Group', this.members});

  Group copyWith({String groupId, String name, List<Map<String, dynamic>> members}) {
    return Group(
      groupId ?? this.groupId,
      name : name ?? this.name,
      members: members ?? this.members,
    );
  }

  @override
  int get hashCode => groupId.hashCode ^ name.hashCode ^ members.hashCode;


  @override
  bool operator == (other) =>
      identical(this, other) ||
          other is Group &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              groupId == other.groupId &&
              members == other.members;


  @override
  String toString() {
    return "Group(name : $name, groupId : $groupId, members : $members)";
  }

  GroupEntity toEntity() {
    return GroupEntity(groupId, name, members);
  }

  static Group fromEntity(GroupEntity entity) {
    return Group(
        entity.groupId,
        name : entity.name,
        members: entity.members,
    );
  }
}