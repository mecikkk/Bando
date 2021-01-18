import 'dart:io';

import 'package:bando/core/errors/exceptions.dart';
import 'package:bando/features/authorization/data/datasources/local_data_source.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPrefereces extends Mock implements SharedPreferences {}

void main() {
  LocalDataSourceImpl dataSourceImpl;
  MockSharedPrefereces sharedPrefereces;
  UserModel user;
  setUp(() {
    sharedPrefereces = MockSharedPrefereces();
    dataSourceImpl = LocalDataSourceImpl(sharedPreferences: sharedPrefereces);
    user = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
  });

  group('LocalDataSource tests - ', () {
    test('should cache user info in shared preferences', () async {
      when(sharedPrefereces.setString(CACHED_USER_INFO, any)).thenAnswer((_) async => true);

      await dataSourceImpl.cacheUserInfo(user);

      verify(sharedPrefereces.setString(CACHED_USER_INFO, any));
    });

    test('should get cached user info from shared preferences', () async {
      final sharedPreferencesJson = File('test/fixtures/correct_user.json').readAsStringSync();
      when(sharedPrefereces.getString(CACHED_USER_INFO)).thenAnswer((_) => sharedPreferencesJson);

      final cachedUser = await dataSourceImpl.getUserInfoFromCache();

      expect(cachedUser, equals(user));
    });

    test('should throw CacheException when try to get cached user info from shared preferences', () async {
      final sharedPreferencesJson = '';
      when(sharedPrefereces.getString(CACHED_USER_INFO)).thenAnswer((_) => sharedPreferencesJson);

      final call = dataSourceImpl.getUserInfoFromCache;

      expect(() => call(), throwsA(isInstanceOf<CacheException>()));
    });

    test('should throw FormatException when try to get cached user info from shared preferences', () async {
      final sharedPreferencesJson = '[{]{]da';
      when(sharedPrefereces.getString(CACHED_USER_INFO)).thenAnswer((_) => sharedPreferencesJson);

      final call = dataSourceImpl.getUserInfoFromCache;

      expect(() => call(), throwsA(isInstanceOf<FormatException>()));
    });
  });
}
