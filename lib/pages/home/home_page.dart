import 'package:bando/blocs/group_bloc/group_bloc.dart';
import 'package:bando/blocs/home_bloc/home_bloc.dart';
import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/deleted_files_model.dart';
import 'package:bando/models/file_model.dart';
import 'package:bando/pages/auth/register_group_form.dart';
import 'package:bando/pages/home/lyrics_page.dart';
import 'package:bando/pages/home/widgets/deleting_alert_dialog.dart';
import 'package:bando/pages/home/widgets/download_entire_songbook_widget.dart';
import 'package:bando/pages/home/widgets/empty_songbook_widget.dart';
import 'package:bando/pages/home/widgets/home_header_widget.dart';
import 'package:bando/pages/home/widgets/no_group_widget.dart';
import 'package:bando/pages/profile/profile.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:bando/utils/files_utils.dart';
import 'package:bando/utils/global_keys.dart';
import 'package:bando/utils/util.dart';
import 'package:bando/widgets/animated_opaticy_widget.dart';
import 'package:bando/widgets/loading_widget.dart';
import 'package:bando/widgets/search_textfield.dart';
import 'package:bando/widgets/songbook_listview.dart';
import 'package:bando/widgets/songbook_update_modal_bottom_sheet.dart';
import 'package:bando/widgets/status_info_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:koin_flutter/koin_flutter.dart';
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

  Animation searchFieldAnimation;
  Animation updateStatusInfoAnimation;
  Animation showHideDeletingModeAnimation;
  Animation showHideStatusInfoAnimation;

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
  FileModel _lastLyricsFile;

  final _deletingBarVisibilityProvider = StateProvider<bool>((ref) {
    return false;
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

    searchFieldAnimation = Tween(begin: 0.0, end: 1.0).animate(new CurvedAnimation(
        parent: _statusAndSearchAnimationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    updateStatusInfoAnimation = Tween(begin: 1.0, end: 0.0).animate(new CurvedAnimation(
        parent: _statusAndSearchAnimationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    showHideDeletingModeAnimation = Tween(begin: 0.0, end: 1.0).animate(new CurvedAnimation(
        parent: _deletingModeAnimationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    showHideStatusInfoAnimation = Tween(begin: 1.0, end: 0.0).animate(new CurvedAnimation(
        parent: _deletingModeAnimationController, curve: Curves.easeOutCirc, reverseCurve: Curves.easeInCirc));

    showHideDeletingModeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.reverse)
        context.read(_deletingBarVisibilityProvider).state = false;
      else if (status == AnimationStatus.forward) context.read(_deletingBarVisibilityProvider).state = true;
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

    updateStatusbarAndNavBar(context, showWhiteStatusBarIcons: true);

    _statusInfoWidget = _buildStatusInfo();

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) async {
        if (state is HomeInitialState) {
          await _checkStoragePermission();
        }

        if (state is HomeReadyState) {
          _filesToDelete.clear();
          _deletedFiles.clear();

          context.read(_songbookListProvider).state.clear();
          context.read(_songbookListProvider).state = state.songbook;

          _userName = state.user?.username;
          _groupName = state.group?.name;

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
          if (state.user != null && state.group != null) {
            _userName = state.user.username;
            _groupName = state.group.name;
          }
        }

        if (state is HomeEmptyLocalAndCloudSongbookState) {
          if (state.user != null && state.group != null) {
            _userName = state.user.username;
            _groupName = state.group.name;
          }
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
            body: Builder(builder: (context) {
              return Stack(
                children: <Widget>[
                  Positioned(
                    top: 190,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildMainContent(context, state),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: HomeHeaderWidget(
                      groupName: _groupName,
                      username: _userName,
                      lastLyricsFile: _lastLyricsFile,
                      onLastLyricsFileClick: () {
                        if (_lastLyricsFile != null) _navigateToLyricsPage(_lastLyricsFile);
                      },
                      onProfileClick: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfile()));
                      },
                    ),
                  )
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
      return NoGroupWidget(
        onConfigureGroupClick: () {
          _showGroupForm(context);
        },
      );
    } else if (state is HomeNeedToDownloadTheEntireSongbookState)
      return DownloadTheEntireSongbookWidget(
        onDownloadClick: () {
          _bloc.add(HomeDownloadTheEntireSongbookEvent());
        },
      );
    else if (state is HomeEmptyLocalAndCloudSongbookState)
      return EmptySongbookWidget();
    else
      return SongbookListView(
        key: GlobalKeys.homeSongbookListView,
        songbook: context.read(_songbookListProvider).state,
        onItemClick: (FileModel file) {
          debugPrint("Clicked : ${file.fileName()}");
          _lastLyricsFile = file;
          _navigateToLyricsPage(file);
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

  void _navigateToLyricsPage(FileModel file) async {
    _lastLyricsFile = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LyricsPage(songbook: context.read(_songbookListProvider).state, fileModel: file)));
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
                                  onChanged: context.read(_songbookListProvider).state.isNotEmpty ? onSearch : null,
                                ),
                                alignment: Alignment.bottomRight,
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  hoverColor: Colors.transparent,
                                  icon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyText1.color),
                                  onPressed: () {
                                    if (context.read(_songbookListProvider).state.isNotEmpty) {
                                      showSearchBar = !showSearchBar;
                                      if (!showSearchBar) {
                                        _searchController.clear();
                                        FocusScope.of(context).unfocus();
                                      }
                                      showSearchBar
                                          ? _statusAndSearchAnimationController.forward(from: 0.0)
                                          : _statusAndSearchAnimationController.reverse(from: 1);
                                    }
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
      _bloc.add(HomeInitialEvent());
    });
  }

  void _logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();

    FirebaseAuth.instance.signOut();
  }

  Future<void> _showConfirmDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DeletingAlertDialog(
          filesToDelete: _filesToDelete,
          onCancel: () {
            Navigator.of(context).pop();
            _filesToDelete.clear();
            _deletingModeAnimationController.reverse(from: 1.0);
            GlobalKeys.homeSongbookListView.currentState.clearSelections();
          },
          onConfirm: () {
            _bloc.add(HomeDeleteFilesFromCloudEvent(deletedFiles: _filesToDelete));

            _deletingModeAnimationController.reverse(from: 1.0);
            GlobalKeys.homeSongbookListView.currentState.clearSelections();

            Navigator.pop(context);
          },
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
