import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/models/wg.dart';
import 'package:wg_app/scoped_models/main.dart';

class WgBeitretenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WgBeitretenPageState();
  }
}

class _WgBeitretenPageState extends State<WgBeitretenPage> {
  final TextEditingController _pwdTextController = TextEditingController();
  final Map<String, dynamic> _formData = {
    'pwd': null,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      //müssen Bild noch holen
      image: AssetImage('assets/uni.jpg'),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Wg Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      controller: _pwdTextController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Bitte geben Sie ein Wg Passwort an';
        }
      },
      onSaved: (String value) {
        _formData['pwd'] = value;
      },
    );
  }

  Widget _buildRaisedButton(Wg diewg) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isloading
          ? CircularProgressIndicator()
          : RaisedButton(
              textColor: Colors.white,
              child: Text('Beitreten'),
              onPressed: () {
               if(!_formKey.currentState.validate()){
                 return;
               } 
               _formKey.currentState.save();
               String pwd= _formData['pwd'];
               if( pwd==diewg.pwd){
                     model.wgBeitreten(diewg).then((_) {
                  Navigator.of(context).pushReplacementNamed('/');
                });

               }
               else {
                 showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                title: Text('Fehler'),
                content: Text('Das Passwort stimmt nicht'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('ok'),
                    onPressed: () {
                      Navigator.pop(context);
                      
                    },
                  )
                ],
              );
               });
               }
              
            
              },
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      Wg diewg;
      model.allwgs.forEach((Wg wg) {
        if (wg.id == model.selectedWg) {
          diewg = wg;
        }
      });
      final double deviceWidth = MediaQuery.of(context).size.width;
      final double targetWidth =
          deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;

      return WillPopScope(
        onWillPop: () {
          model.selectedWgIdToNull();
          print('Back button pressed!');
          Navigator.pop(context, false);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(diewg.wgName),
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
                                Row(
                                  children: <Widget>[
                                    Text('Name:',
                                        style:
                                            Theme.of(context).textTheme.title),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Expanded(
                                      child: Text(diewg.wgName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .title),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: <Widget>[
                                    Text('Wg ID:',
                                        style:
                                            Theme.of(context).textTheme.title),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Expanded(
                                      child: Text(diewg.id,
                                          style: Theme.of(context)
                                              .textTheme
                                              .title),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                _buildPasswordTextField(),
                                SizedBox(
                                  height: 10.0,
                                ),
                                _buildRaisedButton(diewg)
                              ])))))),
        ),
      );
    });
  }
}
