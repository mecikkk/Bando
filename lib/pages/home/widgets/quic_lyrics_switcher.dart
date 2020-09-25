import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SwitcherPosition { LEFT, RIGHT }

class QuickLyricsSwitcher extends StatelessWidget {
  final SwitcherPosition position;
  final String lyricsName;
  final Color color;
  final Function onClick;

  QuickLyricsSwitcher({@required this.position, @required this.lyricsName, @required this.color, @required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding:
            (position == SwitcherPosition.LEFT) ? const EdgeInsets.only(left: 8.0) : const EdgeInsets.only(right: 8.0),
        child: InkWell(
          onTap: onClick,
          splashColor: Colors.grey.withOpacity(0.5),
          child: (position == SwitcherPosition.LEFT)
              ? Row(
                  children: [
                    _buildArrowWidget(),
                    _buildLyricsNameWidget(context),
                  ],
                )
              : Row(
                  children: [
                    _buildLyricsNameWidget(context),
                    _buildArrowWidget(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLyricsNameWidget(BuildContext context) => Container(
        width: (MediaQuery.of(context).size.width / 3.5),
        height: 50,
        child: Align(
          alignment: (position == SwitcherPosition.LEFT) ? Alignment.centerLeft : Alignment.centerRight,
          child: Text(
            lyricsName,
            textAlign: (position == SwitcherPosition.LEFT) ? TextAlign.start : TextAlign.end,
            overflow: TextOverflow.fade,
            softWrap: false,
            maxLines: 1,
            style: TextStyle(color: color, fontSize: 16.0),
          ),
        ),
      );

  Widget _buildArrowWidget() => Padding(
        padding: (position == SwitcherPosition.LEFT) ? const EdgeInsets.only(right: 8.0) : const EdgeInsets.only(left: 8.0),
        child: Icon(
          (position == SwitcherPosition.RIGHT) ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          color: color,
        ),
      );
}
