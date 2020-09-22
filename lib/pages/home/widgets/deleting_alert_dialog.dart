import 'package:bando/models/file_model.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeletingAlertDialog extends StatelessWidget {

  final List<FileModel> filesToDelete;
  final Function onCancel;
  final Function onConfirm;

  DeletingAlertDialog({@required this.filesToDelete, @required this.onCancel, @required this.onConfirm});

  @override
  Widget build(BuildContext context) {
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
                      itemCount: filesToDelete.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            "✖ ${filesToDelete[index].fileName()}",
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
          onPressed: onCancel
        ),
        FlatButton(
          child: Text(
            'USUŃ',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppThemes.getStartColor(context)),
          ),
          onPressed: onConfirm
        ),
      ],
    );
  }


}