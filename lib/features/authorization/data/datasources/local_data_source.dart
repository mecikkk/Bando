import 'dart:convert';

import 'package:bando/core/errors/exceptions.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  Future<void> cacheUserInfo(UserModel user);
  Future<UserModel> getUserInfoFromCache();
}

const CACHED_USER_INFO = 'CACHED_USER_INFO';

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({@required this.sharedPreferences});

  @override
  Future<void> cacheUserInfo(UserModel user) {
    return sharedPreferences.setString(CACHED_USER_INFO, json.encode(user.toJson()));
  }

  @override
  Future<UserModel> getUserInfoFromCache() {
    final userInfoJsonString = sharedPreferences.getString(CACHED_USER_INFO);
    if (userInfoJsonString != null && userInfoJsonString.isNotEmpty)
      return Future.value(UserModel.fromJson(json.decode(userInfoJsonString)));
    else
      throw CacheException();
  }
}
