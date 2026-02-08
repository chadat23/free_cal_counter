import 'package:flutter/material.dart';

class ScreenBackground extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;

  const ScreenBackground({
    super.key,
    required this.child,
    this.appBar,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(child: child),
    );
  }
}
