import 'package:myapp/database/ConfigModel.dart';
import 'package:intl/intl.dart';

class GlobalData {
  static String? baseUrl;
  static String? username;
  static String? password;
  static DateFormat formatter = DateFormat('dd.MM.yyyy');
  static DateFormat formatterTm = DateFormat('dd.MM.yyyy HH:mm:ss');
  static bool isOnline = false;
  static bool isReadAll = false;

  static String getDateString(DateTime dt) {
    return formatter.format(dt);
  }

  static String getDateTimeString(DateTime dt) {
    return formatterTm.format(dt);
  }
}

initGlobalData() async {
  Config cfg = await getConfig();
  GlobalData.username = cfg.username;
  GlobalData.password = cfg.password;
  GlobalData.baseUrl = cfg.url;
}
