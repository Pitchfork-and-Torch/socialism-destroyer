/// 4px-base spacing scale for consistent layout rhythm.
abstract final class AppSpacing {
  static const double unit = 4;

  static const double xxs = unit; // 4
  static const double xs = unit * 2; // 8
  static const double sm = unit * 3; // 12
  static const double md = unit * 4; // 16
  static const double lg = unit * 5; // 20
  static const double xl = unit * 6; // 24
  static const double xxl = unit * 8; // 32
  static const double xxxl = unit * 10; // 40

  /// Standard page horizontal padding (mobile).
  static const double pageHorizontal = md;

  /// Standard page horizontal padding (tablet/desktop).
  static const double pageHorizontalWide = xl;

  /// Minimum touch target (WCAG 2.5.5).
  static const double minTouchTarget = 48;
}