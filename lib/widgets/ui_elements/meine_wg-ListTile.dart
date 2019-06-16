import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/scoped_models/main.dart';

class MeineWgTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (model.wg == null) {
          return Container();
        } else {
          return ListTile(
            leading: Icon(Icons.home),
            title: Text('Meine Wg'),
            onTap: () {
              
              Navigator.of(context).pushReplacementNamed('/meineWg');
            },
          );
        }
      },
    );
  }
}
