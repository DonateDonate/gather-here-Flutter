// 공통 상수 정의
class Const {
  Const._();

  static String baseUrl = 'http://sanha-api.shop:8080';
  static String socketUrl = 'ws://sanha-api.shop:8080/location/share';

  // baseURL & socketURL 변경
  static void changeURLs(String url) {
    baseUrl = 'http://' + url;
    socketUrl = 'http://' + url;
  }
}