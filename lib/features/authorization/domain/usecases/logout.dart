import 'package:bando/features/authorization/domain/repositories/auth_repository.dart';

class Logout {
  final AuthRepository _authRepository;

  Logout(this._authRepository);

  Future<void> call() async {
    return await _authRepository.loggOut();
  }
}
