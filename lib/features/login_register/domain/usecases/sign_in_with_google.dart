import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/login_register/domain/repositories/login_register_repository.dart';
import 'package:dartz/dartz.dart';

class SignInWithGoogle {
  final LoginRegisterRepository loginRepository;

  SignInWithGoogle(this.loginRepository);

  Future<Either<Failure, User>> call() async {
    return await loginRepository.signInWithGoogle();
  }
}
