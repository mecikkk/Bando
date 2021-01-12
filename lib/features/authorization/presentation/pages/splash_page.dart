import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/features/authorization/presentation/blocs/auth/auth_bloc.dart';
import 'package:bando/features/authorization/presentation/blocs/login/login_bloc.dart';
import 'package:bando/features/authorization/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koin_flutter/koin_flutter.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          systemNavigationBarColor: context.bgColor,
          systemNavigationBarIconBrightness: _setIconsBrightness(context),
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: _setIconsBrightness(context),
          statusBarBrightness: _setIconsBrightness(context)),
    );

    return BlocListener<AuthBloc, AuthState>(
      cubit: get<AuthBloc>()..add(AuthStart()),
      listener: (context, state) {
        if (state is AuthorizedState) {
          debugPrint("Authorized, start home screen | logged in as ${state.user}");
        } else if (state is UnauthorizedState) {
          debugPrint("Unauthorized, show login page");
        } else if (state is SplashScreenState) {
          debugPrint("Initializing, show splash screen");
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is UnauthorizedState)
            return BlocProvider<LoginBloc>(
              create: (context) => get<LoginBloc>(),
              child: LoginPage(),
            );
          else
            return Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    top: 36.0,
                    right: 16.0,
                    child: Image.asset(
                      'assets/logo_transparent.png',
                      scale: _setImageScale(context),
                    ),
                  ),
                ],
              ),
            );
        },
      ),
    );
  }

  double _setImageScale(BuildContext context) => (context.width >= 480) ? 2.5 : 4;

  Brightness _setIconsBrightness(BuildContext context) => context.isLightTheme ? Brightness.light : Brightness.dark;
}
