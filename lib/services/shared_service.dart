import 'package:shared_preferences/shared_preferences.dart';

class SharedService {
  static late SharedPreferences _prefs;
  static String _shopId = '';
  static String _shopCode = '';
  static String _shopName = 'FQ UBII';
  static String _shopCity = 'Caracas';

  static String _pagoMovil = '';
  static String _pagoMovilCi = '';
  static String _pagoMovilBank = '';
  static String _keyBdv = '';
  static String _zelle = '';

  static String _displayName = '';
  static String _operatorName = '';
  static String _operatorCode = '';
  static String _userName = '';
  static String _punto = 'PUNTO 1';
  static String _logon = 'YES';
  static bool _showImage = false;
  static String _counterId = '';

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  // COUNTER ID
  static String get counterId {
    return _prefs.getString('counterId') ?? _counterId;
  }
  static set counterId(String counterId) {
    _counterId = counterId;
    _prefs.setString('counterId', counterId);
  }

  // ZELLE
  static String get zelle {
    return _prefs.getString('zelle') ?? _zelle;
  }
  static set zelle(String zelle) {
    _zelle = zelle;
    _prefs.setString('zelle', zelle);
  }
  // PAGO MOVIL
  static String get pagoMovil {
    return _prefs.getString('pagoMovil') ?? _pagoMovil;
  }
  static set pagoMovil(String pagoMovil) {
    _pagoMovil = pagoMovil;
    _prefs.setString('pagoMovil', pagoMovil);
  }
  // PAGO MOVIL CI
  static String get pagoMovilCi {
    return _prefs.getString('pagoMovilCi') ?? _pagoMovilCi;
  }
  static set pagoMovilCi(String pagoMovilCi) {
    _pagoMovilCi = pagoMovilCi;
    _prefs.setString('pagoMovilCi', pagoMovilCi);
  }
  // PAGO MOVIL BANK
  static String get pagoMovilBank {
    return _prefs.getString('pagoMovilBank') ?? _pagoMovilBank;
  }
  static set pagoMovilBank(String pagoMovilBank) {
    _pagoMovilBank = pagoMovilBank;
    _prefs.setString('pagoMovilBank', pagoMovilBank);
  }
  // KEY BDV
  static String get keyBdv {
    return _prefs.getString('keyBdv') ?? _keyBdv;
  }
  static set keyBdv(String keyBdv) {
    _keyBdv = keyBdv;
    _prefs.setString('keyBdv', keyBdv);
  }

  // LOGON
  static String get logon {
    return _prefs.getString('logon') ?? _logon;
  }
  static set logon(String logon) {
    _logon = logon;
    _prefs.setString('logon', logon);
  }

  // SHOPID
  static String get shopId {
    return _prefs.getString('shopId') ?? _shopId;
  }

  static set shopId(String shopId) {
    _shopId = shopId;
    _prefs.setString('shopId', shopId);
  }

  // SHOPCODE
  static String get shopCode {
    return _prefs.getString('shopCode') ?? _shopCode;
  }

  static set shopCode(String shopCode) {
    _shopCode = shopCode;
    _prefs.setString('shopCode', shopCode);
  }

  // SHOP NAME
  static String get shopName {
    return _prefs.getString('shopName') ?? _shopName;
  }

  static set shopName(String shopName) {
    _shopName = shopName;
    _prefs.setString('shopName', shopName);
  }

  // NAME
  static String get displayName {
    return _prefs.getString('displayName') ?? _displayName;
  }

  static set displayName(String displayName) {
    _displayName = displayName;
    _prefs.setString('displayName', displayName);
  }

  // OPERATOR CODE
  static String get operatorCode {
    return _prefs.getString('operatorCode') ?? _operatorCode;
  }
  static set operatorCode(String operatorCode) {
    _operatorCode = operatorCode;
    _prefs.setString('operatorCode', operatorCode);
  }


  // OPERATOR NAME
  static String get operatorName {
    return _prefs.getString('operatorName') ?? _operatorName;
  }

  static set operatorName(String operatorName) {
    _operatorName = operatorName;
    _prefs.setString('operatorName', operatorName);
  }

  // CITY NAME
  static String get shopCity {
    return _prefs.getString('shopCity') ?? _shopCity;
  }

  static set shopCity(String shopCity) {
    _shopCity = shopCity;
    _prefs.setString('shopCity', shopCity);
  }

  // USER NAME
  static String get userName {
    return _prefs.getString('userName') ?? _userName;
  }
  static set userName(String userName) {
    _userName = userName;
    _prefs.setString('userName', userName);
  }

  // USER PUNTO
  static String get punto {
    return _prefs.getString('punto') ?? _punto;
  }
  static set punto(String punto) {
    _punto = punto;
    _prefs.setString('punto', punto);
  }

  // SHOW IMAGE
  static bool get showImage {
    return _prefs.getBool('showImage') ?? _showImage;
  }
  static set showImage(bool showImage) {
    _showImage = showImage;
    _prefs.setBool('showImage', showImage);
  }
}
