import 'package:bando/blocs/group_bloc/group_bloc.dart';
import 'package:bando/blocs/register_bloc/register_bloc.dart';
import 'package:bando/pages/auth_pages/register_form.dart';
import 'package:bando/pages/auth_pages/register_group_form.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:bando/utils/util.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koin_flutter/koin_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RegisterPage extends StatelessWidget {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    updateStatusbarAndNavBar(context, showWhiteStatusBarIcons: !AppThemes.isLightTheme(context));

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
            child: MultiBlocProvider(
              providers: [
                BlocProvider<RegisterBloc>(create: (context) => get<RegisterBloc>()),
                BlocProvider<GroupBloc>(create: (context) => get<GroupBloc>())
              ],
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  RegisterForm(pageController: _pageController),
                  RegisterGroupForm(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            width: MediaQuery.of(context).size.width,
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
                    activeDotColor: AppThemes.getSecondAccentColor(context)),
              ),
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
                        offset: Offset(0, 0),
                        color: Colors.black.withOpacity(0.5),
                      )
                    ]),
                child: Center(
                  child: Text("Brak połączenia z internetem"),
                ),
              ),
              builder: (context, isOnline) {
                return SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}
