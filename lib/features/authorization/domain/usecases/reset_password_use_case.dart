import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';

class ResetPasswordUseCase {
  final LoginRepository _loginRepository;

  ResetPasswordUseCase(this._loginRepository);

  Future<Either<Failure, Unit>> call(EmailAddress email) async {
    return await _loginRepository.resetPassword(email);
  }
}