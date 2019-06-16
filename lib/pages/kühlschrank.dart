import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/scoped_models/main.dart';

class KuehschrankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          appBar: AppBar(
            title: (Text(model.kuehlschrank.datum, )),
            backgroundColor: Colors.transparent,
            elevation: 100,
          ),
          body: Image(
            image: NetworkImage(
              model.kuehlschrank.imageUrl,
            ),
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
        );
      },
    );
  }
}
