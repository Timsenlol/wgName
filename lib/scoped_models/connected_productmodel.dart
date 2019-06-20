import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'package:wg_app/models/auth.dart';
import 'package:wg_app/models/item.dart';
import 'package:wg_app/models/kuehlschrank.dart';
import 'package:wg_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wg_app/models/wg.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';

mixin ConnectedProductsModel on Model {
  User _authenicatedUser;
  Wg _wg;
  List<Wg> _wgListe = [];
  String _selWgId;
  List<Item> _einkaufsListe = [];
  Item _item;
  Kuehlschrank _kuehlschrank;
  List<Kuehlschrank> _kuehlschraenke;
  String _selItem;

  bool _isLoading = false;
}
mixin EinkaufsListeModel on ConnectedProductsModel {
  Item get item {
    return _item;
  }

  List<Item> get einkaufsliste {
    if (_einkaufsListe == null) {
      return null;
    }
    return List.from(_einkaufsListe);
  }

  void selectItem(String itemId) {
    _selItem = itemId;
    notifyListeners();
  }

  String selectedItem() {
    return _selItem;
  }

  void itemToNull() {
    _selItem = null;
  }

  Future<bool> addItem(String itemadd) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> item = {'Item': itemadd, 'wgId': _wg.id};

    final http.Response response = await http.post(
        'https://wgapp-51a82.firebaseio.com/Einkaufsliste.json?auth=${_authenicatedUser.token}',
        
        body: json.encode(item));

    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> fetchEinkaufsListe() async {
    _isLoading = true;
    notifyListeners();
    _item = null;
    _einkaufsListe = null;
    http.Response response = await http.get(
        'https://wgapp-51a82.firebaseio.com/Einkaufsliste.json?auth=${_authenicatedUser.token}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final List<Item> fetchedeinkaufsListe = [];

    final Map<String, dynamic> einkaufsListeData = json.decode(response.body);
    if (einkaufsListeData == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    einkaufsListeData.forEach((String itid, dynamic ekData) {
      final Item itemadd =
          Item(id: itid, itemName: ekData['Item'], wgid: ekData['wgId']);

      fetchedeinkaufsListe.add(itemadd);
    });
    _einkaufsListe = fetchedeinkaufsListe;
    _isLoading = false;
    _selWgId = null;
    notifyListeners();
    return true;
  }

  Future<bool> updateItem(Item item) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> itemData = {'Item': item.itemName, 'wgId': item.wgid};
    final http.Response response = await http.put(
        'https://wgapp-51a82.firebaseio.com/Einkaufsliste/${item.id}.json?auth=${_authenicatedUser.token}',
        body: json.encode(itemData));

    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    //final Map<String, dynamic> responseData = json.decode(response.body);

    _selItem = null;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> deleteItem() async {
    _isLoading = true;
    notifyListeners();
    http.Response response;
    response = await http.delete(
      'https://wgapp-51a82.firebaseio.com/Einkaufsliste/${_selItem}.json?auth=${_authenicatedUser.token}',
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _selItem = null;
    _isLoading = false;
    notifyListeners();
    return true;
  }
}

mixin WgModel on ConnectedProductsModel {
  Wg get wg {
    return _wg;
  }

  Future<bool> fetchWgs() async {
    _isLoading = true;
    notifyListeners();
    http.Response response = await http.get(
        'https://wgapp-51a82.firebaseio.com/wgs.json?auth=${_authenicatedUser.token}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final List<Wg> fetchedWgList = [];
    final Map<String, dynamic> wgListData = json.decode(response.body);
    if (wgListData == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    wgListData.forEach((String wgId, dynamic wgData) {
      final Wg wgAdd = Wg(
        id: wgId,
        wgName: wgData['wgName'],
        wgUser: 'dummyUser',
        pwd: wgData['pwd'],
      );

      fetchedWgList.add(wgAdd);
    });
    _wgListe = fetchedWgList;
    _isLoading = false;
    _selWgId = null;
    notifyListeners();
    return true;
  }

  List<Wg> get allwgs {
    return List.from(_wgListe);
  }

  void selectKuehlschrank(Kuehlschrank ks) {
    _kuehlschrank = ks;
  }

  void selectWg(String wgId) {
    _selWgId = wgId;

    notifyListeners();
  }

  String get selectedWg {
    return _selWgId;
  }

  void selectedWgIdToNull() {
    _selWgId = null;
  }

  Future<bool> wgBeitreten(Wg neueWg) async {
    _isLoading = true;
    notifyListeners();

    final http.Response response = await http.put(
        'https://wgapp-51a82.firebaseio.com/wgs/${neueWg.id}/wgUser/${_authenicatedUser.id}.json?auth=${_authenicatedUser.token}',
        body: json.encode(true));
    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _wg = Wg(
        wgName: neueWg.wgName,
        wgUser: _authenicatedUser.id,
        id: neueWg.id,
        pwd: neueWg.pwd);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String wgId = prefs.getString('wgId');
    if (wgId != null) {
      prefs.remove('wgId');
      prefs.remove('wgUser');
      prefs.remove('wgName');
      prefs.remove('pwd');
    }

    prefs.setString('wgId', _wg.id);
    prefs.setString('wgUser', _wg.wgUser);
    prefs.setString('wgName', _wg.wgName);
    prefs.setString('pwd', _wg.pwd);
    _isLoading = false;

    notifyListeners();
    return true;
  }

  Future<bool> wgErstellen(String wgName, String pwd) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> wgUsers = {'${_authenicatedUser.id}': true};
    final Map<String, dynamic> wgData = {
      'wgName': wgName,
      'pwd': pwd,
      'wgUser': wgUsers
    };
    final http.Response response = await http.post(
        'https://wgapp-51a82.firebaseio.com/wgs.json?auth=${_authenicatedUser.token}',
        body: json.encode(wgData));

    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final Map<String, dynamic> responseData = json.decode(response.body);
    _wg = Wg(
        id: responseData['name'],
        wgName: wgName,
        wgUser: _authenicatedUser.id,
        pwd: responseData['pwd']);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String wgId = prefs.getString('wgId');
    if (wgId != null) {
      prefs.remove('wgId');
      prefs.remove('wgUser');
      prefs.remove('wgName');
      prefs.remove('pwd');
    }

    prefs.setString('wgId', _wg.id);
    prefs.setString('wgUser', _wg.wgUser);
    prefs.setString('wgName', _wg.wgName);
    prefs.setString('pwd', _wg.pwd);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-wgapp-51a82.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenicatedUser.token}';

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong');
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addKuehlschrank(File image) async {
    _isLoading = true;
    notifyListeners();
    var now = new DateTime.now();
    var formatter = new DateFormat('H:m dd.MM.yyyy');
    String formattedDate = formatter.format(now);

    final uploadData = await uploadImage(image);

    final Map<String, dynamic> kuehlschrankData = {
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'wgid': _wg.id,
      'dateTime': formattedDate.toString()
    };

    if (uploadData == null) {
      print('Upload failed!');
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final http.Response response = await http.post(
        'https://wgapp-51a82.firebaseio.com/kuehlschrank.json?auth=${_authenicatedUser.token}',
        body: json.encode(kuehlschrankData));

    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final Map<String, dynamic> responseData = json.decode(response.body);

    _kuehlschrank = Kuehlschrank(
        id: responseData['name'],
        imagePath: uploadData['imagePath'],
        imageUrl: uploadData['imageUrl'],
        wgid: _wg.id,
        datum: responseData['dateTime']);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> editKuehlschrank(File image) async {
    _isLoading = true;
    notifyListeners();

    final uploadData =
        await uploadImage(image, imagePath: _kuehlschrank.imagePath);
    _isLoading = true;
    notifyListeners();
    var now = new DateTime.now();
    var formatter = new DateFormat('H:m dd.MM.yyyy');
    String formattedDate = formatter.format(now);

    final Map<String, dynamic> kuehlschrankData = {
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'wgid': _wg.id,
      'dateTime': formattedDate.toString()
    };

    if (uploadData == null) {
      print('Upload failed!');
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final http.Response response = await http.put(
        'https://wgapp-51a82.firebaseio.com/kuehlschrank/${_kuehlschrank.id}.json?auth=${_authenicatedUser.token}',
        body: json.encode(kuehlschrankData));

    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final Map<String, dynamic> responseData = json.decode(response.body);

    _kuehlschrank = Kuehlschrank(
        id: responseData['name'],
        imagePath: uploadData['imagePath'],
        imageUrl: uploadData['imageUrl'],
        wgid: _wg.id,
        datum: responseData['dateTime']);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Kuehlschrank get kuehlschrank {
    return _kuehlschrank;
  }

  Future<bool> fetchKuehlschrank() async {
    _isLoading = true;
    notifyListeners();
    http.Response response = await http.get(
        'https://wgapp-51a82.firebaseio.com/kuehlschrank.json?auth=${_authenicatedUser.token}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final List<Kuehlschrank> fetchedKsList = [];
    final Map<String, dynamic> ksListData = json.decode(response.body);
    if (ksListData == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    ksListData.forEach((String ksId, dynamic ksData) {
      final Kuehlschrank ksAdd = Kuehlschrank(
          id: ksId,
          imagePath: ksData['imagePath'],
          imageUrl: ksData['imageUrl'],
          wgid: ksData['wgid'],
          datum: ksData['dateTime']);

      fetchedKsList.add(ksAdd);
    });
    _kuehlschraenke = fetchedKsList;
    _isLoading = false;
    _selWgId = null;
    notifyListeners();
    return true;
  }

  List<Kuehlschrank> get kuehlschranke {
    if (_kuehlschraenke == null) {
      return null;
    }
    return List.from(_kuehlschraenke);
  }

 Future <void> wgVerlassen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('wgId');
    prefs.remove('wgUser');
    prefs.remove('wgName');
    prefs.remove('pwd');

    http.Response response;

    response = await http.delete(
      'https://wgapp-51a82.firebaseio.com/wgs/${_wg.id}/wgUser/${_wg.wgUser}.json?auth=${_authenicatedUser.token}',
    );

    _wg = null;
    _selWgId = null;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();
  User get user {
    return _authenicatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String pwd,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    http.Response response;
    //_authenicatedUser = User(id: 'abcd', email: email, password: pwd);
    final Map<String, dynamic> authData = {
      'email': email,
      'password': pwd,
      'returnSecureToken': true
    };
    if (mode == AuthMode.Login) {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyCQEkOyoNp8jREni9MxM1fKhmXVOOzMX_0',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'AnmeldungsFehler'};
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> responseDataWg = json.decode(response.body);
      final String wgId = prefs.getString('wgId');
      final String wgUser = prefs.getString('wgUser');

      if (wgId != null && wgUser == responseDataWg['localId']) {
        final String wgName = prefs.getString('wgName');
        final String pwd = prefs.getString('pwd');
        _wg = Wg(id: wgId, wgUser: wgUser, wgName: wgName, pwd: pwd);
      } else {
        http.Response responsewg = await http.get(
            'https://wgapp-51a82.firebaseio.com/wgs.json?auth=${responseDataWg['idToken']}');

        final Map<String, dynamic> wgDataList = json.decode(responsewg.body);
        if (wgDataList == null) {
          _isLoading = false;
          notifyListeners();
          return {'success': false, 'message': 'Keine Daten'};
        }
        wgDataList.forEach((String wgid, dynamic wgData) {
          if (wgData['wgUser'] == null) {
          } else if ((wgData['wgUser'] as Map<String, dynamic>)
              .containsKey(responseDataWg['localId'])) {
            final Wg wgadd = Wg(
                id: wgid,
                wgName: wgData['wgName'],
                wgUser: responseDataWg['localId'],
                pwd: wgData['pwd']);
            _wg = wgadd;
          }
        });
        if (_wg != null) {
          prefs.remove('wgId');
          prefs.remove('wgUser');
          prefs.remove('wgName');
          prefs.remove('pwd');
          prefs.setString('wgId', _wg.id);
          prefs.setString('wgUser', _wg.wgUser);
          prefs.setString('wgName', _wg.wgName);
          prefs.setString('pwd', _wg.pwd);
        }
      }
    } else {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyCQEkOyoNp8jREni9MxM1fKhmXVOOzMX_0',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    if (responseData.containsKey('idToken')) {
      _authenicatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('email', email);
      prefs.setString('id', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
      hasError = false;

      message = 'Authentication succeeded!';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Die Email wurde nicht gefunden';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Das Passwort ist nicht richtig lol';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    }
    _isLoading = false;
    notifyListeners();

    return {'success': !hasError, 'message': message};
  }

  void autoAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenicatedUser = null;
        notifyListeners();
        return;
      }

      final String email = prefs.getString('email');
      final String id = prefs.getString('id');
      final int tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      _authenicatedUser = User(email: email, id: id, token: token);
      final String wgId = prefs.getString('wgId');
      if (wgId != null) {
        final String wgUser = prefs.getString('wgUser');
        final String wgName = prefs.getString('wgName');
        final String pwd = prefs.getString('pwd');
        _wg = Wg(id: wgId, wgUser: wgUser, wgName: wgName, pwd: pwd);
      }

      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);
      notifyListeners();
    }
  }

  Future <void> logout() async {
    _authenicatedUser = null;
    _wgListe.clear();

    _wg = null;
    _selWgId = null;
    _kuehlschraenke = null;
    _kuehlschrank = null;
    _item = null;
    _einkaufsListe = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('wgId');
    prefs.remove('wgUser');
    prefs.remove('wgName');
    prefs.remove('pwd');
    prefs.remove('token');
    prefs.remove('email');
    prefs.remove('id');
   notifyListeners();
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), () {
      logout();
    });
  }
}
mixin UtilityModel on ConnectedProductsModel {
  bool get isloading {
    return _isLoading;
  }
}
