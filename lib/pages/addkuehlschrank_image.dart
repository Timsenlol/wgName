import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/scoped_models/main.dart';
import 'package:wg_app/widgets/form_inputs/image.dart';

class AddKuehlschrankImagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddKuehlschrankImagePageState();
  }
}

class _AddKuehlschrankImagePageState extends State<AddKuehlschrankImagePage> {
  final Map<String, dynamic> _formData = {
    'image': null,
  };

  void _setImage(File image) {
    _formData['image'] = image;
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
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Bild aktualisieren'),
        ),
        body: Center(
            child: Container(
          decoration: BoxDecoration(
            image: _buildBackgroundImage(),
          ),
          child: ImageInput(_setImage),
        )),
      );
    });
  }
}
