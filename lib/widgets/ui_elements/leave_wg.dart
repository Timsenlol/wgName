import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/scoped_models/main.dart';



class WgVerlassenListTile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WgVerlassenListTileState();
  }
  
}
class _WgVerlassenListTileState extends State<WgVerlassenListTile>{
 


 
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (model.wg == null) {
          return Container();
        } else {
          return ListTile(
            leading: Icon(Icons.backspace),
            title: Text('Wg verlassen'),
            onTap: () {
              showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                title: Text('Wg verlassen?'),
                content: Text('Wollen Sie wirklich die Wg verlassen?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('ok'),
                    onPressed: () {
                      //setState(() {
                        model.wgVerlassen();
                        Navigator.of(context).pushReplacementNamed('/');
                      
                     // });
                      
                    },
                  )
                ],
              );
               });
              
              
            },
          );
        }
      },
    );
  }
}
