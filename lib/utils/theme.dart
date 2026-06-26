import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFF050B14);
  static const Color bgCard = Color(0xFF0D1825);
  static const Color bgCard2 = Color(0xFF152032);
  static const Color bgCard3 = Color(0xFF1C2C3F);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanDark = Color(0xFF00B8D9);
  static const Color amber = Color(0xFFFFB300);
  static const Color amberLight = Color(0xFFFFCC44);
  static const Color green = Color(0xFF00E676);
  static const Color greenDark = Color(0xFF00C853);
  static const Color red = Color(0xFFFF3D57);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFFAA00FF);
  static const Color orange = Color(0xFFFF6D00);
  static const Color textW = Color(0xFFFFFFFF);
  static const Color textL = Color(0xFFB0C4D8);
  static const Color textM = Color(0xFF5E7A96);
  static const Color border = Color(0xFF1E3048);
  static const Color adminPurple = Color(0xFF7C4DFF);
  static const Color adminPink = Color(0xFFE040FB);

  static const routeColors = [cyan, green, amber, orange, blue, purple];
  static Color routeColor(int i) => routeColors[i % routeColors.length];
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.cyan,
      secondary: AppColors.amber,
      surface: AppColors.bgCard,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme()
        .apply(bodyColor: AppColors.textL, displayColor: AppColors.textW)
        .copyWith(
          displayLarge: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textW,
            letterSpacing: -0.5,
          ),
          displayMedium: GoogleFonts.spaceGrotesk(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textW,
          ),
          titleLarge: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textW,
          ),
          titleMedium: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textW,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textL,
            height: 1.6,
          ),
          bodyMedium: GoogleFonts.inter(fontSize: 13, color: AppColors.textL),
          bodySmall: GoogleFonts.inter(fontSize: 11, color: AppColors.textM),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.textW),
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textW,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.bg,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cyan,
        side: const BorderSide(color: AppColors.cyan),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgCard2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      labelStyle: GoogleFonts.inter(color: AppColors.textM, fontSize: 13),
      hintStyle: GoogleFonts.inter(color: AppColors.textM, fontSize: 13),
      prefixIconColor: AppColors.textM,
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgCard,
      selectedItemColor: AppColors.cyan,
      unselectedItemColor: AppColors.textM,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 10),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.bgCard2,
      contentTextStyle: GoogleFonts.inter(color: AppColors.textW),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );
}

// Reusable gradient widget
class GradientBg extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final BorderRadius? borderRadius;
  const GradientBg({
    super.key,
    required this.child,
    this.colors,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors ?? [AppColors.cyan.withOpacity(0.12), AppColors.bgCard],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadius,
    ),
    child: child,
  );
}
