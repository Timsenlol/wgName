import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as prefix0;
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/scoped_models/main.dart';

class LogoutListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logut'),
          onTap: () {
            // Navigator.pop(context);

            model.logout().then((_) {});

            Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

            //Navigator.of(context).pushReplacementNamed('/');
          },
        );
      },
    );
  }
}
