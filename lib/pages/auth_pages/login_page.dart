import 'package:bando/blocs/login_bloc/login_bloc.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:bando/utils/util.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koin_flutter/koin_flutter.dart';

import 'login_form.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    updateStatusbarAndNavBar(context);

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
              create: (context) => get<LoginBloc>(),
              child: LoginForm(),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ConnectivityWidget(
              offlineBanner: Container(
                height: 34,
                decoration: BoxDecoration(
                    color: AppThemes.errorColorDark,
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: Offset(0,0),
                        color: Colors.black.withOpacity(0.5),
                      )
                    ]
                ),
                child: Center(
                  child: Text("Brak połączenia z internetem"),
                ),
              ),
              builder: (context, isOnline) {
                return SizedBox(
                );
              },
            ),
          )
        ],
      ),
    );
  }

}