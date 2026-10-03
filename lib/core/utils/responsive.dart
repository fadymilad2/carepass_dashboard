import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double _mobileBreak = 768;
  static const double _tabletBreak = 1100;

  static ScreenSize of(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < _mobileBreak) return ScreenSize.mobile;
    if (w < _tabletBreak) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      of(context) == ScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenSize.desktop;

  /// Mobile or Tablet (not desktop)
  static bool isSmall(BuildContext context) =>
      of(context) != ScreenSize.desktop;

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    switch (of(context)) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? desktop;
      case ScreenSize.desktop:
        return desktop;
    }
  }

  static double padding(BuildContext context) =>
      value(context, mobile: 16.0, tablet: 20.0, desktop: 24.0);
}
