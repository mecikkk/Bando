import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<Either<Failure, Unit>> call() async {
    return await _authRepository.logout();
  }
}
