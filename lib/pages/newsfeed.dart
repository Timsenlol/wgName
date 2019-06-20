import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/scoped_models/main.dart';
import 'package:wg_app/widgets/ui_elements/leave_wg.dart';
import 'package:wg_app/widgets/ui_elements/logout_list_tile.dart';
import 'package:wg_app/widgets/ui_elements/meine_wg-ListTile.dart';
import 'package:wg_app/widgets/ui_elements/zueinkaufsListe.dart';

class NewsFeedPage extends StatelessWidget {
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Auswählen'),
          ),
          ZurEinkaufsListe(),
          MeineWgTile(),
          Divider(),
          LogoutListTile(),
          Divider(),
          WgVerlassenListTile()
        ],
      ),
    );
  }
  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      //müssen Bild noch holen
      image: AssetImage('assets/uni.jpg'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.wg == null
          ? Scaffold(
              drawer: _buildSideDrawer(context),
              appBar: AppBar(
                title: Text('Newsfeed'),
              ),
              body: Container(decoration: BoxDecoration(
              image: _buildBackgroundImage(), 
              
            ),child:  Center(
                child: SingleChildScrollView(
                    child: Container(
                        child: Column(
                  children: <Widget>[
                    Text(
                        'Sie sind noch in keiner WG.....erstellen Sie eine eigene oder treten Sie einer bei!!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                            textColor: Colors.white,
                            child: Text('WG erstellen'),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/wgErstellen');
                            }),
                      ),
                      SizedBox(
                        width: 10,
                        ),
                      Expanded(
                          child: RaisedButton(
                              textColor: Colors.white,
                              child: Text('WG beitreten'),
                              onPressed: () {
                                Navigator.of(context).pushNamed('/wgListe');
                                
                              }))
                    ]),
                  ],
                ))),
              ),),
              
              
            )
          : Scaffold(
              drawer: _buildSideDrawer(context),
              appBar: AppBar(
                title: Text('Newsfeed'),
              ),
              body: Container(decoration: BoxDecoration(
              image: _buildBackgroundImage(), 
              
            ),
            child: Center(
                child: Text('WG wurde erkannt/Feed Laden'),
              ),),
              
            );
    });
  }
}
