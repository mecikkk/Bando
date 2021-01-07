import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/repositories/registration_repository.dart';
import 'package:dartz/dartz.dart';

class RegisterWithEmailAndPasswordUseCase {
  final RegistrationRepository _repository;

  RegisterWithEmailAndPasswordUseCase(this._repository);

  Future<Either<Failure, User>> call(EmailAddress email, Password password, String username) async {
    return await _repository.registerWithEmailAndPassword(email, password, username);
  }
}
