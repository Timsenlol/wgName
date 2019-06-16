import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/models/wg.dart';
import 'package:wg_app/pages/wg_beitreten.dart';
import 'package:wg_app/scoped_models/main.dart';

import 'package:flutter/material.dart';

class WgListPage extends StatefulWidget {
  final MainModel model;
  WgListPage(this.model);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WgListPageState();
  }
}

class _WgListPageState extends State<WgListPage> {
  String name;
  List<Wg> wgs = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  initState() {
    widget.model.fetchWgs();

    super.initState();
  }

  final Map<String, dynamic> _formData = {
    'wgName': null,
  };

  Widget _buildEnterButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.input),
      onPressed: () {
        model.selectWg(wgs[index].id);
        wgs.clear();
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return WgBeitretenPage();
            },
          ),
        );
      },
    );
  }

  Widget _buildNameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Suche nach dem Wg Namen',
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Bitte geben Sie einen Wg Namen ein';
        }
      },
      onSaved: (String value) {
        _formData['wgName'] = value;
      },
    );
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      image: AssetImage('assets/uni.jpg'),
    );
  }

  Widget _buildContextSuche(MainModel model) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
        appBar: AppBar(
          title: Text('Wg Suchen'),
        ),
        body: Container(
            decoration: BoxDecoration(
              image: _buildBackgroundImage(),
            ),
            padding: EdgeInsets.all(10.0),
            child: Center(
                child: SingleChildScrollView(
                    child: Container(
                        width: targetWidth,
                        child: Form(
                            key: _formKey,
                            child: Column(children: <Widget>[
                              _buildNameTextField(),
                              SizedBox(
                                height: 10.0,
                              ),
                              _buildRaisedButton(model)
                            ])))))));
  }

  Widget _buildRaisedButton(MainModel model) {
    return model.isloading
        ? CircularProgressIndicator()
        : RaisedButton(
            textColor: Colors.white,
            child: Text('Suchen'),
            onPressed: () {
              setState(() {
                _formKey.currentState.save();
                if (!_formKey.currentState.validate()) {
                  return;
                }
                String _wgname = _formData['wgName'];
                model.allwgs.forEach((Wg wgforeach) {
                  if (wgforeach.wgName.toUpperCase() == _wgname.toUpperCase()) {
                    wgs.add(wgforeach);
                  }
                });
                if (wgs.isEmpty) {
                   showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Keine Wg gefunden'),
                          content:
                              Text('Es wurde keine Wg mit diesem Namen gefunden'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('ok'),
                              onPressed: () {
                             
                                  
                                  Navigator.pop(context, false)
                                      ;
                               
                              },
                            )
                          ],
                        );
                      });
                }
              });
            },
          );
  }

  Widget _buildwgList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/wgsuche.jpg'),
                  ),
                  title: Text(wgs[index].wgName),
                  trailing: _buildEnterButton(context, index, model),
                ),
                Divider()
              ],
            );
          },
          itemCount: wgs.length,
        );
      },
    );
  }

  Widget _buildContextListe() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return WillPopScope (
          onWillPop: () async{
            setState(() {
              wgs.clear();
              
             
            });
            return wgs.isEmpty;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Wgs'),
            ),
            body: Container(
                decoration: BoxDecoration(
                  image: _buildBackgroundImage(),
                ),
                child: _buildwgList()),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (wgs.isEmpty) {
        return _buildContextSuche(model);
      } else {
        return _buildContextListe();
      }
    });
  }
}
