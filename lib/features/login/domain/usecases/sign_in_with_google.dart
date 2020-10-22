import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/login/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';

class SignInWithGoogle {
  final LoginRepository loginRepository;

  SignInWithGoogle(this.loginRepository);

  Future<Either<Failure, User>> call() async {
    return await loginRepository.signInUserWithGoogle();
  }
}
