import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/models/wg.dart';
import 'package:wg_app/scoped_models/main.dart';
import 'package:wg_app/widgets/helpers/ensure-visible.dart';

class WgErstellenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WgErstellenPageState();
  }
}

class _WgErstellenPageState extends State<WgErstellenPage> {
  final Map<String, dynamic> _formData = {
    'wgName': null,
    'pwd': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();

   Widget _buildPWDConfirmTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Wg Passwort', filled: true, fillColor: Colors.white),
      obscureText: true,
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

  Widget _buildWgNameTextField() {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: 'Wg Name',
        filled: true,
          fillColor: Colors.white),
        initialValue: '',
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 5) {
            return 'Bitte geben Sie einen Namen an';
          }
        },
        onSaved: (String value) {
          _formData['wgName'] = value;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isloading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Erstellen'),
                textColor: Colors.white,
                onPressed: () => _submitForm(
                      model.wgErstellen,
                    ),
              );
      },
    );
  }

  void _submitForm(Function wgErstellen) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    

    wgErstellen(
      _formData['wgName'],
      _formData['pwd']
    ).then((bool success) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Something went wrong'),
                content: Text('Please try again!'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Okay'),
                  )
                ],
              );
            });
      }
    });
  }

/*   Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildWgNameTextField(),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  } */

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      //müssen Bild noch holen
      image: AssetImage('assets/uni.jpg'),
    );
  }

  Widget _buildPageContent(MainModel model) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Container(
       
        padding: EdgeInsets.all(10.0),
        child: Center(
            child: SingleChildScrollView(
                child: Container(
                    width: targetWidth,
                    child: Form(
                        key: _formKey,
                        child: Column(children: <Widget>[
                          _buildWgNameTextField(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _buildPWDConfirmTextField(),
                           SizedBox(
                            height: 10.0,
                          ),
                          _buildSubmitButton()
                        ]))))));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Wg erstellen'),
            ),
            body: Container(
              decoration: BoxDecoration(
                image: _buildBackgroundImage(),
              ),
              child: _buildPageContent(model),
            ));
      },
    );
  }
}
