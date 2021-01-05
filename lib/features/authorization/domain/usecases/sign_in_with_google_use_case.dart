import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';

class SignInWithGoogleUseCase {
  final LoginRepository _loginRepository;

  SignInWithGoogleUseCase(this._loginRepository);

  Future<Either<Failure, User>> call() async {
    return await _loginRepository.signInWithGoogle();
  }
}
