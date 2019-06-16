import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/scoped_models/main.dart';

import 'package:flutter/material.dart';
import 'package:wg_app/widgets/ui_elements/leave_wg.dart';
import 'package:wg_app/widgets/ui_elements/logout_list_tile.dart';
import 'package:wg_app/widgets/ui_elements/meine_wg-ListTile.dart';
import 'package:wg_app/widgets/ui_elements/zueinkaufsListe.dart';

class MeineWgPage extends StatelessWidget {
  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      //müssen Bild noch holen
      image: AssetImage('assets/uni.jpg'),
    );
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.announcement),
            title: Text('Newsfeed'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ZurEinkaufsListe(),
          Divider(),
          LogoutListTile(),
          Divider(),
          WgVerlassenListTile()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        drawer: _buildSideDrawer(context),
          appBar: AppBar(
            title: Text('Meine Wg'),
          ),
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                image: _buildBackgroundImage(),
              ),
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Email:',
                            style: Theme.of(context).textTheme.title),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(model.user.email,
                          style: Theme.of(context).textTheme.title),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Wg Name :',
                            style: Theme.of(context).textTheme.title),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        model.wg.wgName,
                        style: Theme.of(context).textTheme.title,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Wg Passwort :',
                            style: Theme.of(context).textTheme.title),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        model.wg.pwd,
                        style: Theme.of(context).textTheme.title,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Wg id :',
                            style: Theme.of(context).textTheme.title),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        model.wg.id,
                        style: Theme.of(context).textTheme.title,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ));
    });
  }
}
