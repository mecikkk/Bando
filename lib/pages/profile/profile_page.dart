import 'dart:ui';

import 'package:bando/blocs/profile/profile_bloc.dart';
import 'package:bando/models/group_model.dart';
import 'package:bando/models/user_model.dart';
import 'package:bando/pages/profile/widgets/dialog_widget.dart';
import 'package:bando/pages/profile/widgets/expandable_edit_panel.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:bando/utils/util.dart';
import 'package:bando/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  ProfileBloc _bloc;
  User _user;
  Group _group;
  bool _isLeader = false;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    debugPrint("InitState Profile ");
    _bloc = BlocProvider.of<ProfileBloc>(context)..add(ProfileInitialEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateStatusbarAndNavBar(context, showWhiteStatusBarIcons: true);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        debugPrint("LISTENER STATE : $state");

        if (state is ProfileDataLoadedState) {
          _user = state.user;
          _group = state.group;

          _isLeader = (_group.leaderID == _user.uid) ? true : false;
        }

        if (state is ProfileInitial) {
          _bloc.add(ProfileLoadAllDataEvent());
        }

        if (state is ProfileLogoutSuccessState) {
          Navigator.pop(context, true);
        }

        if (state is ProfileLeaderChangedSuccessfullyState) {
          _bloc.add(ProfileInitialEvent());
        }

        if (state is ProfileUserDataUpdateSuccessState) {
          _bloc.add(ProfileInitialEvent());
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
        debugPrint("BUILD PROFILE UI | state : $state");
        return Scaffold(
          body: (state is ProfileLoadingState)
              ? LoadingWidget(loadingType: LoadingType.LOADING)
              : Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 240,
                      child: Container(
                        padding: const EdgeInsets.only(top: 45.0),
                        decoration: BoxDecoration(
                          gradient: AppThemes.getGradient(context, Alignment.topRight, Alignment.bottomLeft),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Zalogowano jako",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              (_user != null) ? _user.username : "Użytkownik",
                              style: TextStyle(fontSize: 26.0, color: Colors.white, shadows: [
                                Shadow(
                                  offset: Offset(0, 0),
                                  blurRadius: 20,
                                )
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 16,
                      child: IconButton(
                        icon: Icon(
                          Icons.power_settings_new,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          debugPrint("Logout");
                          _bloc.add(ProfileLogoutEvent());
                        },
                      ),
                    ),
                    Positioned(
                      top: 180,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                            color: Theme.of(context).backgroundColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, -3),
                                blurRadius: 40,
                                spreadRadius: 0.5,
                              )
                            ]),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 56.0, bottom: 8),
                                  child: Text(
                                    (_group != null) ? _group.name : "Grupa",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.0),
                              _buildTitle('Twoje dane', Icons.person),
                              SizedBox(height: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ExpandableEditPanel(
                                    header: Row(
                                      children: [
                                        Text(
                                          "Nick : ",
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        Text(
                                          (_user != null) ? _user.username : "?",
                                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    controller: _usernameController,
                                    textFieldLabel: "Nowy nick",
                                    textFieldIcon: Icons.person,
                                    onConfirmClick: () {
                                      if (_usernameController.text.isNotEmpty)
                                        _showConfirmChangeUserNameDialog(context, _usernameController.text);
                                    },
                                  ),
                                  SizedBox(height: 15.0),
                                  ExpandableEditPanel.password(
                                    // TODO : Potrzebna reautentykacja, (dodac tutaj, wyswietlic dialog czy cos z podaniem maila, starego hasla i nowego hasla)
                                    header: Row(
                                      children: [
                                        Text(
                                          "Hasło : ",
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        Text(
                                          "•••••••••",
                                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    controller: _passwordController,
                                    textFieldLabel: "Nowe hasło",
                                    textFieldIcon: Icons.lock_rounded,
                                    onConfirmClick: () {
                                      if (_passwordController.text.isNotEmpty)
                                        _showConfirmChangePasswordDialog(context, _passwordController.text);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 48.0),
                              _buildTitle('Członkowie grupy', Icons.group),
                              _buildMembersList(context),
                              _isLeader
                                  ? Text(
                                      "Przytrzymaj nazwę użytkownika, któremu chcesz oddać rolę lidera.\nOddając rolę lidera innej osobie stracisz możliwość decydowania, jaki tekst ma zostać wyświetlony grupie.",
                                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 120,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black45,
                                offset: Offset(0, 5),
                                blurRadius: 20,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: (_group != null)
                              ? RepaintBoundary(
                                  key: _globalKey,
                                  child: Column(
                                    children: <Widget>[
                                      QrImage(
                                        data: _group.groupId,
                                        size: 130,
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: 130,
                                  width: 130,
                                ),
                        ),
                      ),
                    )
                  ],
                ),
        );
      }),
    );
  }

  Row _buildTitle(String title, IconData icon) => Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).textTheme.bodyText1.color,
            size: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      );

  Padding _buildMembersList(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: (_group != null) ? _group.members.length : 0,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onLongPress: () {
                  if (_isLeader && _group.members[index]['uid'] != _group.leaderID)
                    _showConfirmChangeLeaderDialog(context, _group.members[index]);
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    color: AppThemes.getSecondAccentColor(context).withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      (_group.members[index]['uid'] == _group.leaderID)
                          ? (AppThemes.isLightTheme(context))
                              ? SvgPicture.asset(
                                  'assets/crown.svg',
                                  height: 16,
                                  color: AppThemes.getSecondAccentColor(context),
                                )
                              : SvgPicture.asset('assets/crown.svg', height: 16)
                          : Icon(
                              Icons.person,
                              size: 16,
                              color: AppThemes.isLightTheme(context)
                                  ? AppThemes.getSecondAccentColor(context)
                                  : Colors.amberAccent,
                            ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          (_group != null) ? _group.members[index]['username'] : 'Użytkownik',
                          style: TextStyle(fontSize: 16.0, color: AppThemes.getSecondAccentColor(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  void _showConfirmChangeLeaderDialog(BuildContext context, Map<String, dynamic> newLeader) {
    showDialog(
      context: context,
      builder: (context) => DialogWidget(
        title: "Nowy lider",
        content: RichText(
          textAlign: TextAlign.center,
          text:
              TextSpan(style: TextStyle(fontSize: 16.0, color: Theme.of(context).textTheme.bodyText1.color), children: [
            TextSpan(text: "Czy chcesz oddać rolę lidera użytkownikowi "),
            TextSpan(
                text: "${newLeader['username']} ?",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppThemes.getStartColor(context))),
          ]),
        ),
        onAcceptClick: () {
          _bloc.add(ProfileChangeLeaderEvent(newLeaderId: newLeader['uid']));
        },
      ),
    );
  }

  void _showConfirmChangeUserNameDialog(BuildContext context, String newUsername) {
    showDialog(
      context: context,
      builder: (context) => DialogWidget(
        title: "Nowy Nick",
        content: RichText(
          textAlign: TextAlign.center,
          text:
              TextSpan(style: TextStyle(fontSize: 16.0, color: Theme.of(context).textTheme.bodyText1.color), children: [
            TextSpan(text: "Chcesz zmienić swoją nazwę użytkownika na "),
            TextSpan(
                text: "$newUsername ?",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppThemes.getStartColor(context))),
          ]),
        ),
        onAcceptClick: () {
          _bloc.add(ProfileChangeUsernameEvent(newUsername: newUsername));
        },
      ),
    );
  }

  void _showConfirmChangePasswordDialog(BuildContext context, String password) {
    showDialog(
      context: context,
      builder: (context) => DialogWidget(
        title: "Zmiana hasła",
        content: Text("Czy na pewno chcesz zmienić swoje hasło ?"),
        onAcceptClick: () {
          _bloc.add(ProfileChangePasswordEvent(password: password));
        },
      ),
    );
  }
}
