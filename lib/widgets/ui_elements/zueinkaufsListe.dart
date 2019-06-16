import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/scoped_models/main.dart';

class ZurEinkaufsListe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (model.wg == null) {
          return Container();
        } else {
          return ListTile(
            leading: Icon(Icons.view_list),
            title: Text('Einkaufsliste'),
            onTap: () {
              
              Navigator.pushReplacementNamed(context,'/wgEinkaufsListe');
            },
          );
        }
      },
    );
  }
}