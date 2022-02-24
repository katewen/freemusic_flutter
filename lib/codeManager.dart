import 'package:shared_preferences/shared_preferences.dart';
class CodeManager {

  
  static final CodeManager _manager = new CodeManager.internal();

  factory CodeManager() => _manager;

  static CodeManager _codeManager;

  CodeManager.internal();

  String netCode = '0000';

  void Function() showCodeAlertCallBack;

  Future<bool> isCodeValid(String code) async {
    if (code == netCode) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("XLCode", code);
      prefs.setString("XLCodeTime", DateTime.now().toString());
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isShowAlert() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("XLCodeTime") == null) {
        return true;
      }
      DateTime nowTime = DateTime.now();
      DateTime saveTime = DateTime.parse(prefs.getString("XLCodeTime"));
      if (nowTime.millisecondsSinceEpoch - saveTime.millisecondsSinceEpoch < -2*1000*86400 
          || nowTime.millisecondsSinceEpoch - saveTime.millisecondsSinceEpoch > 2*1000*86400) {
            if (showCodeAlertCallBack != null)
              showCodeAlertCallBack();
            return true;
      }
      return false;
  }


}