import 'package:bando/blocs/group_bloc/group_bloc.dart';
import 'package:bando/blocs/home_bloc/home_bloc.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/models/file_model.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/utils/files_utils.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/widgets/songbook_listview.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/widgets/status_info_widget.dart';
import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/deleted_files_model.dart';
import 'package:bando/pages/auth_pages/register_group_form.dart';
import 'package:bando/pages/file_manager/library_chooser_page.dart';
import 'package:bando/utils/consts.dart';
import 'package:bando/widgets/loading_widget.dart';
import 'package:bando/widgets/rounded_colored_shadow_button.dart';
import 'package:bando/widgets/search_textfield.dart';
import 'package:bando/widgets/songbook_update_modal_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberHomePage extends StatefulWidget {
  @override
  _MemberHomePageState createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  AnimationController _animationController;
  var searchAnimation;
  var textAnimation;

  final GlobalKey<SongbookListViewState> _songbookGlobalKey = GlobalKey();
  final GlobalKey<StatusInfoWidgetState> _statusInfoGlobalKey = GlobalKey();

  double _fullWidth;
  String _groupName = "------";
  String _userName = "user";
  String _groupId = "";
  bool _needToUpdate = false;
  bool showSearchBar = false;

  HomeBloc _bloc;

  Widget _homeContentWidget;
  BuildContext _scaffoldContext;

  List<DeletedFiles> _updates = List();
  List<FileModel> songbook = List();

  List<FileModel> newLocalFiles = List();
  List<DatabaseLyricsFileInfo> newCloudFiles = List();
  SongbookUpdateType songbookUpdateType;

  @override
  Future<void> initState() {
    super.initState();
    _bloc = BlocProvider.of<HomeBloc>(context);
    _bloc.add(HomeInitialEvent());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    searchAnimation = Tween(begin: 0.0, end: 1.0).animate(
        new CurvedAnimation(parent: _animationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    textAnimation = Tween(begin: 1.0, end: 0.0).animate(
        new CurvedAnimation(parent: _animationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("HOME BUILD");

    _fullWidth = MediaQuery.of(context).size.width;
    updateStatusbar();

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) async {

        if (state is HomeInitialState) {
          _homeContentWidget = LoadingWidget(text: "", loadingType: LoadingType.LOADING);
        }

        if (state is HomeBasicInfoLoadedState) {
          _userName = state.user.username;
          _groupName = state.group.name;
          _groupId = state.group.groupId;

          await _checkStoragePermission();

          _homeContentWidget = LoadingWidget(text: "", loadingType: LoadingType.LOADING);
          _bloc.add(HomeCheckSongbookEvent(groupId: state.group.groupId));
        }

        if (state is HomeReadyState) {
          if (songbook.isEmpty)
            _bloc.add(HomeLoadLocalSongbookEvent());
          else
            _homeContentWidget = _buildMainContent(_scaffoldContext);

          _bloc.add(HomeCheckForDeletedFilesEvent(groupId: _groupId));

          _bloc.add(HomeCheckForNewLocalFilesEvent());

        }

        if (state is HomeNeedToUpdateSongbookState) {
          _needToUpdate = true;
          _updates = state.updates;
          _statusInfoGlobalKey.currentState.updateInfoState(songbookActual: false);

        }

        if (state is HomeSongbookUpdateSuccessState) {
          songbook.clear();
          _bloc.add(HomeLoadLocalSongbookEvent());
        }


        if (state is HomeNeedToDownloadTheEntireSongbookState) {
          _homeContentWidget = _buildDownloadTheEntireSongbookWidget();
        }

        if (state is HomeNeedToUploadLocalSongbookToCloudState) {
          _homeContentWidget = _buildUploadLocalSongbookToCloudWidget();
        }

        if (state is HomeLocalSongbookLoadedState) {
          songbook = List.from(state.songbook);
          _homeContentWidget = _buildMainContent(_scaffoldContext);
        }

        if (state is HomeNoGroupState) {
          _userName = state.user.username;
          _homeContentWidget = _buildNoGroupInfoContent(_scaffoldContext);
        }


        if (state is HomeFailureState) {
          Scaffold.of(_scaffoldContext)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(state.message), Icon(Icons.warning)],
                ),
                backgroundColor: Constants.getErrorColor(context),
              ),
            );
        }

        if (state is HomeGroupConfiguredState) {
          _groupName = state.group.name;
          _bloc.add(HomeInitialEvent());

        }

        if (state is HomeCheckingSongbookCompleteState) {

          newLocalFiles = state.newLocalFiles;
          newCloudFiles = state.newCloudFiles;

          if (newLocalFiles.isEmpty && newCloudFiles.isEmpty) {
            _needToUpdate = false;
            _statusInfoGlobalKey.currentState.updateInfoState(songbookActual: true);
          } else if(newLocalFiles.isNotEmpty && newCloudFiles.isEmpty) {
            _showUpdateInfoBottomSheet(context, SongbookUpdateType.NEW_LOCAL_FILES);
            _statusInfoGlobalKey.currentState.updateInfoState(songbookActual: false);
          } else if(newLocalFiles.isEmpty && newCloudFiles.isNotEmpty) {
            _showUpdateInfoBottomSheet(context, SongbookUpdateType.NEW_CLOUD_FILES);
            _statusInfoGlobalKey.currentState.updateInfoState(songbookActual: false);
          } else if(newLocalFiles.isNotEmpty && newCloudFiles.isNotEmpty) {
            _showUpdateInfoBottomSheet(context, SongbookUpdateType.NEW_LOCAL_CLOUD_FILES);
            _statusInfoGlobalKey.currentState.updateInfoState(songbookActual: false);
          }

        }

        if (state is HomeUploadSongbookSuccessState) {
          _bloc.add(HomeLoadLocalSongbookEvent());
        }

        if(state is HomeShowLoadingState) {
          _homeContentWidget =
              LoadingWidget(text: state.message, loadingType: state.loadingType);
        }

        if (state is HomeSearchResultState) {
          if (_searchController.text.isEmpty)
            _songbookGlobalKey.currentState.updateList(songbook);
          else
            _songbookGlobalKey.currentState.updateList(state.searchResult);

          state.searchResult.forEach((element) {
            debugPrint(element.fileName());
          });
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

  void _showUpdateInfoBottomSheet(BuildContext context, SongbookUpdateType updateType) {

    songbookUpdateType = updateType;
    _needToUpdate = true;

    String locationLocalFiles = "Na urządzeniu";
    String locationCloudFiles = "W chmurze";

    String messageLocalFiles = "udostępnić pliki grupie";
    String messageCloudFiles = "pobrać brakujące pliki";

    String location;
    String message;

    switch(updateType) {
      case SongbookUpdateType.NEW_LOCAL_CLOUD_FILES :
        location = locationLocalFiles + " oraz " + locationCloudFiles.toLowerCase();
        message = messageLocalFiles + " oraz " + messageCloudFiles;
        break;
      case SongbookUpdateType.NEW_LOCAL_FILES :
        location = locationLocalFiles;
        message = messageLocalFiles;
        break;
      case SongbookUpdateType.NEW_CLOUD_FILES :
        location = locationCloudFiles;
        message = messageCloudFiles;
        break;
    }

    showMaterialModalBottomSheet(
      context: context,
      enableDrag: false,
      builder: (context, scrollController) =>
          UpdateSongbookBottomSheet(
            updateType: updateType,
            title: "Aktualizacje",
            message: "$location pojawiły się nowe pliki. Czy chcesz $message?",
            newLocalFiles: newLocalFiles,
            newCloudFiles: newCloudFiles,
            onCancelClick: () {
              Navigator.of(context).pop();
            },
            onUpdateClick: () {
              switch(updateType) {
                case SongbookUpdateType.NEW_LOCAL_FILES :
                  _bloc.add(HomeUploadFilesToCloudEvent(newLocalFiles: newLocalFiles));
                  break;
                case SongbookUpdateType.NEW_CLOUD_FILES :
                  songbook.clear();
                  _bloc.add(HomeDownloadMissingFilesFilesEvent(newCloudFiles: newCloudFiles));
                  break;
                case SongbookUpdateType.NEW_LOCAL_CLOUD_FILES :
                  _bloc.add(HomeUploadFilesToCloudEvent(newLocalFiles: newLocalFiles));
                  _bloc.add(HomeDownloadMissingFilesFilesEvent(newCloudFiles: newCloudFiles));
                  break;
              }
              Navigator.of(context).pop();
            },
          ),
      isDismissible: false,
      expand: false,
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25)),
      ),
      animationCurve: Curves.easeOutCirc,
    );

  }

  Widget _buildMainContent(BuildContext context) {
    return (songbook.isEmpty)
        ? _buildUploadLocalSongbookToCloudWidget()
        : Container(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SongbookListView(
                    key: _songbookGlobalKey,
                    songbook: songbook,
                    onItemClick: (FileModel file) {
                      debugPrint("Clicked : ${file.fileName()}");
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: Material(
                    elevation: 10.0,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shadowColor: (Theme.of(context).brightness == Brightness.light) ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.5) ,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom : 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Align(
                                    child: SearchTextField(
                                      controller: _searchController,
                                      labelText: "Szukaj tekstów..",
                                      width: searchAnimation,
                                      searchBarOutlineFocusColor: Theme.of(context).textTheme.bodyText1.color,
                                      maxWidth: MediaQuery.of(context).size.width - 100,
                                      onChanged: onSearch,
                                    ),
                                    alignment: Alignment.bottomRight,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: IconButton(
                                      hoverColor: Colors.transparent,
                                      icon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyText1.color),
                                      onPressed: () {
                                        showSearchBar = !showSearchBar;
                                        if (!showSearchBar) FocusScope.of(context).unfocus();
                                        showSearchBar
                                            ? _animationController.forward(from: 0.0)
                                            : _animationController.reverse(from: 1);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 20,
                  right: 0,
                  height: 70,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildStatusInfo(),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildStatusInfo() {
    return StatusInfoWidget(
      key: _statusInfoGlobalKey,
      opacityAnimation: textAnimation,
      onUpdatePressed: () {
        if (_needToUpdate) {
          _showUpdateInfoBottomSheet(context, songbookUpdateType);
        }
      },
    );
  }

  onSearch(String query) {
    _bloc.add(
      HomeOnSearchFileEvent(fileName: query, songbook: songbook),
    );
  }

  Widget _buildUploadLocalSongbookToCloudWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Text(
            "Śpiewnik jest pusty",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 26.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
          child: Text(
            "Na urządzeniu został utworzony nowy folder \"BandoSongbook\". Umieść w nim pliki PDF z tekstami. Pliki innego typu niż PDF będą pomijane.",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  _bloc.add(HomeCheckForNewLocalFilesEvent());
                },
                child: Text(
                  "Odśwież".toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20, left: 20),
          child: Text(
            "Zawartość folderu zostanie umieszczona w chmurze i udostępniona wszystkim członkom grupy.",
            style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadTheEntireSongbookWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Text(
            "Pobierz teksty",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 26.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
          child: Text(
            "Grupa posiada w chmurze bibliotekę z tekstami. Pobierz pliki na swoje urządzenie, aby móc korzystać z aplikacji offline.",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white70,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: RaisedButton(
                  onPressed: () {
                    _bloc.add(HomeDownloadTheEntireSongbookEvent());
                  },
                  child: Text(
                    "Pobierz".toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Text(
            "Pobrane pliki zostaną umieszczone w specjalnie utworzonym folderze \"BandoSongbook\".",
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
                shadowColor: Constants.getAccentColor(buildContext),
                iconColor: Constants.getAccentColor(buildContext),
                borderColor: Constants.getAccentColor(buildContext),
                textColor: Constants.getAccentColor(buildContext),
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
      debugPrint("GROUP CONFIGURED ! Update UI");
      _updateUI();
    });
  }

  void _updateUI() async {
    _bloc.add(HomeInitialEvent());
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
                color: (Theme.of(context).brightness == Brightness.light) ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.6) ,
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
                      _logout();
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

  void _logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();

    FirebaseAuth.instance.signOut();
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

  Future<void> _showConfirmUpdateDialog(List<DeletedFiles> updates) async {
    List<String> filesNames = List();
    List<String> dates = List();

    updates.forEach((info) {
      info.files.forEach((element) {
        filesNames.add(element['name']);
      });
      var date = Timestamp.fromMillisecondsSinceEpoch(info.time).toDate();
      dates.add("${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}");
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Text(
                'Nowe teksty',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          content: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 1.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pojawiły się nowe pliki w bibliotece',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Row(
                    children: [
                      Text(
                        (dates.length > 1) ? '${dates[dates.length - 1]} - ${dates[0]}' : '${dates[0]}',
                        style: TextStyle(fontSize: 13.0, color: Colors.grey),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 8, right: 8),
                      child: ListView.builder(
                          itemCount: filesNames.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text("- ${filesNames[index]}"),
                            );
                          }),
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('ANULUJ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'AKTUALIZUJ',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
              ),
              onPressed: () {
//                _selectDir(fileModel);
                _bloc.add(HomeUpdateSongbookEvent(updates: updates));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkStoragePermission() async {
    PermissionStatus storagePermission = await Permission.storage.status;
    debugPrint("Granted ? : ${storagePermission.isGranted}");
    if (!storagePermission.isGranted) {
      await Permission.storage.request();
      await FilesUtils.generateBandoSongbookDirectory();
      return;
    } else {
      await FilesUtils.generateBandoSongbookDirectory();
      return;
    }
  }
}
