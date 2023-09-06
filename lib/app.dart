import 'package:flutter/material.dart';

// screens
import 'package:fes_signage/screens/home.dart';
import 'package:fes_signage/screens/wait.dart';

// extensions
import 'package:fes_signage/extensions/color_schemes.g.dart';
import 'package:fes_signage/extensions/snackbar.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文化祭デジタルサイネージシステム',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      //darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const AppTopWidget(),
    );
  }
}

class AppTopWidget extends StatefulWidget {
  const AppTopWidget({Key? key}) : super(key: key);

  @override
  State<AppTopWidget> createState() => _StatefulWidgetState();
}

class _StatefulWidgetState extends State<AppTopWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    return Scaffold(
      body: HomeScreen(),
    );
  }
}

// 状態保持
bool loadState = false;

// meta
String? mainTitle;
String? subTitle;

// timeline
List<Map<String, String>> timeline = [];
double timelinePadding = 60.0;

// notification
List<Map<String, String>> notification = [];
