import 'package:bando/core/entities/group.dart';
import 'package:bando/core/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'file:///D:/Android/Bando/FlutterProject/bando/lib/features/home/domain/repositories/group_repository.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/features/home/domain/usecases/groups/create_new_group_use_case.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  MockGroupRepository mockGroupRepository;
  CreateNewGroupUseCase usecase;
  User user;
  final String groupName = "SomeGroup";
  Group newGroup;

  setUp(() {
    mockGroupRepository = MockGroupRepository();
    usecase = CreateNewGroupUseCase(mockGroupRepository);
    user = User(uid: "SomeFakeUid", displayName: "SomeFakeUsername", groupId: '');
    newGroup = Group(name: groupName, leaderId: "SomeFakeUid", members: [user]);
  });

  group('CreateNewGroupUseCase tests - ', ()  {

    test('should return created group entity from repository', () async {
      //arrange
      when(mockGroupRepository.createNewGroup(user, groupName)).thenAnswer((_) async => Right(newGroup));
      //act
      final result = await usecase.call(user : user, groupName: groupName);

      //assert
      expect(result, Right(newGroup));
      verify(mockGroupRepository.createNewGroup(user, groupName));
      verifyNoMoreInteractions(mockGroupRepository);
    });

  });

}