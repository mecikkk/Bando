import 'package:bando/auth/blocs/login_bloc/login_bloc.dart';
import 'package:bando/auth/pages/login_form.dart';
import 'package:bando/auth/repository/auth_repository.dart';
import 'package:bando/utils/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koin_flutter/koin_flutter.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Constants.updateNavBarTheme(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 28,
            right: 10,
            child: Container(
              child: SvgPicture.asset(
                "assets/logo.svg",
                height: 250,
                color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.03),
              ),
            ),
          ),
          Container(
            child: BlocProvider<LoginBloc>(
              create: (context) => LoginBloc(authRepository: get<AuthRepository>()),
              child: LoginForm(),
            ),
          ),
        ],
      ),
    );
  }
}
