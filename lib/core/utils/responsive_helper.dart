import 'package:flutter/material.dart';

/// Responsive Helper untuk mendapatkan ukuran yang sesuai dengan device
class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  // Get screen size
  Size get screenSize => MediaQuery.of(context).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // Device type detection
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // Orientation
  bool get isPortrait => screenHeight > screenWidth;
  bool get isLandscape => screenWidth > screenHeight;

  // Responsive font sizes
  double fontSize({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Responsive spacing
  double spacing({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Responsive sizing untuk width/height
  double size({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Get responsive padding
  EdgeInsets padding({
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

// Extension untuk akses lebih mudah
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);

  bool get isMobile => ResponsiveHelper(this).isMobile;
  bool get isTablet => ResponsiveHelper(this).isTablet;
  bool get isDesktop => ResponsiveHelper(this).isDesktop;
  bool get isPortrait => ResponsiveHelper(this).isPortrait;
  bool get isLandscape => ResponsiveHelper(this).isLandscape;
}