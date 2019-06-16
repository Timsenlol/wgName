import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/scoped_models/main.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  ImageInput(this.setImage);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File _imageFile;
  void _getImage(BuildContext context, ImageSource source) {
    ImagePicker.pickImage(source: source, maxWidth: 400.00).then((File image) {
      setState(() {
        _imageFile = image;
      });
      widget.setImage(image);

      Navigator.pop(context);
    });
  }

  void openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Wähle ein Bild',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text('Kamera'),
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                ),
                SizedBox(
                  height: 5.0,
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text('Auf Gallerie zugreifen'),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
          onPressed: () {
            openImagePicker(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(
                width: 5.0,
              ),
              ScopedModelDescendant<MainModel>(
                builder: (BuildContext context, Widget child, MainModel model) {
                  if (model.kuehlschrank == null) {
                    return Text(
                      'Bild hinzufügen',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    );
                  } else {
                    return Text(
                      'Bild ändern',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    );
                  }
                },
              )
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        _imageFile == null
            ? Text('Bitte wähle ein Bild')
            : Column(
                children: <Widget>[
                  Image.file(
                    _imageFile,
                    fit: BoxFit.cover,
                    height: 300.0,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                  ),
                  ScopedModelDescendant<MainModel>(builder:
                      (BuildContext context, Widget child, MainModel model) {
                    return model.isloading
                        ? CircularProgressIndicator()
                        : RaisedButton(
                            textColor: Colors.white,
                            child: Text('Bild bestäigen'),
                            onPressed: () {
                              setState(() {
                                if (model.kuehlschrank == null) {
                                  model.addKuehlschrank(_imageFile).then((_) {
                                    Navigator.of(context).pushReplacementNamed(
                                        '/wgEinkaufsListe');
                                  });
                                } else {
                                  model.editKuehlschrank(_imageFile).then((_) {
                                    Navigator.of(context).pushReplacementNamed(
                                        '/wgEinkaufsListe');
                                  });
                                }
                              });
                            });
                  })
                ],
              )
      ],
    );
  }
}
