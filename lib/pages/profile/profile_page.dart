import 'package:bando/blocs/profile/profile_bloc.dart';
import 'package:bando/models/group_model.dart';
import 'package:bando/models/user_model.dart';
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
        }

        if (state is ProfileInitial) {
          _bloc.add(ProfileLoadAllDataEvent());
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
                                Row(
                                  children: [
                                    Text("Nick : ", style: TextStyle(fontSize: 16.0),),
                                    Text((_user != null) ? _user.username : "?", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {},
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Hasło : ", style: TextStyle(fontSize: 16.0),),
                                    Text( "•••••••••", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {},
                                    )
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height:  48.0),

                            _buildTitle('Członkowie grupy', Icons.group),
                            _buildMembersList(context)
                          ],
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
            itemCount: _group.members.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  color: AppThemes.getSecondAccentColor(context).withOpacity(0.3),
                ),
                child: Row(
                  children: [
                    (index == 0)
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
                        _group.members[index]['username'],
                        style: TextStyle(fontSize: 16.0, color: AppThemes.getSecondAccentColor(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

}
