import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 600) return 32;
    if (width > 400) return 24;
    return 16;
  }

  static double verticalPadding(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    if (height > 800) return 24;
    return 16;
  }
}
