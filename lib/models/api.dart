import 'dart:convert';

import 'package:fes_signage/app.dart';
import 'package:http/http.dart' as http;

void getApiData() async {
  // apiからjsonを取得
  var url = Uri.parse(
      'https://script.google.com/macros/s/AKfycby6fC4Mj6Xx_NwSq1MCchYvlVI-tbPjNiAO-5ZuqaC5ZIGZTyhp-M4jlRNKHmzA1QqD/exec');
  var response = await http.get(url);
  var data = jsonDecode(response.body);
  print(data);

  timelinePadding = data['timeline']['padding'];
  mainTitle = data['meta']['main_title'] ?? "取得エラー";
  subTitle = data['meta']['sub_title'] ?? "取得エラー";
  // notificationを順次読み込み
  data['notification']['content'].forEach((element) {
    notification.add({
      "title": element['title'] ?? "取得エラー",
      "body": element['body'] ?? "取得エラー"
    });
  });
  print(notification);
  // timelineを順次読み込み
  data['timeline']['content'].forEach((element) {
    timeline.add({
      element['name'] ?? "取得エラー": element['time'] ?? "取得エラー",
    });
  });
  print(timeline);
}
