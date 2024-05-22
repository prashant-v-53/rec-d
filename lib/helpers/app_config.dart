class App {
  static const String appName = "REC\'d";
  //? Demo
  // static const String RECd_URL = "http://134.213.212.201:3000/";
  //? Production
  // static const String RECd_URL = "http://134.213.213.12:3000/";
  static const String RECd_URL = "https://recd.app/";
  static const String unauthorized = "Unauthorized please login again";
}

class PrefsKey {
  static const String ACCESS_TOKEN = "ACCESS_TOKEN";
  static const String USER_ID = "USER_ID";
  static const String RECD_HEADER = "authorization";
  static const String PODCAST_HEADER = "X-ListenAPI-Key";
}
