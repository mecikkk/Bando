import 'dart:convert';

import 'package:bando/core/entities/group.dart';
import 'package:bando/core/errors/exceptions.dart';
import 'package:bando/features/home/data/models/group_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class GroupLocalDataSource {
  Future<Group> getCachedGroupInfo();
  Future<void> cacheGroupInfo(GroupModel group);
}

const CACHED_GROUP_INFO = 'CACHED_GROUP_INFO';


class GroupLocalDataSourceImpl implements GroupLocalDataSource {
  final SharedPreferences sharedPreferences;

  GroupLocalDataSourceImpl({@required this.sharedPreferences});

  @override
  Future<void> cacheGroupInfo(GroupModel group) {
    return sharedPreferences.setString(CACHED_GROUP_INFO, json.encode(group.toJson()));
  }

  @override
  Future<Group> getCachedGroupInfo() {
    final groupInfoJsonString = sharedPreferences.getString(CACHED_GROUP_INFO);
    if (groupInfoJsonString != null && groupInfoJsonString.isNotEmpty)
      return Future.value(GroupModel.fromJson(json.decode(groupInfoJsonString)));
    else
      throw CacheException();
  }

}