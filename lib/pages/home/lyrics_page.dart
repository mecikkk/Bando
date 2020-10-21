import 'package:bando/blocs/udp/udp_bloc.dart';
import 'package:bando/models/file_model.dart';
import 'package:bando/models/udp_message.dart';
import 'package:bando/pages/home/widgets/quic_lyrics_switcher.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:bando/utils/files_utils.dart';
import 'package:bando/utils/global_keys.dart';
import 'package:bando/widgets/loading_widget.dart';
import 'package:bando/widgets/songbook_listview.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:koin_flutter/koin_flutter.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SyncMode { AUTO, MANUAL }

class LyricsPage extends StatefulWidget {
  final FileModel fileModel;
  final List<FileModel> songbook;

  final List<double> invertColors = [
    //R  G   B    A  Const
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ];

  LyricsPage({@required this.fileModel, @required this.songbook});

  @override
  State<StatefulWidget> createState() {
    return LyricsPageState();
  }
}

class LyricsPageState extends State<LyricsPage> with SingleTickerProviderStateMixin {
  bool _isDarkMode;
  bool _loading = true;
  bool _showOptions = true;

  bool _isLeader = false;
  SyncMode _syncMode;

  TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UdpBloc _bloc;

  Flushbar _flushbar;
  Widget _pdfViewer;
  FileModel currentFile;
  FileModel previousFile;
  FileModel nextFile;
  List<FileModel> songbook;

