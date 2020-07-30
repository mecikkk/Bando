import 'dart:io';

import 'package:bando/auth/blocs/group_bloc/group_bloc.dart';
import 'package:bando/auth/pages/register_group_form.dart';
import 'package:bando/file_manager/models/file_model.dart';
import 'package:bando/file_manager/pages/library_chooser_page.dart';
import 'package:bando/file_manager/utils/files_utils.dart';
import 'package:bando/file_manager/widgets/file_item_widget.dart';
import 'package:bando/file_manager/widgets/file_manager_list_view.dart';
import 'package:bando/home/blocs/home_bloc.dart';
import 'package:bando/utils/consts.dart';
import 'package:bando/widgets/loading_widget.dart';
import 'package:bando/widgets/rounded_colored_shadow_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  Widget _homeContentWidget;
  BuildContext _scaffoldContext;

  List<FileModel> songbook = List();

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
      listener: (context, state) async {
        if (state is HomeInitialState) {
          _homeContentWidget = LoadingWidget();
        }

        if (state is HomeReadyState) {
          print("ready state !");
          _userName = state.user.username;
          _groupName = state.group.name;
          _homeContentWidget = _buildMainContent(_scaffoldContext);
        }

        if (state is HomeNoGroupState) {
          print("No Group State !");
          _userName = state.user.username;
          _homeContentWidget = _buildNoGroupInfoContent(_scaffoldContext);
        }

        if (state is HomeLoadingState) {
          print("Loading state !");
          _homeContentWidget = LoadingWidget();
        }

        if (state is HomeFailureState) {
          print("Failure State ! ");
        }

        if (state is HomeGroupConfiguredState) {
          print("Group Configured State ! ");
          _groupName = state.group.name;
        }

        if (state is HomeSelectedDirectoryMovedState) {
          print("Directory moved successful");
          _bloc.add(HomeUploadSongbookToCloudEvent());
        }
        if (state is HomeUploadingSongbookState) {
          _homeContentWidget = LoadingWidget();
        }
        if (state is HomeUploadSongbookSuccessState) {
          print("Uploading success");
          _homeContentWidget = _buildMainContent(_scaffoldContext);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            body: Builder(builder: (scaffoldContext) {
              _scaffoldContext = scaffoldContext;
              return Stack(
                children: <Widget>[
                  Positioned(
                    top: 190,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 800),
                      child: _homeContentWidget,
                    ),
                  ),
                  buildHeader(scaffoldContext),
                ],
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (songbook.isEmpty) loadFilesList();

    return (songbook.isEmpty)
        ? _buildLibraryConfigurationView()
        : Container(
            child: ListView.builder(
              itemCount: songbook.length,
              itemBuilder: (BuildContext context, int index) {
                return new EntryFileItem(songbook[index], context, onClick: (file) {
                  // TODO : on file click reaction
                  print("Click");
                }, onLongClick: () {});
              },
            ),
          );
  }

  loadFilesList() async {
    print("Start Loading local songbook");
    Directory songbookDirectory = await FilesUtils.getSongbookDirectory();
    FilesUtils.getFilesInPath(songbookDirectory.path).then((value) {
      print("getting files ended");
      songbook = value;
      setState(() {
        print("Update UI");
      });
    });
  }

  Widget _buildLibraryConfigurationView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Text(
            "Biblioteka jest pusta.",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 26.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
          child: Text(
            "Wybierz folder, w którym znajdują się pliki PDF z tekstami.",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white70,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: RaisedButton(
                    onPressed: () {
                      _runSongbookDirectoryChooser();
                    },
                    child: Text(
                      "Przeglądaj".toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "/ścieżka/",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.2),
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Text(
            "Zawartość zostanie przeniesiona do specjalnie utworzonego folderu, oraz umieszczona w chmurze.",
            style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  void _runSongbookDirectoryChooser() async {
    var selectedDirectory = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) {
        return LibraryChooser();
      },
      settings: RouteSettings(name: '/', arguments: Map()),
    ));

    _bloc.add(HomeConfigureSongbookDirectoryEvent(
      directoryToMove: selectedDirectory,
    ));
  }

  Padding _buildNoGroupInfoContent(BuildContext buildContext) {
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.only(top: 60.0),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 5),
              child: Text(
                "Nie należysz do żadnej grupy.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15, right: 20, left: 20),
              child: Text(
                "Utwórz nową grupę, lub dołącz do istniejącej.",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: SvgPicture.asset(
                Constants.isLightTheme(context) ? "assets/no_group.svg" : "assets/no_group_dark.svg",
                height: 150,
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
                  _showGroupForm(buildContext);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  _showGroupForm(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<GroupBloc>(context),
          child: RegisterGroupForm(),
        ),
      ),
    ).then((_) {
      print("GROUP CONFIGURED ! Update UI");
      _updateUI();
    });
  }

  void _updateUI() async {
    _bloc.add(HomeInitialEvent(uid: (await FirebaseAuth.instance.currentUser()).uid));
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
