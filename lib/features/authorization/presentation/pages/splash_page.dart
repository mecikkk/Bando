import 'package:bando/core/utils/localization.dart';
import 'package:bando/features/authorization/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koin_flutter/koin_flutter.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: get<AuthBloc>()..add(AuthStart()),
      listener: (context, state) {
        if (state is AuthorizedState) {
          debugPrint("Authorized, start home screen");
        } else if (state is UnauthorizedState) {
          debugPrint("Unauthorized, show login page");
        } else if (state is SplashScreenState) {
          debugPrint("Initializing, show splash screen");
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 100,
              right: 0,
              left: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo_gradient.png',
                    height: 200.0,
                  ),
                  SizedBox(height: 50.0),
                  Text(
                    'Bando',
                    style: TextStyle(fontSize: 38.0),
                  ),
                  Text(
                    AppLocalizations.of(context).translate('splash_subtitle'),
                    style: TextStyle(fontSize: 21.0),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 30,
              right: 30,
              child: Image.asset(
                'assets/logo_gradient.png',
                height: 350.0,
                color: Colors.grey.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
