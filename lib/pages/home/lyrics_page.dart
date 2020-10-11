import 'package:bando/blocs/udp/udp_bloc.dart';
import 'package:bando/models/file_model.dart';
import 'package:bando/models/udp_message.dart';
import 'package:bando/pages/home/widgets/quic_lyrics_switcher.dart';
import 'package:bando/utils/files_utils.dart';
import 'package:bando/widgets/loading_widget.dart';
import 'package:bando/widgets/songbook_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:koin_flutter/koin_flutter.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UdpBloc _bloc;

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
    _bloc = get<UdpBloc>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 600), () {
      updateStatusbarAndNavBar(context, _isDarkMode);
    });

    return BlocListener<UdpBloc, UdpState>(
      cubit: _bloc,
      listener: (context, state) {
        if (state is UdpDataReceivedState) {
          debugPrint("Received some data : ${state.udpMessage}");

          FileModel receivedLyrics =
              songbook.firstWhere((element) => element.localPath.contains(state.udpMessage.songbookPath));
          if (receivedLyrics != null) {
            currentFile = receivedLyrics;
            _reloadCurrentPreviousAndNextFile();
          } else {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text(
                  'Nie znaleziono pliku ${state.udpMessage.fileName}',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
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
                              debugPrint("Tapped");
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
                              padding: const EdgeInsets.only(left: 35.0, top: 45),
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
                                          TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: 21.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: IconButton(
                                      icon: Icon(
                                        _isDarkMode ? Icons.brightness_7 : Icons.brightness_3,
                                        color: _isDarkMode ? Colors.white : Colors.black,
                                      ),
                                      onPressed: () {
                                        _bloc.add(UdpStartListeningEvent());
                                        //_changeLyricsBrightnessMode();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 750),
                          curve: Curves.easeOutCirc,
                          bottom: _showOptions ? 0 : -110,
                          left: 0.0,
                          right: 0.0,
                          child: Column(
                            children: [
                              Container(
                                height: 70,
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

                                                      _bloc.add(UdpSendDataEvent(
                                                        udpMessage: UdpMessage(
                                                          fileName: currentFile.fileName(),
                                                          songbookPath: currentFile.localPath,
                                                        ),
                                                      ));
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

                                                      //   _scaffoldKey.currentState.showSnackBar(
                                                      //       SnackBar(
                                                      //         content: Row(
                                                      //             children: [
                                                      //         Text("Wysyłam : ${currentFile.fileName()}"),
                                                      //         ],
                                                      //       )
                                                      //   ),
                                                      // );

                                                      _bloc.add(UdpSendDataEvent(
                                                        udpMessage: UdpMessage(
                                                          fileName: currentFile.fileName(),
                                                          songbookPath: currentFile.localPath,
                                                        ),
                                                      ));
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
                          left: 0.0,
                          right: 0.0,
                          bottom: _showOptions ? 70 : 0,
                          child: IconButton(
                            icon: Icon(Icons.more_horiz, size: 30),
                            color: _isDarkMode ? Colors.white : Colors.black,
                            onPressed: () {
                              _showBottomSheet(context);
                            },
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

  Future<bool> _onWillPop() async {
    // TODO : Zwracac aktualny tekst tylko od leadera. Dzieki temu reszta grupy po powrocie na ekran glowny nie straci aktualnego tekstu.
    // TODO : Przetestowac czy jak nie zwroce nic, to na home bedzie aktualny tekst z bloca <- to chyba nie przejdzie bo bedzie nasluchiwanie wylaczone u leadera... xd
    Navigator.of(context).pop(currentFile);
    return true;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height / 1.25,
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
            ),
            Positioned(
              top: 35,
              left: 35,
              right: 35,
              child: Text(
                "Wszystkie teksty",
                style: TextStyle(
                  fontSize: 21.0,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Positioned(
              top: 85,
              left: 0,
              right: 0,
              bottom: 0,
              child: SongbookListView(
                songbook: widget.songbook,
                onItemClick: (FileModel file) {
                  currentFile = file;
                  _reloadCurrentPreviousAndNextFile();
                  Navigator.pop(context);
                },
                onItemLongClick: () {},
                customColor: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
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

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarIconBrightness: Brightness.dark));

    return;
  }
}
