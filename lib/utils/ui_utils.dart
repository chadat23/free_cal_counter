import 'package:flutter/material.dart';
import 'package:meal_of_record/widgets/auto_dismiss_dialog.dart';

class UiUtils {
  static Future<void> showAutoDismissDialog(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 1),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          AutoDismissDialog(content: Text(message), duration: duration),
    );
  }
}
