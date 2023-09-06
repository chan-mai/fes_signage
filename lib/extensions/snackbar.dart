import 'package:flutter/material.dart';

class AppSnackBar extends StatelessWidget {
  final String message;
  AppSnackBar({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // 正常 SnackBar
  static show(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Wrap(
        children: <Widget>[
          const Icon(
            Icons.check,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(message),
        ],
      ),
      duration: const Duration(milliseconds: 5000),
    ));
  }

  // 異常 SnackBar
  static showError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Wrap(
        children: <Widget>[
          const Icon(
            Icons.error,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(message),
        ],
      ),
      duration: const Duration(milliseconds: 5000),
    ));
  }
}
