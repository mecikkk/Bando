import 'package:bando/auth/blocs/register_bloc/register_bloc.dart';
import 'package:bando/auth/pages/register_group_form.dart';
import 'package:bando/auth/pages/register_form.dart';
import 'package:bando/auth/repository/auth_repository.dart';
import 'package:bando/auth/repository/firestore_group_repository.dart';
import 'package:bando/auth/repository/firestore_user_repository.dart';
import 'package:bando/utils/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:koin_flutter/koin_flutter.dart';

class RegisterPage extends StatelessWidget {

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    Constants.updateNavBarTheme(
        context);

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
                color: Theme
                    .of(
                    context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(
                    0.03),
              ),
            ),
          ),
          Container(
            child: BlocProvider<RegisterBloc>(
              create: (context) =>
                  RegisterBloc(
                    authRepository: get<AuthRepository>(),
                    userRepository: get<FirestoreUserRepository>(),
                    groupRepository: get<FirestoreGroupRepository>(),
                  ),
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  RegisterForm(pageController: _pageController),
                  RegisterGroupForm(context),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            width: MediaQuery
                .of(
                context)
                .size
                .width,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 2,
                effect: WormEffect(
                    spacing: 8.0,
                    radius: 10.0,
                    dotWidth: 10.0,
                    dotHeight: 10.0,
                    paintStyle: PaintingStyle.stroke,
                    strokeWidth: 0,
                    dotColor: Colors.grey,
                    activeDotColor: Constants.getEndGradientColor(
                        context)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}