  @override
  void initState() {
    super.initState();
    _getLyricsBrightnessMode();
    currentFile = widget.fileModel;
    _loadSongbook();
    _syncMode = SyncMode.MANUAL;
    _bloc = get<UdpBloc>()..add(UdpGetSyncModeEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD LYRICS PAGE");
    Future.delayed(Duration(milliseconds: 600), () {
      updateStatusbarAndNavBar(context, _isDarkMode);
    });

    return BlocListener<UdpBloc, UdpState>(
      cubit: _bloc,
      listener: (context, state) async {
        if (state is UdpDataReceivedState) {
          debugPrint("Received some data : ${state.udpMessage}");

          FileModel receivedLyrics =
              songbook.firstWhere((element) => element.localPath.contains(state.udpMessage.songbookPath));

          if (receivedLyrics != null) {
            if (!_isLeader && _syncMode == SyncMode.AUTO) {
              currentFile = receivedLyrics;
              _reloadCurrentPreviousAndNextFile();
            } else if (!_isLeader && _syncMode == SyncMode.MANUAL) {
              debugPrint("Isflushbar visible : ${_flushbar?.isShowing()}");

              if(_flushbar != null && _flushbar.isShowing())
                await _flushbar.dismiss();

              _flushbar = Flushbar(
                    title: "Przysłano nowy tekst",
                    message: "${receivedLyrics.fileName()}",
                    duration: const Duration(seconds: 30),
                    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                    borderRadius: 8.0,
                    margin: EdgeInsets.all(8.0),
                    animationDuration: const Duration(milliseconds: 450),

                    mainButton: FlatButton(
                      child: Text("ZMIEŃ", style: TextStyle(color: AppThemes.getStartColor(context)),),
                      onPressed: () {
                        currentFile = receivedLyrics;
                        _reloadCurrentPreviousAndNextFile();
                        Navigator.pop(context);
                      },
                    ),
                    flushbarPosition: FlushbarPosition.TOP,
                  );

                  _flushbar.show(_scaffoldKey.currentContext);


            }
          } else {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                margin: EdgeInsets.only(bottom: 45.0),
                content: Text(
                  'Nie znaleziono pliku ${state.udpMessage.fileName}',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }

        if (state is UdpGetSyncModeResultState) {
          _syncMode = state.syncMode;
          setState(() {});

          _scaffoldKey.currentState?.showSnackBar(SnackBar(
            backgroundColor: AppThemes.getPositiveGreenColor(context),
            margin: EdgeInsets.only(bottom: 75.0, left: 16.0, right: 16.0),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    (_syncMode == SyncMode.AUTO) ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                    color: Colors.black,
                  ),
                ),
                Text(
                  (_syncMode == SyncMode.AUTO) ? "Automatyczna synchronizacja" : "Ręczna synchronizacja",
                ),
              ],
            ),
          ));
        }

        if (state is UdpMemberModeState) {
          _isLeader = false;
        }

        if (state is UdpLeaderModeState) {
          _isLeader = true;
        }
      },
      child: BlocBuilder<UdpBloc, UdpState>(
        cubit: _bloc,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: _onWillPop,
            child: _loading
                ? LoadingWidget(loadingType: LoadingType.LOADING)
                : Scaffold(
                    key: _scaffoldKey,
                    backgroundColor: (_isDarkMode) ? Colors.black : Colors.white,
                    body: Stack(
                      children: [
                        Positioned(
                          top: 24.0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _isDarkMode
                              ? ColorFiltered(
                                  colorFilter: ColorFilter.matrix(widget.invertColors),
                                  child:
                                      AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: _pdfViewer),
                                )
                              : AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: _pdfViewer),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showOptions = !_showOptions;
                              });
                            },
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCirc,
                          top: _showOptions ? 0 : -100,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            height: 90,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 35.0, top: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${currentFile.fileName()}",
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                      style:
                                          TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: 18.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            _isDarkMode ? Icons.brightness_7_rounded : Icons.brightness_3_rounded,
                                            color: _isDarkMode ? Colors.white : Colors.black,
                                          ),
                                          onPressed: () {
                                            _changeLyricsBrightnessMode();
                                          },
                                        ),
                                        IconButton(
                                          icon: (_syncMode == SyncMode.MANUAL)
                                              ? Icon(
                                                  Icons.sync_disabled_rounded,
                                                  color: _isDarkMode ? Colors.white : Colors.black,
                                                )
                                              : Icon(
                                                  Icons.sync_rounded,
                                                  color: _isDarkMode ? Colors.white : Colors.black,
                                                ),
                                          onPressed: () {
                                            _changeSyncMode();
                                          },
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          curve: Curves.easeOutCirc,
                          bottom: (_syncMode == SyncMode.AUTO)
                              ? -60
                              : (_showOptions)
                                  ? 80
                                  : 25,
                          right: 25.0,
                          child: (_isLeader)
                              ? FloatingActionButton(
                                  child: Icon(Icons.send_rounded),
                                  backgroundColor: AppThemes.getStartColor(context),
                                  onPressed: () {
                                    if (_isLeader && (_syncMode == SyncMode.MANUAL)) _sendInfoAboutChangedCurrentFile();
                                  },
                                )
                              : SizedBox(),
                          duration: const Duration(milliseconds: 760),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 750),
                          curve: Curves.easeOutCirc,
                          bottom: _showOptions ? 0 : -100,
                          left: 0.0,
                          right: 0.0,
                          child: Column(
                            children: [
                              Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      offset: Offset(0, -5),
                                      blurRadius: 45,
                                      spreadRadius: 1,
                                    )
                                  ],
                                  color: _isDarkMode ? Color(0xff27272b) : Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          (previousFile != null)
                                              ? QuickLyricsSwitcher(
                                                  position: SwitcherPosition.LEFT,
                                                  lyricsName: previousFile.fileName(),
                                                  color: _isDarkMode ? Colors.white : Colors.black,
                                                  onClick: () {
                                                    debugPrint("Previous lyrics <- ");
                                                    if (previousFile != null) {
                                                      currentFile = previousFile;
                                                      _reloadCurrentPreviousAndNextFile();
                                                      if (_isLeader && (_syncMode == SyncMode.AUTO))
                                                        _sendInfoAboutChangedCurrentFile();
                                                    }
                                                  })
                                              : SizedBox(),
                                          (nextFile != null)
                                              ? QuickLyricsSwitcher(
                                                  position: SwitcherPosition.RIGHT,
                                                  lyricsName: nextFile.fileName(),
                                                  color: _isDarkMode ? Colors.white : Colors.black,
                                                  onClick: () {
                                                    debugPrint("Next lyrics -> ");
                                                    if (nextFile != null) {
                                                      currentFile = nextFile;
                                                      _reloadCurrentPreviousAndNextFile();

                                                      if (_isLeader && (_syncMode == SyncMode.AUTO))
                                                        _sendInfoAboutChangedCurrentFile();
                                                    }
                                                  })
                                              : SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 850),
                          curve: Curves.easeOutCirc,
                          bottom: _showOptions ? 60 : 0,
                          left: 0.0,
                          right: 0.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.more_horiz, size: 30),
                                color: _isDarkMode ? Colors.white : Colors.black,
                                onPressed: () {
                                  _showBottomSheet(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  void _changeSyncMode() {
    _bloc.add(UdpChangeSyncModeEvent(syncMode: (_syncMode == SyncMode.MANUAL) ? SyncMode.AUTO : SyncMode.MANUAL));
  }

  void _sendInfoAboutChangedCurrentFile() {
    _bloc.add(UdpSendDataEvent(
      udpMessage: UdpMessage(
        fileName: currentFile.fileName(),
        songbookPath: currentFile.localPath,
      ),
    ));
  }

  Future<bool> _onWillPop() async {
    if (_isLeader)
      Navigator.of(context).pop(currentFile);
    else
      Navigator.of(context).pop(null);

    return true;
  }

  void _showBottomSheet(BuildContext context) {
    final bottomSheetContent = Container(
      height: MediaQuery.of(context).size.height / 1.2,
      child: Stack(
        children: [
          Positioned(
            top: 5,
            left: 0,
            right: 0,
            child: Icon(
              Icons.more_horiz,
              color: Colors.grey,
              size: 30,
            ),
          ), // TODO : Zaimplementować wyszukiwanie
          Positioned(
              top: 45,
              left: 35,
              right: 35,
              child: Text(
                "Wszystkie teksty",
                style: TextStyle(fontSize: 18.0, color: _isDarkMode ? Colors.white : Colors.black87),
              )),
          Positioned(
            top: 75,
            left: 0,
            right: 0,
            bottom: 0,
            child: SongbookListView(
              key: GlobalKeys.lyricsPageSongbookListView,
              songbook: widget.songbook,
              onItemClick: (FileModel file) {
                currentFile = file;
                _reloadCurrentPreviousAndNextFile();
                if (_isLeader && (_syncMode == SyncMode.AUTO)) _sendInfoAboutChangedCurrentFile();
                Navigator.pop(context);
              },
              onItemLongClick: () {},
              customColor: _isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );

    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      builder: (BuildContext context) => bottomSheetContent,
      backgroundColor: _isDarkMode ? Color(0xff27272b) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25)),
      ),
    );
  }

  void _loadSongbook() async {
    songbook = await FilesUtils.getOnlyFilesFromLocalSongbook(widget.songbook);
    _reloadCurrentPreviousAndNextFile();
  }

  void _updatePdfView() {
    setState(() {
      debugPrint("Updating pdf : filename : ${currentFile.fileName()}");
      _pdfViewer = PdfViewer(
        key: UniqueKey(),
        filePath: currentFile.fileSystemEntity.path,
      );
    });
  }

  void _reloadCurrentPreviousAndNextFile() {
    int currentFileIndex = songbook.indexOf(currentFile);
    debugPrint("CurrentFileIndex : $currentFileIndex | songbookLength : ${songbook.length}");
    if ((currentFileIndex == 0) && (songbook.length > currentFileIndex + 1)) {
      previousFile = null;
      nextFile = songbook[currentFileIndex + 1];
    } else if (currentFileIndex > 0 && songbook.length > currentFileIndex + 1) {
      previousFile = songbook[currentFileIndex - 1];
      nextFile = songbook[currentFileIndex + 1];
    } else if (currentFileIndex > 0 && songbook.length - 1 == currentFileIndex) {
      previousFile = songbook[currentFileIndex - 1];
      nextFile = null;
    } else {
      previousFile = null;
      nextFile = null;
    }

    _updatePdfView();
  }

  void _changeLyricsBrightnessMode() {
    SharedPreferences.getInstance().then((pref) {
      debugPrint("IsDarkMode : field : $_isDarkMode | pref : ${pref.get('lyrics_dark_mode')}");

      _isDarkMode = !_isDarkMode;

      pref.setBool('lyrics_dark_mode', _isDarkMode).then((value) {
        setState(() {
          _loading = false;
        });
      });
    });
  }

  void _getLyricsBrightnessMode() {
    SharedPreferences.getInstance().then((pref) {
      _isDarkMode = pref.get('lyrics_dark_mode');

      if (_isDarkMode == null) _isDarkMode = false;

      setState(() {
        _loading = false;
      });
    });
  }

  Future updateStatusbarAndNavBar(BuildContext context, bool showLightStatusbarIcons) async {
    await FlutterStatusbarcolor.setStatusBarColor(showLightStatusbarIcons ? Colors.black : Colors.white);
    await FlutterStatusbarcolor.setStatusBarWhiteForeground(showLightStatusbarIcons);
    await FlutterStatusbarcolor.setNavigationBarColor(
        showLightStatusbarIcons ? Theme.of(context).scaffoldBackgroundColor : Colors.white);
    await FlutterStatusbarcolor.setNavigationBarWhiteForeground(showLightStatusbarIcons);

    return;
  }
}
