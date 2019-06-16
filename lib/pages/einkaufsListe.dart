

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wg_app/models/kuehlschrank.dart';
import 'package:wg_app/scoped_models/main.dart';
import 'package:wg_app/models/item.dart';

import 'package:wg_app/widgets/ui_elements/custom_popup_menu.dart';
import 'package:wg_app/widgets/ui_elements/leave_wg.dart';
import 'package:wg_app/widgets/ui_elements/logout_list_tile.dart';
import 'package:wg_app/widgets/ui_elements/meine_wg-ListTile.dart';

class EinkaufsListePage extends StatefulWidget {
  final MainModel model;
  EinkaufsListePage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EinkaufsListePageState();
  }
}

List<CustomPopupMenu> choices = <CustomPopupMenu>[
  CustomPopupMenu(title: 'Kühlschrankinhalt anzeigen'),
  CustomPopupMenu(title: 'Kühlschrankinhalt aktualisieren'),
];

class _EinkaufsListePageState extends State<EinkaufsListePage> {
    List<Item> einkaufsliste=[];
  

  initState() {
   widget.model.itemToNull();
    sucheSchrank();
    erstelleEinkaufsListe();

    super.initState();
  }

  //= choices[0];
  void _select(
    CustomPopupMenu choice,
  ) {
    if (choice == null) {}
    if (choice.title == 'Kühlschrankinhalt anzeigen') {
      if (widget.model.kuehlschrank == null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Kein Bild vorhanden'),
                content: Text('Noch kein Kühlschrankbild vorhanden'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('ok'),
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                  )
                ],
              );
            });
      } else {
        Navigator.of(context).pushNamed('/kühl');
      }
    }
    if (choice.title == 'Kühlschrankinhalt aktualisieren') {
      Navigator.of(context).pushNamed('/addkühl');
    }
  }

  /*  Widget _showContent(CustomPopupMenu choice) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (choice == null) {
          return Center(
            child: Text('Hier kommt die Einkausliste hin'),
          );
        }
        if (choice.title == 'Kühlschrankinhalt anzeigen') {
          if (widget.model.kuehlschrank == null) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Kein Bild vorhanden'),
                    content: Text('Noch kein Kühlschrankbild vorhanden'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('ok'),
                        onPressed: () {
                          setState(() {
                          
                            Navigator.of(context).pop();
                          });
                        },
                      )
                    ],
                  );
                });
          }
   

          Navigator.of(context).pushNamed('/kühl');
        }
        if (choice.title == 'Kühlschrankinhalt aktualisieren') {
     
          return ImageInput(_setImage);
        }
        return Center(
          child: Text('Hier kommt die Einkaufsliste hin'),
        );
      },
    );
  } */

  void sucheSchrank() async {
    await widget.model.fetchKuehlschrank();
    List<Kuehlschrank> kuehlschraenke = widget.model.kuehlschranke;

    if (kuehlschraenke == null) {
      return;
    }
    kuehlschraenke.forEach((Kuehlschrank ks) {
      if (ks.wgid == widget.model.wg.id) {
        widget.model.selectKuehlschrank(ks);
      }
    });
  }

  Future<void> erstelleEinkaufsListe() async {
    
    einkaufsliste.clear();
    await widget.model.fetchEinkaufsListe();
    List<Item> einkaufslisteForWg = widget.model.einkaufsliste;
    if (einkaufslisteForWg == null) {
      return;
    }

    einkaufslisteForWg.forEach((Item item) {
      if (item.wgid == widget.model.wg.id) {
        einkaufsliste.add(item);
      }
    });
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.announcement),
            title: Text('Newsfeed'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
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

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.input),
      onPressed: () {
        model.selectItem(einkaufsliste[index].id);

        Navigator.of(context).pushNamed('/additem');
      },
    );
  }

  Widget buildList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (einkaufsliste == null) {
          return Center(
            child: Text('Noch keine Items in der Liste enthalten'),
          );
        } else {
          return Center(
            child: Container(
                decoration: BoxDecoration(
                  image: _buildBackgroundImage(),
                ),
                child: Center(child: ScopedModelDescendant<MainModel>(
                  builder:
                      (BuildContext context, Widget child, MainModel model) {
                    return RefreshIndicator(onRefresh: erstelleEinkaufsListe,
                    child:  ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                          key: Key(einkaufsliste[index].itemName),
                          onDismissed: (DismissDirection direction) {
                            if (direction == DismissDirection.endToStart) {
                              model.selectItem(einkaufsliste[index].id);
                              model.deleteItem().then((_){
                                 erstelleEinkaufsListe();

                              });
                             
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              print('Swiped start to end');
                            } else {
                              print('Other swiping');
                            }
                          },
                          background: Container(color: Colors.red),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage('assets/einkauf.jpg'),
                                ),
                                title: Text(einkaufsliste[index].itemName),
                                trailing:
                                    _buildEditButton(context, index, model),
                              ),
                              Divider()
                            ],
                          ),
                        );
                      },
                      itemCount: einkaufsliste.length,
                     
                    ));
                   
                    
                  },
                ))),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
           
            drawer: _buildSideDrawer(context),
            appBar: model.isloading
                ? AppBar(
                    title: Text('Einkaufsliste'),
                  )
                : AppBar(
                    title: Text('Einkaufsliste'),
                    actions: <Widget>[
                      PopupMenuButton<CustomPopupMenu>(
                        elevation: 3.2,
                        onCanceled: () {},
                        tooltip: 'This is tooltip',
                        onSelected: _select,
                        itemBuilder: (BuildContext context) {
                          return choices.map((CustomPopupMenu choice) {
                            return PopupMenuItem<CustomPopupMenu>(
                              value: choice,
                              child: Text(choice.title),
                            );
                          }).toList();
                        },
                      )
                    ],
                  ),
            body: model.isloading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : buildList(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/additem');
              },
              child: Icon(Icons.add),
            )
           
            );
            
      },
    );
  }
}
