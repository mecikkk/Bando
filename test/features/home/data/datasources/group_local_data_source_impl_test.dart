import 'dart:convert';
import 'dart:io';

import 'package:bando/features/home/data/datasources/group_local_data_source.dart';
import 'package:bando/features/home/data/models/group_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

main() {
  GroupLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = GroupLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });


  group('GroupLocalDataSource tests - ', () {
    final jsonGroup = File('test/fixtures/group.json').readAsStringSync();
    final group = GroupModel.fromJson(json.decode(jsonGroup));

    test('should return GroupModel from SharedPreferences', () async {
      //arrange
      when(mockSharedPreferences.getString(any)).thenReturn(jsonGroup);
      //act
      final result = await dataSource.getCachedGroupInfo();
      //assert
      expect(result, group);
    });

  });
}