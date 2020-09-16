import 'package:bando/blocs/group_bloc/group_bloc.dart';
import 'package:bando/blocs/home_bloc/home_bloc.dart';
import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/deleted_files_model.dart';
import 'package:bando/models/file_model.dart';
import 'package:bando/pages/auth_pages/register_group_form.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:bando/utils/files_utils.dart';
import 'package:bando/utils/global_keys.dart';
import 'package:bando/utils/util.dart';
import 'package:bando/widgets/animated_opaticy_widget.dart';
import 'package:bando/widgets/gradient_raised_button.dart';
import 'package:bando/widgets/loading_widget.dart';
import 'package:bando/widgets/rounded_colored_shadow_button.dart';
import 'package:bando/widgets/search_textfield.dart';
import 'package:bando/widgets/songbook_listview.dart';
import 'package:bando/widgets/songbook_update_modal_bottom_sheet.dart';
import 'package:bando/widgets/status_info_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koin_flutter/koin_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();

  AnimationController _statusAndSearchAnimationController;
  AnimationController _deletingModeAnimationController;
  AnimationController _loadingWidgetAnimationController;

  Animation searchFieldAnimation;
  Animation updateStatusInfoAnimation;
  Animation showHideDeletingModeAnimation;
  Animation showHideStatusInfoAnimation;
  Animation _loadingWidgetAnimation;

  double _fullWidth;
  String _groupName = "------";
  String _userName = "user";
  bool _needToUpdate = false;
  bool showSearchBar = false;

  HomeBloc _bloc;

  Widget _statusInfoWidget;
  BuildContext _scaffoldContext;

  List<DeletedFiles> _deletedFiles = List();
  List<FileModel> _filesToDelete = List();
  List<FileModel> newLocalFiles = List();
  List<DatabaseLyricsFileInfo> newCloudFiles = List();
  SongbookUpdateType songbookUpdateType;

  final _deletingBarVisibilityProvider = StateProvider<bool>((ref) {
    return false;
  });

  final _loadingWidgetVisibilityProvider = StateProvider<bool>((ref) {
    return true;
  });

  final _songbookListProvider = StateProvider<List<FileModel>>((ref) {
    return List();
  });

  @override
  Future<void> initState() {
    super.initState();

    _bloc = get<HomeBloc>()..add(HomeInitialEvent());

    _statusAndSearchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _deletingModeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _loadingWidgetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    searchFieldAnimation = Tween(begin: 0.0, end: 1.0).animate(new CurvedAnimation(
        parent: _statusAndSearchAnimationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    updateStatusInfoAnimation = Tween(begin: 1.0, end: 0.0).animate(new CurvedAnimation(
        parent: _statusAndSearchAnimationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    showHideDeletingModeAnimation = Tween(begin: 0.0, end: 1.0).animate(new CurvedAnimation(
        parent: _deletingModeAnimationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    showHideStatusInfoAnimation = Tween(begin: 1.0, end: 0.0).animate(new CurvedAnimation(
        parent: _deletingModeAnimationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    _loadingWidgetAnimation = Tween(begin: 0.0, end: 1.0).animate(new CurvedAnimation(
        parent: _loadingWidgetAnimationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    showHideDeletingModeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.reverse)
        context.read(_deletingBarVisibilityProvider).state = false;
      else if (status == AnimationStatus.forward) context.read(_deletingBarVisibilityProvider).state = true;
    });

    _loadingWidgetAnimation.addStatusListener((status) {
      if (status == AnimationStatus.forward) context.read(_loadingWidgetVisibilityProvider).state = true;

      if (status == AnimationStatus.dismissed) context.read(_loadingWidgetVisibilityProvider).state = false;

      debugPrint(
          "LoadingANimState : ${status} | loadingVisibility : ${context.read(_loadingWidgetVisibilityProvider).state}");
    });

    return null;
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
    _searchController.dispose();
    _deletingModeAnimationController.dispose();
    _statusAndSearchAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeBuild');
    _fullWidth = MediaQuery.of(context).size.width;
    updateStatusbarAndNavBar(context);
    _statusInfoWidget = _buildStatusInfo();

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) async {
        if (state is HomeInitialState) await _checkStoragePermission();

        if (state is HomeReadyState) {
          _filesToDelete.clear();
          _deletedFiles.clear();

          context.read(_songbookListProvider).state.clear();
          context.read(_songbookListProvider).state = state.songbook;

          _userName = state.user.username;
          _groupName = state.group.name;

          _bloc.add(HomeCheckForDeletedFilesEvent());
        }

        if (state is HomeReloadSongbook) {
          context.read(_songbookListProvider).state.clear();
          context.read(_songbookListProvider).state = state.songbook;
        }

        if (state is HomeReloadSongbookAndHideUpdatesInfo) {
          context.read(_songbookListProvider).state.clear();
          context.read(_songbookListProvider).state = state.songbook;

          _needToUpdate = false;
          _deletedFiles.clear();
          GlobalKeys.homeStatusInfo.currentState.updateInfoState(songbookActual: true);

          _bloc.add(HomeCheckForAnyUpdatesEvent());
        }

        if (state is HomeNeedToDeleteFilesLocallyState) {
          _needToUpdate = true;
          _deletedFiles = state.updates;
          GlobalKeys.homeStatusInfo.currentState.updateInfoState(songbookActual: false);
          _showUpdateInfoBottomSheet(context, SongbookUpdateType.DELETED_FILES);
        }

        if (state is HomeNeedToDownloadTheEntireSongbookState) {
          _userName = state.user.username;
          _groupName = state.group.name;
        }

        if (state is HomeNeedToUploadLocalSongbookToCloudState) {
          _userName = state.user.username;
          _groupName = state.group.name;
        }

        if (state is HomeStartCheckingUpdatesState) {
          _bloc.add(HomeCheckForAnyUpdatesEvent());
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
                backgroundColor: AppThemes.getErrorColor(context),
              ),
            );
        }

        if (state is HomeCheckingSongbookCompleteState) {
          newLocalFiles = state.newLocalFiles;
          newCloudFiles = state.newCloudFiles;

          SongbookUpdateType updateType;

          if (newLocalFiles.isEmpty && newCloudFiles.isEmpty) {
            _needToUpdate = false;
            GlobalKeys.homeStatusInfo.currentState.updateInfoState(songbookActual: true);
          } else {
            if (newLocalFiles.isNotEmpty && newCloudFiles.isEmpty) {
              updateType = SongbookUpdateType.NEW_LOCAL_FILES;
            } else if (newLocalFiles.isEmpty && newCloudFiles.isNotEmpty) {
              updateType = SongbookUpdateType.NEW_CLOUD_FILES;
            } else if (newLocalFiles.isNotEmpty && newCloudFiles.isNotEmpty) {
              updateType = SongbookUpdateType.NEW_LOCAL_CLOUD_FILES;
            }

            _showUpdateInfoBottomSheet(context, updateType);
          }
        }

        if (state is HomeUploadSongbookSuccessState) {
          _needToUpdate = false;
          GlobalKeys.homeStatusInfo.currentState.updateInfoState(songbookActual: true);
        }

        if (state is HomeSearchResultState) {
          if (_searchController.text.isEmpty)
            GlobalKeys.homeSongbookListView.currentState.updateList(context.read(_songbookListProvider).state);
          else
            GlobalKeys.homeSongbookListView.currentState.updateList(state.searchResult);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          debugPrint("_____________ Build whole ui");
          return Scaffold(
            body: Builder(builder: (scaffoldContext) {
              _scaffoldContext = scaffoldContext;
              return Stack(
                children: <Widget>[
                  Positioned(top: 190, left: 0, right: 0, bottom: 0, child: _buildMainContent(context, state)),
                  buildHeader(scaffoldContext),
                ],
              );
            }),
          );
        },
      ),
    );
  }

  Widget _switchMainContent(HomeState state) {
    if (state is HomeShowLoadingState) {
      return LoadingWidget(text: state.message, loadingType: state.loadingType);
    } else if (state is HomeInitialState) {
      return LoadingWidget(loadingType: LoadingType.LOADING);
    } else if (state is HomeNoGroupState) {
      _userName = state.user.username;
      return _buildNoGroupInfoContent(_scaffoldContext);
    } else if (state is HomeNeedToDownloadTheEntireSongbookState)
      return _buildDownloadTheEntireSongbookWidget();
    else if (state is HomeNeedToUploadLocalSongbookToCloudState)
      return _buildEmptyLocalAndCloudSongbookWidget();
    else
      return SongbookListView(
        key: GlobalKeys.homeSongbookListView,
        songbook: context.read(_songbookListProvider).state,
        onItemClick: (FileModel file) {
          debugPrint("Clicked : ${file.fileName()}");
          _filesToDelete.forEach((element) {
            debugPrint("${element.fileName()}");
          });
        },
        onItemLongClick: (FileModel file, bool isSelected) {
          debugPrint("Long clicked : ${file.fileName()} selected ? $isSelected");
          isSelected ? _filesToDelete.add(file) : _filesToDelete.remove(file);

          if (_filesToDelete.isNotEmpty && _deletingModeAnimationController.value != 1.0)
            _deletingModeAnimationController.forward(from: 0.0);
          else if (_filesToDelete.isEmpty && _deletingModeAnimationController.value == 1.0)
            _deletingModeAnimationController.reverse(from: 1.0);
        },
      );
  }

  void _showUpdateInfoBottomSheet(BuildContext context, SongbookUpdateType updateType) {
    songbookUpdateType = updateType;
    _needToUpdate = true;

    GlobalKeys.homeStatusInfo.currentState.updateInfoState(songbookActual: false);

    String locationLocalFiles = "Na urządzeniu";
    String locationCloudFiles = "W chmurze";

    String messageLocalFiles = "udostępnić pliki grupie";
    String messageCloudFiles = "pobrać brakujące pliki";

    String location;
    String message;

    switch (updateType) {
      case SongbookUpdateType.NEW_LOCAL_CLOUD_FILES:
        location = locationLocalFiles + " oraz " + locationCloudFiles.toLowerCase();
        message = messageLocalFiles + " oraz " + messageCloudFiles;
        break;
      case SongbookUpdateType.NEW_LOCAL_FILES:
        location = locationLocalFiles;
        message = messageLocalFiles;
        break;
      case SongbookUpdateType.NEW_CLOUD_FILES:
        location = locationCloudFiles;
        message = messageCloudFiles;
        break;
      default:
        break;
    }

    showMaterialModalBottomSheet(
      context: context,
      enableDrag: false,
      builder: (context, scrollController) => UpdateSongbookBottomSheet(
        updateType: updateType,
        title: "Aktualizacje",
        message: "$location pojawiły się nowe pliki. Czy chcesz $message?",
        newLocalFiles: newLocalFiles,
        newCloudFiles: newCloudFiles,
        deletedCloudFiles: _deletedFiles,
        onCancelClick: () {
          Navigator.of(context).pop();
        },
        onUpdateClick: () {
          switch (updateType) {
            case SongbookUpdateType.NEW_LOCAL_FILES:
              _bloc.add(HomeUploadFilesToCloudEvent(newLocalFiles: newLocalFiles));
              break;
            case SongbookUpdateType.NEW_CLOUD_FILES:
              _bloc.add(HomeDownloadMissingFilesFilesEvent(newCloudFiles: newCloudFiles));
              break;
            case SongbookUpdateType.NEW_LOCAL_CLOUD_FILES:
              _bloc.add(HomeUploadFilesToCloudEvent(newLocalFiles: newLocalFiles));
              _bloc.add(HomeDownloadMissingFilesFilesEvent(newCloudFiles: newCloudFiles));
              break;
            case SongbookUpdateType.DELETED_FILES:
              _bloc.add(HomeDeleteLocalFilesEvent(deletedFiles: _deletedFiles));
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

  Widget _buildMainContent(BuildContext context, HomeState state) {
    debugPrint("---- Build Main Content !");
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _switchMainContent(state),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: AnimatedOpacityWidget(
              opacity: showHideStatusInfoAnimation,
              child: Material(
                elevation: 10.0,
                color: Theme.of(context).scaffoldBackgroundColor,
                shadowColor: (Theme.of(context).brightness == Brightness.light)
                    ? Colors.black.withOpacity(0.25)
                    : Colors.black.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Align(
                                child: SearchTextField(
                                  controller: _searchController,
                                  labelText: "Szukaj tekstów..",
                                  width: searchFieldAnimation,
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
                                        ? _statusAndSearchAnimationController.forward(from: 0.0)
                                        : _statusAndSearchAnimationController.reverse(from: 1);
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
          ),
          Positioned(
            top: 30,
            left: 20,
            right: 0,
            height: 70,
            child: AnimatedOpacityWidget(
              opacity: showHideStatusInfoAnimation,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _statusInfoWidget,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Consumer(
              builder: (context, watch, child) {
                return Visibility(
                  visible: watch(_deletingBarVisibilityProvider).state,
                  child: AnimatedOpacityWidget(
                    opacity: showHideDeletingModeAnimation,
                    child: Material(
                      elevation: 10.0,
                      color: Colors.redAccent,
                      shadowColor: (Theme.of(context).brightness == Brightness.light)
                          ? Colors.black.withOpacity(0.25)
                          : Colors.black.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Align(
                                      child: IconButton(
                                        hoverColor: Colors.transparent,
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.black,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          _filesToDelete.clear();
                                          _deletingModeAnimationController.reverse(from: 1.0);
                                          GlobalKeys.homeSongbookListView.currentState.clearSelections();
                                        },
                                      ),
                                      alignment: Alignment.bottomLeft,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
                                      child: Align(
                                        child: Text(
                                          "Usuwanie plików",
                                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                                        ),
                                        alignment: Alignment.bottomLeft,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                        hoverColor: Colors.transparent,
                                        icon: Icon(
                                          Icons.delete_forever,
                                          color: Colors.black,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          _showConfirmDeleteDialog();
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    return StatusInfoWidget(
      key: GlobalKeys.homeStatusInfo,
      opacityAnimation: updateStatusInfoAnimation,
      onUpdatePressed: () {
        if (_needToUpdate) {
          _showUpdateInfoBottomSheet(context, songbookUpdateType);
        }
      },
    );
  }

  onSearch(String query) {
    _bloc.add(
      HomeOnSearchFileEvent(fileName: query, songbook: context.read(_songbookListProvider).state),
    );
  }

  Widget _buildEmptyLocalAndCloudSongbookWidget() {
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
                  _bloc.add(HomeCheckForAnyUpdatesEvent());
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

  Padding _buildNoGroupInfoContent(BuildContext context) {
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
                "Nie należysz do żadnej grupy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15, right: 20, left: 20),
              child: Text(
                "Utwórz nową grupę, lub dołącz do istniejącej",
                style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Lottie.asset(
                "assets/no_group_animation.json",
                repeat: true,
                width: 150,
                height: 150,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: GradientRaisedButton(
                text: "Grupa",
                height: 40,
                width: 200.0,
                colors: [AppThemes.getStartColor(context), AppThemes.getSecondAccentColor(context), AppThemes.getSecondAccentColor(context)],
                onPressed: () {
                  _showGroupForm(context);
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
            gradient: AppThemes.getGradient(context, Alignment.centerLeft, Alignment.topRight),
            boxShadow: [
              BoxShadow(
                color: (Theme.of(context).brightness == Brightness.light)
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.6),
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
                      WidgetsBinding.instance.drawFrame();
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

  Future<void> _showConfirmDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Usuń pliki',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          content: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height / 2.5,
              width: MediaQuery.of(context).size.width / 1.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Czy chcesz trwale usunąć teksty ? Zaznaczone pliki zostaną usunięte z twojego urządzenia, oraz z chmury.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 8, right: 8, bottom: 16.0),
                      child: ListView.builder(
                          itemCount: _filesToDelete.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                "✖ ${_filesToDelete[index].fileName()}",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            );
                          }),
                    ),
                  ),
                  Text(
                    'Członkowie zespołu otrzymają powiadomienie o usuniętych plikach, oraz zostaną poproszeni o zaktualizowanie swoich lokalnych plików.',
                    style: TextStyle(fontSize: 13.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('ANULUJ'),
              onPressed: () {
                Navigator.of(context).pop();
                _filesToDelete.clear();
                _deletingModeAnimationController.reverse(from: 1.0);
                GlobalKeys.homeSongbookListView.currentState.clearSelections();
              },
            ),
            FlatButton(
              child: Text(
                'USUŃ',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppThemes.getStartColor(context)),
              ),
              onPressed: () {
                _bloc.add(HomeDeleteFilesFromCloudEvent(deletedFiles: _filesToDelete));

                _deletingModeAnimationController.reverse(from: 1.0);
                GlobalKeys.homeSongbookListView.currentState.clearSelections();

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
