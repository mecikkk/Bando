import 'package:bando/features/authorization/data/datasources/auth_remote_data_source.dart';
import 'package:bando/features/authorization/data/datasources/local_data_source.dart';
import 'package:bando/features/authorization/data/datasources/login_remote_data_source.dart';
import 'package:bando/features/authorization/data/repositories/auth_repository_impl.dart';
import 'package:bando/features/authorization/data/repositories/login_repository_impl.dart';
import 'package:bando/features/authorization/domain/repositories/auth_repository.dart';
import 'package:bando/features/authorization/domain/repositories/login_repository.dart';
import 'package:bando/features/authorization/domain/usecases/check_is_logged_in_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/logout_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/register_with_email_and_password_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/reset_password_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_email_and_password_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_google_use_case.dart';
import 'package:bando/features/authorization/presentation/blocs/auth/auth_bloc.dart';
import 'package:bando/features/authorization/presentation/blocs/login/login_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:koin/koin.dart';
import 'package:shared_preferences/shared_preferences.dart';

var _sharedPreferences;

Future<void> initDi() async {
  _sharedPreferences = await SharedPreferences.getInstance();

  startKoin((app) {
    app.printLogger(level: Level.debug)
      ..modules([authDataSourcesModule, authRepositoriesModule, authUseCasesModule, authBlocsModules]);
  });
}

var authDataSourcesModule = Module()
  ..single<AuthRemoteDataSource>((scope) => AuthRemoteDataSourceImpl(
        firebaseAuth: FirebaseAuth.instance,
        googleSignIn: GoogleSignIn(),
      ))
  ..single<LoginRemoteDataSource>((scope) => LoginRemoteDataSourceImpl(firebaseAuth: FirebaseAuth.instance, googleSignIn: GoogleSignIn()))
  ..single<LocalDataSource>((scope) => LocalDataSourceImpl(sharedPreferences: _sharedPreferences));

var authRepositoriesModule = Module()
  ..single<AuthRepository>((scope) => AuthRepositoryImpl(remoteDataSource: scope.get<AuthRemoteDataSource>(), localDataSource: scope.get<LocalDataSource>()))
  ..single<LoginRepository>((scope) => LoginRepositoryImpl(loginDataSource: scope.get<LoginRemoteDataSource>(), localDataSource: scope.get<LocalDataSource>()));

var authUseCasesModule = Module()
  ..single<CheckIsLoggedInUseCase>((scope) => CheckIsLoggedInUseCase(scope.get<AuthRepository>()))
  ..single<LogoutUseCase>((scope) => LogoutUseCase(scope.get<AuthRepository>()))
  ..single<RegisterWithEmailAndPasswordUseCase>((scope) => RegisterWithEmailAndPasswordUseCase(scope.get<AuthRepository>()))
  ..single<SignInWithEmailAndPasswordUseCase>((scope) => SignInWithEmailAndPasswordUseCase(scope.get<LoginRepository>()))
  ..single<SignInWithGoogleUseCase>((scope) => SignInWithGoogleUseCase(scope.get<LoginRepository>()))
  ..single<ResetPasswordUseCase>((scope) => ResetPasswordUseCase(scope.get<LoginRepository>()));

var authBlocsModules = Module()
  ..single<AuthBloc>((scope) => AuthBloc(scope.get(), scope.get()))
  ..single<LoginBloc>((scope) => LoginBloc(scope.get<SignInWithEmailAndPasswordUseCase>(), scope.get<SignInWithGoogleUseCase>(), scope.get<ResetPasswordUseCase>()));
