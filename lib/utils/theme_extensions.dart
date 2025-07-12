import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.success,
    required this.failure,
  });

  final Color success;
  final Color failure;

  @override
  CustomColors copyWith({
    Color? success,
    Color? failure,
  }) {
    return CustomColors(
      success: success ?? this.success,
      failure: failure ?? this.failure,
    );
  }

  @override
  CustomColors lerp(CustomColors? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      failure: Color.lerp(failure, other.failure, t)!,
    );
  }

  // Light theme colors
  static const CustomColors light = CustomColors(
    success: Color(0xFF00C853), // Bright green
    failure: Color(0xFFFF1744), // Bright red
  );

  // Dark theme colors
  static const CustomColors dark = CustomColors(
    success:
        Color.fromARGB(255, 23, 146, 54), // Lighter bright green for dark theme
    failure:
        Color.fromARGB(255, 243, 29, 29), // Lighter bright red for dark theme
  );
}

// Extension to easily access custom colors from BuildContext
extension CustomColorsExtension on BuildContext {
  CustomColors get customColors => Theme.of(this).extension<CustomColors>()!;
}
