import 'dart:convert';

import 'package:fes_signage/models/timelineDate.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:fes_signage/app.dart';
import 'package:http/http.dart' as http;
// extensions
import 'package:fes_signage/extensions/snackbar.dart';

// clock
import 'package:analog_clock/analog_clock.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

// timeline
import 'package:timelines/timelines.dart';

// stt
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SpeechToText? speech;
  bool _listenLoop = false;
  String lastHeard = '';
  String totalHeard = "";
  double confidence = 0.0;

  final pageController = PageController();
  int initialPage = 0;

  void _onStatus(String status) {
    if ('done' == status) {
      print('onStatus(): $status ');
      startListening();
    }
  }

  void startListening({bool forced = false}) async {
    if (forced) {
      setState(() {
        _listenLoop = !_listenLoop;
      });
    }
    if (!_listenLoop) return;
    print('startListening()');
    speech = SpeechToText();

    bool _available = await speech!.initialize(
      onStatus: _onStatus,
      onError: (val) => onError(val),
      debugLogging: true,
    );
    if (_available) {
      print('startListening() -> _available = true');
      await listen();
    } else {
      print('startListening() -> _available = false');
    }
  }

  Future listen() async {
    print('speech!.listen()');
    speech!.listen(
      onResult: (val) => onResult(val),
    ); // Doesn't do anything
  }

  void onError(SpeechRecognitionError val) async {
    print('onError(): ${val.errorMsg}');
  }

  void onResult(SpeechRecognitionResult val) async {
    print('onResult()');
    print('val.alternates ${val.alternates.last}');

    setState(() {
      lastHeard = val.alternates.last.recognizedWords;
      if (val.alternates.last.recognizedWords != "") {
        setState(() {
          totalHeard = val.alternates.last.recognizedWords;
          confidence = val.alternates.last.confidence;
          print('$totalHeard ($confidence)');
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startListening(forced: true);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      // apiからjsonを取得
      var url = Uri.parse(
          'https://script.google.com/macros/s/AKfycby6fC4Mj6Xx_NwSq1MCchYvlVI-tbPjNiAO-5ZuqaC5ZIGZTyhp-M4jlRNKHmzA1QqD/exec');
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      print(data);

      setState(() {
        timelinePadding = data['meta']['timeline_padding'];
        mainTitle = data['meta']['main_title'] ?? "取得エラー";
        subTitle = data['meta']['sub_title'] ?? "取得エラー";
        notification.clear();
        // notificationを順次読み込み
        data['notification'].forEach((element) {
          notification.add({
            "title": element['name'].toString() ?? "取得エラー",
            "body": element['body'].toString() ?? "取得エラー"
          });
        });
        print(notification);
        // timelineを順次読み
        timeline.clear();
        data['timeline'].forEach((element) {
          // datatimeから時刻を取得
          String start = getTimeText(DateTime.parse(element['start']));
          String end = getTimeText(DateTime.parse(element['end']));
          String? timeText;
          if (start != null && end != null) {
            timeText = start + " ~ " + end;
          }
          print(timeText);
          timeline.add({
            element['title'].toString() ?? "取得エラー": timeText ?? "取得エラー",
          });
        });
        print(timeline);
      });
    });
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.735,
                        height: MediaQuery.of(context).size.height * 0.6,
                        padding: const EdgeInsets.all(50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mainTitle,
                              style: TextStyle(
                                fontSize: 35,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              subTitle,
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(10)),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.735,
                              height: 1,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Expanded(
                                    child: ListView(
                                  // タイムラインカードの生成
                                  children: timeline.map((e) {
                                    return Card(
                                      child: ListTile(
                                        title: Text(
                                          e.keys.first,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        subtitle: Text(
                                          e.values.first,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        // 影をなくす
                                        tileColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.01)),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.735,
                        height: MediaQuery.of(context).size.height * 0.28,
                        padding: const EdgeInsets.all(50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'リアルタイム字幕',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: [
                                Text(
                                  totalHeard,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                confidence == 0.0
                                    ? Container()
                                    : Text(
                                        '(信頼度: ${(confidence * 100).toStringAsFixed(3)}%)',
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.01)),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.height * 0.38,
                        padding: const EdgeInsets.all(50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: AnalogClock(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    shape: BoxShape.circle),
                                width: 150.0,
                                isLive: true,
                                hourHandColor:
                                    Theme.of(context).colorScheme.primary,
                                minuteHandColor:
                                    Theme.of(context).colorScheme.primary,
                                showSecondHand: false,
                                numberColor:
                                    Theme.of(context).colorScheme.primary,
                                showNumbers: true,
                                showAllNumbers: false,
                                textScaleFactor: 1.4,
                                showTicks: false,
                                showDigitalClock: false,
                                datetime: DateTime.now(),
                              ),
                            ),
                            DigitalClock(
                              is24HourTimeFormat: false,
                              showSecondsDigit: false,
                              digitAnimationStyle: Curves.elasticOut,
                              hourMinuteDigitTextStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 50,
                              ),
                              amPmDigitTextStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.01)),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.height * 0.5,
                        padding: const EdgeInsets.all(50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '会場の皆様へお知らせ',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: notification.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                      title: Text(
                                        notification[index]['title'] ?? '取得エラー',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      subtitle: Text(
                                        notification[index]["body"] ?? '取得エラー',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
