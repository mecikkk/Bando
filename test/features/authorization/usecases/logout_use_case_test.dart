import 'package:bando/features/authorization/domain/repositories/auth_repository.dart';
import 'package:bando/features/authorization/domain/usecases/logout_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final repository = MockAuthRepository();
  final usecase = LogoutUseCase(repository);

  group('LogoutUseCase tests - ', () {
    test('should invoke sign out method from repository', () {
      usecase.call();

      verify(repository.logout());
      verifyNoMoreInteractions(repository);
    });
  });
}
