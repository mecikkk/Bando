import 'package:bando/auth/blocs/register_bloc/register_bloc.dart';
import 'package:bando/auth/pages/register_group_form.dart';
import 'package:bando/file_manager/widgets/file_manager_list_view.dart';
import 'package:bando/home/blocs/home_bloc.dart';
import 'package:bando/home/widgets/fade_on_scroll.dart';
import 'package:bando/utils/consts.dart';
import 'package:bando/widgets/rounded_colored_shadow_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_svg/svg.dart';

class MemberHomePage extends StatefulWidget {
  @override
  _MemberHomePageState createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  double _fullWidth;
  String _groupName = "------";
  String _userName = "user";

  HomeBloc _bloc;

  @override
  Future<void> initState() {
    super.initState();
    _bloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _fullWidth = MediaQuery.of(context).size.width;
    updateStatusbar();

    _loadCurrentUserInfo();

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeReadyState) {
          print("ready state !");
          _userName = state.user.username;
          _groupName = state.group.name;
        }

        if (state is HomeNoGroupState) {
          print("No Group State !");
          _userName = state.user.username;
        }

        if (state is HomeLoadingState) {
          print("Loading state !");
        }

        if (state is HomeFailureState) {
          print("Failure State ! ");
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            body: Builder(
              builder: (scaffoldContext) => Stack(
                children: <Widget>[
                  Positioned(
                    top: 190,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 800),
                      child:
                          (state is HomeNoGroupState) ? _buildNoGroupInfoContent(scaffoldContext) : _buildMainContent(scaffoldContext),
                    ),
                  ),
                  buildHeader(scaffoldContext),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ListView _buildMainContent(BuildContext context) {
    return ListView(
      key: UniqueKey(),
      padding: EdgeInsets.only(top: 30),
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
        ),
      ],
    );
  }

  Padding _buildNoGroupInfoContent(BuildContext buildContext) {
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.only(top: 30.0),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Nie należysz do żadnej grupy. Utwórz nową grupę, lub dołącz do istniejącej.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: SvgPicture.asset(
                "assets/no_group.svg",
                height: 100,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: RoundedColoredShadowButton(
                text: "Dodaj grupę",
                icon: Icons.add,
                height: 40,
                width: 200,
                backgroundColor: Theme.of(buildContext).scaffoldBackgroundColor,
                shadowColor: Constants.getStartGradientColor(buildContext),
                iconColor: Constants.getStartGradientColor(buildContext),
                borderColor: Constants.getStartGradientColor(buildContext),
                textColor: Constants.getStartGradientColor(buildContext),
                onTap: () {
                  Navigator.of(buildContext).push(MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<RegisterBloc>(buildContext),
                            child: RegisterGroupForm(buildContext),
                          )));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Positioned buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      child: Container(
        height: 220,
        width: _fullWidth,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: Constants.getGradient(context, Alignment.centerLeft, Alignment.topRight),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                spreadRadius: 0,
                blurRadius: 15,
                offset: Offset(0, 1),
              ),
            ]),
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                      child: Text(
                        _groupName,
                        style: TextStyle(color: Colors.white, fontSize: 28.0),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, right: 20.0),
                      child: Icon(Icons.account_circle, color: Colors.white),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22.0),
                child: Text(
                  "Witaj $_userName",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              SizedBox(height: 40),
              _buildSubtitle("Aktualny tekst"),
              _buildCurrentSongTitleWidget(
                context,
                "W Krainieckiej dziewczynie każdy się cieszy, jak jo dotyko",
                "śpiewnik/blok1",
              )
            ],
          ),
        ),
      ),
    );
  }

  void updateStatusbar() async {
    await FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  }

  Widget _buildSubtitle(String text) {
    return Container(
      padding: EdgeInsets.only(left: 22.0, bottom: 8),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
    );
  }

  Widget _buildCurrentSongTitleWidget(BuildContext context, String title, String directory) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: SvgPicture.asset(
              "assets/audio-doc.svg",
              height: 30,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              width: _fullWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    // Song Title
                    title,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.folder_open,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                      Text(
                        // Directory name
                        directory,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white70, fontSize: 14.0, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadCurrentUserInfo() async {
    FirebaseAuth.instance.currentUser().then((value) {
      _bloc.add(
        HomeInitialEvent(uid: value.uid),
      );
    });
  }
}
