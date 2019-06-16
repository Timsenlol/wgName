import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/models/item.dart';
import 'package:wg_app/scoped_models/main.dart';
import 'package:wg_app/widgets/helpers/ensure-visible.dart';

class ItemHinzuefugenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ItemHinzuefugenPageState();
  }
}

class _ItemHinzuefugenPageState extends State<ItemHinzuefugenPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();

  final Map<String, dynamic> _formData = {
    'itemName': null,
  };

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      //müssen Bild noch holen
      image: AssetImage('assets/uni.jpg'),
    );
  }

  Widget _buildItemNameTextField() {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(
            labelText: 'Item', filled: true, fillColor: Colors.white),
        initialValue: '',
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty) {
            return 'Bitte geben Sie einen Namen an';
          }
        },
        onSaved: (String value) {
          _formData['itemName'] = value;
        },
      ),
    );
  }

  Widget _buildEditItemNameTextField(MainModel model) {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(
            labelText: 'Item', filled: true, fillColor: Colors.white),
        initialValue: getOldItemName(model),
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty) {
            return 'Bitte geben Sie einen Namen an';
          }
        },
        onSaved: (String value) {
          _formData['itemName'] = value;
        },
      ),
    );
  }

  String getOldItemName(MainModel model) {
    String id = model.selectedItem();
    String name;
    List<Item> itemlist = model.einkaufsliste;
    itemlist.forEach((Item item) {
      if (item.id == id) {
        name = item.itemName;
      }
    });
    return name;
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isloading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Erstellen'),
                textColor: Colors.white,
                onPressed: () => _submitForm(model),
              );
      },
    );
  }

  void _submitForm(MainModel model) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (model.selectedItem() != null) {
      Item itemEdit = Item(
          itemName: _formData['itemName'],
          id: model.selectedItem(),
          wgid: model.wg.id);
      model.updateItem(itemEdit).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/wgEinkaufsListe');
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
    } else {
      model
          .addItem(
        _formData['itemName'],
      )
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/wgEinkaufsListe');
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
                          model.selectedItem() == null
                              ? _buildItemNameTextField()
                              : _buildEditItemNameTextField(model),
                          SizedBox(
                            height: 10.0,
                          ),
                          _buildSubmitButton()
                        ]))))));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return WillPopScope(
            onWillPop: () async{
              setState(() {
                print('on will pop');
                model.itemToNull();
                Navigator.of(context).pushReplacementNamed('/wgEinkaufsListe');
              });
              return true;
            },
            child:  Scaffold(
                appBar: model.selectedItem() == null
                    ? AppBar(
                        title: Text('Item hinzufügen'),
                      )
                    : AppBar(title: Text('Item editieren')),
                body: Container(
                  decoration: BoxDecoration(
                    image: _buildBackgroundImage(),
                  ),
                  child: _buildPageContent(model),
                ))
                )
                ;
      },
    );
  }
}
