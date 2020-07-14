import 'package:bando/file_manager/widgets/file_manager_list_view.dart';
import 'package:bando/home/widgets/fade_on_scroll.dart';
import 'package:bando/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MemberHomePage extends StatefulWidget {

  @override
  _MemberHomePageState createState() => _MemberHomePageState();

}

class _MemberHomePageState extends State<MemberHomePage> {
  double _fullWidth;
  final ScrollController scrollController = ScrollController();

  @override
  Future<void> initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 250,
              floating: false,
              pinned: true,
              titleSpacing: 0.0,
              backgroundColor: Theme.of(context).accentColor,
              brightness: Brightness.dark,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(start: 4, bottom: 14),
                collapseMode: CollapseMode.parallax,
                stretchModes: [StretchMode.zoomBackground, StretchMode.blurBackground],
                title: buildCurrentSongTitleWidget(
                  context,
                  "Każdy się cieszy jak jo dotyko uło o o o",
                  "śpiwenik/blok1",
                ),
                background: FadeOnScroll(
                  scrollController: scrollController,
                  fullOpacityOffset: 0,
                  zeroOpacityOffset: 180,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: Constants.getGradient(context, Alignment.bottomLeft, Alignment.topRight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 25.0,
                        ),
                        buildExpandedTopAppBar("Nazwa zespołu"),
                        buildMembersListWidget(),
                        SizedBox(
                          height: 28,
                          child: Center(
                            child: Container(
                              height: 2,
                              width: MediaQuery.of(context).size.width / 1.1,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        buildSubtitle("Aktualny tekst : "),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: Container(
            decoration: BoxDecoration(
              gradient: Constants.getGradient(context, Alignment.topLeft, Alignment.centerRight),
            ),
            child: FileManagerListView()),
      ),
    );
  }

  Column buildMembersListWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildSubtitle("Członkowie : "),
        SizedBox(
          height: 5,
        ),
        Container(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                buildMemberChip("Tadek", true),
                buildMemberChip("Ziutekkkkkkkkkkkkkkkkkkk", false),
                buildMemberChip("Marian", true),
                buildMemberChip("Władek", false),
                buildMemberChip("Henio", false),
              ],
            ))
      ],
    );
  }

  Widget buildSubtitle(String text) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.white, fontSize: 14.0),
        ),
      ),
    );
  }

  Container buildExpandedTopAppBar(String bandName) {
    return Container(
      height: 70.0,
      width: _fullWidth,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                bandName,
                style: TextStyle(color: Colors.white, fontSize: 24.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(Icons.account_circle, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget buildCurrentSongTitleWidget(BuildContext context, String title, String directory) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 21,
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            height: 31.0,
            width: MediaQuery.of(context).size.width,
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
                  style: TextStyle(color: Colors.white, fontSize: 13.0),
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
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                    Text(
                      // Directory name
                      directory,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white, fontSize: 10.0, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMemberChip(String memberName, bool isOnline) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 0.0),
      child: Container(
        width: 90,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Center(
                    child: Text(
                  memberName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(color: isOnline ? Colors.green : Colors.grey, fontWeight: FontWeight.bold),
                )),
              ),
            ),
            Expanded(
                flex: 1,
                child: Icon(
                  isOnline ? Icons.check : Icons.block,
                  color: isOnline ? Colors.green : Colors.grey,
                  size: 20,
                ))
          ],
        ),
      ),
    );
  }
}
