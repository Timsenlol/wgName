import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/pages/addkuehlschrank_image.dart';
import 'package:wg_app/pages/auth.dart';
import 'package:wg_app/pages/einkaufsListe.dart';
import 'package:wg_app/pages/item_hinzuf%C3%BCgen.dart';
import 'package:wg_app/pages/k%C3%BChlschrank.dart';
import 'package:wg_app/pages/meine_wg.dart';
import 'package:wg_app/pages/newsfeed.dart';
import 'package:wg_app/pages/wg_erstellen.dart';
import 'package:wg_app/pages/wg_list.dart';
import 'package:wg_app/scoped_models/main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;
  @override
  void initState() {
    _model.autoAuth();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : NewsFeedPage(),
          '/wgErstellen': (BuildContext context) => WgErstellenPage(),
          '/meineWg': (BuildContext context) => MeineWgPage(),
          '/wgListe': (BuildContext context) => WgListPage(_model),
          '/wgEinkaufsListe': (BuildContext context) => EinkaufsListePage(_model),
          '/kühl': (BuildContext context) => KuehschrankPage(),
          '/addkühl': (BuildContext context) => AddKuehlschrankImagePage(),
         '/additem': (BuildContext context) =>ItemHinzuefugenPage()
          
        },
      ),
    );
  }
}
