import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fes_signage/app.dart';

// extensions
import 'package:fes_signage/extensions/snackbar.dart';

// models
import 'package:fes_signage/models/timelineDate.dart';

// clock
import 'package:analog_clock/analog_clock.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

// stt
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

// etc
import 'package:translator/translator.dart';
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // StT
  SpeechToText? speech;
  bool _listenLoop = false;
  String lastHeard = '';
  double confidence = 0.0;
  // ja
  String totalHeard = "";
  // en
  String totalHeardEn = "";
  // cn
  String totalHeardCn = "";

  final translator = GoogleTranslator();

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
          confidence = val.alternates.last.confidence;
          // jp
          totalHeard = val.alternates.last.recognizedWords;
          // jp -> en
          translator
              .translate(val.alternates.last.recognizedWords,
                  from: 'ja', to: 'en')
              .then((value) {
            setState(() {
              totalHeardEn = value.text;
            });
          });
          // jp -> cn
          translator
              .translate(val.alternates.last.recognizedWords,
                  from: 'ja', to: 'zh-cn')
              .then((value) {
            setState(() {
              totalHeardCn = value.text;
            });
          });
          print('$totalHeard ($confidence)');
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startListening(forced: true);

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      // apiからjsonを取得
      var url = Uri.parse(
          'https://script.google.com/macros/s/AKfycby6fC4Mj6Xx_NwSq1MCchYvlVI-tbPjNiAO-5ZuqaC5ZIGZTyhp-M4jlRNKHmzA1QqD/exec');
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      // print(data);

      setState(() {
        timelinePadding = data['meta']['timeline_padding'];
        mainTitle = data['meta']['main_title'] ?? "取得エラー";
        subTitle = data['meta']['sub_title'] ?? "取得エラー";
        notification.clear();
        // notificationを順次読み込み
        data['notification'].forEach((element) {
          notification.add({
            "title": element['name'] ?? "取得エラー",
            "body": element['body'] ?? "取得エラー"
          });
        });
        // print(notification);
        // timelineを順次読み
        timeline.clear();
        data['timeline'].forEach((element) {
          // datatimeから時刻を取得
          String start = getTimeText(DateTime.parse(element['start']));
          String end = getTimeText(DateTime.parse(element['end']));
          String? timeText;
          if (start != null && end != null) {
            timeText = "$start ~ $end";
          }
          // print(timeText);
          timeline.add({
            element['title'] ?? "取得エラー": timeText ?? "取得エラー",
          });
        });
        // print(timeline);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                              mainTitle ?? "処理中です. しばらくお待ち下さい.",
                              style: GoogleFonts.notoSans(
                                fontSize: 35,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              subTitle ?? "処理中です. しばらくお待ち下さい.",
                              style: GoogleFonts.notoSans(
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
                                  // wrapで実装
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: timeline.map((e) {
                                      return Container(
                                        // 3分割の比率で
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.735 *
                                                0.245,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.keys.first,
                                              style: GoogleFonts.notoSans(
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            Text(
                                              e.values.first,
                                              style: GoogleFonts.notoSans(
                                                fontSize: 15,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: timelinePadding)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'リアルタイム字幕',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                confidence == 0.0
                                    ? Container()
                                    : Text(
                                        '(Confidence: ${(confidence * 100).toStringAsFixed(3)}%)',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 20,
                                        ),
                                      ),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                            // リアルタイム字幕 ja
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: [
                                Text('日本語',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                                Text(
                                  totalHeard,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            // リアルタイム字幕 en
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: [
                                Text('English',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                                Text(
                                  totalHeardEn,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            // リアルタイム字幕 cn
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: [
                                Text('中文',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                                Text(
                                  totalHeardCn,
                                  style: GoogleFonts.notoSans(
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
                              hourMinuteDigitTextStyle: GoogleFonts.notoSans(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 50,
                              ),
                              amPmDigitTextStyle: GoogleFonts.notoSans(
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
                              style: GoogleFonts.notoSans(
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
                                        style: GoogleFonts.notoSans(
                                          fontSize: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      subtitle: Text(
                                        notification[index]["body"] ?? '取得エラー',
                                        style: GoogleFonts.notoSans(
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
