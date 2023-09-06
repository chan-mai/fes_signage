import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:fes_signage/app.dart';

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

class WaitScreen extends StatefulWidget {
  @override
  _WaitScreenState createState() => new _WaitScreenState();
}

class _WaitScreenState extends State<WaitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
