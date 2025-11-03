import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Theme token model
// ---------------------------------------------------------------------------

class EmotionColors {
  const EmotionColors({
    required this.background,
    required this.border,
    required this.hoverBackground,
    required this.hoverBorder,
    required this.text,
    required this.ring,
    required this.solid,
  });

  final Color background;
  final Color border;
  final Color hoverBackground;
  final Color hoverBorder;
  final Color text;
  final Color ring;
  final Color solid;

  static EmotionColors lerp(EmotionColors? a, EmotionColors? b, double t) {
    if (a == null && b == null) {
      return const EmotionColors(
        background: Colors.transparent,
        border: Colors.transparent,
        hoverBackground: Colors.transparent,
        hoverBorder: Colors.transparent,
        text: Colors.transparent,
        ring: Colors.transparent,
        solid: Colors.transparent,
      );
    }

    return EmotionColors(
      background: Color.lerp(a?.background, b?.background, t) ?? (b?.background ?? a!.background),
      border: Color.lerp(a?.border, b?.border, t) ?? (b?.border ?? a!.border),
      hoverBackground:
          Color.lerp(a?.hoverBackground, b?.hoverBackground, t) ?? (b?.hoverBackground ?? a!.hoverBackground),
      hoverBorder: Color.lerp(a?.hoverBorder, b?.hoverBorder, t) ?? (b?.hoverBorder ?? a!.hoverBorder),
      text: Color.lerp(a?.text, b?.text, t) ?? (b?.text ?? a!.text),
      ring: Color.lerp(a?.ring, b?.ring, t) ?? (b?.ring ?? a!.ring),
      solid: Color.lerp(a?.solid, b?.solid, t) ?? (b?.solid ?? a!.solid),
    );
  }
}

class FeelBetterTheme extends ThemeExtension<FeelBetterTheme> {
  const FeelBetterTheme({
    required this.id,
    required this.name,
    required this.isDark,
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.backgroundHover,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnAccent,
    required this.borderPrimary,
    required this.borderSecondary,
    required this.accentPrimary,
    required this.accentPrimaryHover,
    required this.accentSecondary,
    required this.accentSecondaryHover,
    required this.accentTertiary,
    required this.accentTertiaryHover,
    required this.accentRing,
    required this.shadowColor,
    required this.previewColor,
    required this.emotions,
  });

  final String id;
  final String name;
  final bool isDark;
  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color backgroundHover;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnAccent;
  final Color borderPrimary;
  final Color borderSecondary;
  final Color accentPrimary;
  final Color accentPrimaryHover;
  final Color accentSecondary;
  final Color accentSecondaryHover;
  final Color accentTertiary;
  final Color accentTertiaryHover;
  final Color accentRing;
  final Color shadowColor;
  final Color previewColor;
  final Map<String, EmotionColors> emotions;

  EmotionColors emotion(String key) => emotions[key] ?? emotions.values.first;

  @override
  FeelBetterTheme copyWith({
    bool? isDark,
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? backgroundHover,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnAccent,
    Color? borderPrimary,
    Color? borderSecondary,
    Color? accentPrimary,
    Color? accentPrimaryHover,
    Color? accentSecondary,
    Color? accentSecondaryHover,
    Color? accentTertiary,
    Color? accentTertiaryHover,
    Color? accentRing,
    Color? shadowColor,
    Color? previewColor,
    Map<String, EmotionColors>? emotions,
  }) {
    return FeelBetterTheme(
      id: id,
      name: name,
      isDark: isDark ?? this.isDark,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      backgroundHover: backgroundHover ?? this.backgroundHover,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentPrimaryHover: accentPrimaryHover ?? this.accentPrimaryHover,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      accentSecondaryHover: accentSecondaryHover ?? this.accentSecondaryHover,
      accentTertiary: accentTertiary ?? this.accentTertiary,
      accentTertiaryHover: accentTertiaryHover ?? this.accentTertiaryHover,
      accentRing: accentRing ?? this.accentRing,
      shadowColor: shadowColor ?? this.shadowColor,
      previewColor: previewColor ?? this.previewColor,
      emotions: emotions ?? this.emotions,
    );
  }

  @override
  FeelBetterTheme lerp(covariant FeelBetterTheme? other, double t) {
    if (other == null) return this;
    final mergedKeys = <String>{...emotions.keys, ...other.emotions.keys};

    return FeelBetterTheme(
      id: t < 0.5 ? id : other.id,
      name: t < 0.5 ? name : other.name,
      isDark: t < 0.5 ? isDark : other.isDark,
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t) ?? backgroundPrimary,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t) ?? backgroundSecondary,
      backgroundTertiary: Color.lerp(backgroundTertiary, other.backgroundTertiary, t) ?? backgroundTertiary,
      backgroundHover: Color.lerp(backgroundHover, other.backgroundHover, t) ?? backgroundHover,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t) ?? textOnAccent,
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t) ?? borderPrimary,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t) ?? borderSecondary,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t) ?? accentPrimary,
      accentPrimaryHover: Color.lerp(accentPrimaryHover, other.accentPrimaryHover, t) ?? accentPrimaryHover,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t) ?? accentSecondary,
      accentSecondaryHover:
          Color.lerp(accentSecondaryHover, other.accentSecondaryHover, t) ?? accentSecondaryHover,
      accentTertiary: Color.lerp(accentTertiary, other.accentTertiary, t) ?? accentTertiary,
      accentTertiaryHover:
          Color.lerp(accentTertiaryHover, other.accentTertiaryHover, t) ?? accentTertiaryHover,
      accentRing: Color.lerp(accentRing, other.accentRing, t) ?? accentRing,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      previewColor: Color.lerp(previewColor, other.previewColor, t) ?? previewColor,
      emotions: {
        for (final key in mergedKeys)
          key: EmotionColors.lerp(emotions[key], other.emotions[key], t),
      },
    );
  }
}

class ThemeOption {
  const ThemeOption({
    required this.id,
    required this.name,
    required this.previewColor,
  });

  final String id;
  final String name;
  final Color previewColor;
}

// ---------------------------------------------------------------------------
// Theme definitions (mirroring themes.ts from React app)
// ---------------------------------------------------------------------------

class AppTheme {
  static ThemeData themeFor(String id) => _themeData(id, false);
  static ThemeData darkThemeFor(String id) => _themeData(id, true);

  static ThemeData _themeData(String id, bool dark) {
    final targetId = dark ? (_darkFallback[id] ?? id) : id;
    final definition = _definitions[targetId] ?? _definitions['aurora-light']!;
    final FeelBetterTheme tokens = definition.themeExtension;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: tokens.accentPrimary,
      brightness: tokens.isDark ? Brightness.dark : Brightness.light,
      surface: tokens.backgroundSecondary,
    ).copyWith(
      primary: tokens.accentPrimary,
      onPrimary: tokens.textOnAccent,
      secondary: tokens.accentSecondary,
      onSecondary: tokens.textOnAccent,
      tertiary: tokens.accentTertiary,
      onTertiary: tokens.textOnAccent,
      surface: tokens.backgroundSecondary,
      surfaceTint: tokens.accentPrimary,
      primaryContainer: tokens.accentPrimaryHover,
      onPrimaryContainer: tokens.textOnAccent,
      secondaryContainer: tokens.accentSecondaryHover,
      onSecondaryContainer: tokens.textOnAccent,
      tertiaryContainer: tokens.accentTertiaryHover,
      onTertiaryContainer: tokens.textOnAccent,
      onSurface: tokens.textPrimary,
      surfaceContainerHighest: tokens.backgroundTertiary,
      onSurfaceVariant: tokens.textSecondary,
      outline: tokens.borderPrimary,
      outlineVariant: tokens.borderSecondary,
      shadow: tokens.shadowColor,
      scrim: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.8 : 0.4),
    );

    final headlineFont = GoogleFonts.playfairDisplay;
    final bodyFont = GoogleFonts.workSans;

    final textTheme = TextTheme(
      displayLarge: headlineFont(textStyle: const TextStyle(fontSize: 56, fontWeight: FontWeight.w600)),
      displayMedium: headlineFont(textStyle: const TextStyle(fontSize: 48, fontWeight: FontWeight.w600)),
      displaySmall: headlineFont(textStyle: const TextStyle(fontSize: 38, fontWeight: FontWeight.w600)),
      headlineLarge: headlineFont(textStyle: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600)),
      headlineMedium: headlineFont(textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
      headlineSmall: headlineFont(textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
      titleLarge: headlineFont(textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
      titleMedium: headlineFont(textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      titleSmall: headlineFont(textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      bodyLarge: bodyFont(textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, height: 1.48)),
      bodyMedium: bodyFont(textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500, height: 1.48)),
      bodySmall: bodyFont(textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.46)),
      labelLarge: bodyFont(textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
      labelMedium: bodyFont(textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      labelSmall: bodyFont(textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
    ).apply(
      displayColor: tokens.textPrimary,
      bodyColor: tokens.textPrimary,
    );

    final roundedShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: tokens.backgroundPrimary,
      canvasColor: tokens.backgroundPrimary,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      cardColor: tokens.backgroundSecondary,
      shadowColor: tokens.shadowColor,
      dividerColor: tokens.borderPrimary,
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.backgroundSecondary,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: tokens.backgroundSecondary,
        elevation: 8,
        textStyle: TextStyle(color: tokens.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.accentPrimary,
        foregroundColor: tokens.textOnAccent,
      ),
      textTheme: textTheme,
      iconTheme: IconThemeData(color: tokens.textPrimary),
      listTileTheme: ListTileThemeData(
        iconColor: tokens.accentPrimary,
        textColor: tokens.textPrimary,
        tileColor: tokens.backgroundSecondary,
        shape: roundedShape,
        minLeadingWidth: 48,
        horizontalTitleGap: 20,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        selectedColor: tokens.accentPrimary,
        selectedTileColor: tokens.accentPrimary.withValues(alpha: tokens.isDark ? 0.24 : 0.18),
      ),
      cardTheme: CardThemeData(
        color: tokens.backgroundSecondary,
        elevation: tokens.isDark ? 2 : 4,
        shadowColor: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.38 : 0.22),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        surfaceTintColor: tokens.accentPrimary.withValues(alpha: 0.08),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.backgroundSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w600),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.backgroundSecondary,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.backgroundTertiary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: tokens.textSecondary,
          letterSpacing: 0.25,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary.withValues(alpha: 0.7)),
        prefixIconColor: tokens.textSecondary.withValues(alpha: 0.7),
        suffixIconColor: tokens.textSecondary.withValues(alpha: 0.7),
        iconColor: tokens.textSecondary.withValues(alpha: 0.7),
        focusColor: tokens.accentPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: tokens.borderPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: tokens.borderPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: tokens.accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.accentPrimary,
          foregroundColor: tokens.textOnAccent,
          shadowColor: tokens.shadowColor.withValues(alpha: 0.25),
          shape: roundedShape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.accentSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: roundedShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.accentSecondary,
          side: BorderSide(color: tokens.accentSecondary.withValues(alpha: 0.6)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: roundedShape,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.backgroundTertiary,
        selectedColor: tokens.accentPrimary.withValues(alpha: tokens.isDark ? 0.32 : 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: tokens.borderSecondary.withValues(alpha: 0.6)),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: tokens.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.borderPrimary.withValues(alpha: 0.6),
        thickness: 1.2,
        space: 36,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all<double>(6),
        radius: const Radius.circular(12),
        thumbVisibility: const WidgetStatePropertyAll<bool>(true),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => tokens.accentPrimary
              .withValues(alpha: states.contains(WidgetState.dragged) ? 0.78 : 0.42),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[tokens],
    );
  }

  static List<ThemeOption> get themeOptions => _themeOrder
      .where(_definitions.containsKey)
      .map((id) {
        final definition = _definitions[id]!;
        return ThemeOption(id: definition.id, name: definition.name, previewColor: definition.previewColor);
      })
      .toList(growable: false);

  static FeelBetterTheme tokens(BuildContext context) =>
      Theme.of(context).extension<FeelBetterTheme>() ?? _definitions['aurora-light']!.themeExtension;
}

class _EmotionPalette {
  const _EmotionPalette({
    required this.base,
    required this.hover,
    required this.text,
    required this.ring,
  });

  final Color base;
  final Color hover;
  final Color text;
  final Color ring;
}

class _ThemeDefinition {
  const _ThemeDefinition({
    required this.id,
    required this.name,
    required this.isDark,
    required this.previewColor,
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.backgroundHover,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnAccent,
    required this.borderPrimary,
    required this.borderSecondary,
    required this.accentPrimary,
    required this.accentPrimaryHover,
    required this.accentSecondary,
    required this.accentSecondaryHover,
    required this.accentTertiary,
    required this.accentTertiaryHover,
    required this.accentRing,
    required this.shadowColor,
    required this.palette,
  });

  final String id;
  final String name;
  final bool isDark;
  final Color previewColor;
  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color backgroundHover;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnAccent;
  final Color borderPrimary;
  final Color borderSecondary;
  final Color accentPrimary;
  final Color accentPrimaryHover;
  final Color accentSecondary;
  final Color accentSecondaryHover;
  final Color accentTertiary;
  final Color accentTertiaryHover;
  final Color accentRing;
  final Color shadowColor;
  final Map<String, _EmotionPalette> palette;

  FeelBetterTheme get themeExtension => FeelBetterTheme(
        id: id,
        name: name,
        isDark: isDark,
        backgroundPrimary: backgroundPrimary,
        backgroundSecondary: backgroundSecondary,
        backgroundTertiary: backgroundTertiary,
        backgroundHover: backgroundHover,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        textOnAccent: textOnAccent,
        borderPrimary: borderPrimary,
        borderSecondary: borderSecondary,
        accentPrimary: accentPrimary,
        accentPrimaryHover: accentPrimaryHover,
        accentSecondary: accentSecondary,
        accentSecondaryHover: accentSecondaryHover,
        accentTertiary: accentTertiary,
        accentTertiaryHover: accentTertiaryHover,
        accentRing: accentRing,
        shadowColor: shadowColor,
        previewColor: previewColor,
        emotions: _buildEmotionTokens(isDark, palette),
      );
}

Map<String, EmotionColors> _buildEmotionTokens(
  bool isDark,
  Map<String, _EmotionPalette> palette,
) {
  final backgroundOpacity = isDark ? 0.15 : 0.1;
  final hoverOpacity = isDark ? 0.25 : 0.2;
  final borderOpacity = isDark ? 0.3 : 0.2;
  final hoverBorderOpacity = isDark ? 0.4 : 0.3;

  return {
    for (final entry in palette.entries)
      entry.key: EmotionColors(
        background: entry.value.base.withValues(alpha: backgroundOpacity),
        border: entry.value.base.withValues(alpha: borderOpacity),
        hoverBackground: entry.value.hover.withValues(alpha: hoverOpacity),
        hoverBorder: entry.value.hover.withValues(alpha: hoverBorderOpacity),
        text: entry.value.text,
        ring: entry.value.ring,
        solid: entry.value.base,
      ),
  };
}

const List<String> _themeOrder = <String>[
  'aurora-light',
  'calm-light',
  'serene-light',
  'forest-light',
  'aurora-dark',
  'dusk-dark',
  'serene-dark',
  'tide-dark',
  'forest-dark',
];

final Map<String, String> _darkFallback = <String, String>{
  'aurora-light': 'aurora-dark',
  'calm-light': 'dusk-dark',
  'serene-light': 'serene-dark',
  'forest-light': 'forest-dark',
  'dusk-dark': 'dusk-dark',
  'tide-dark': 'tide-dark',
  'serene-dark': 'serene-dark',
  'forest-dark': 'forest-dark',
  'aurora-dark': 'aurora-dark',
};

const Map<String, _EmotionPalette> _auroraLightPalette = <String, _EmotionPalette>{
  'purple': _EmotionPalette(base: Color(0xFFA855F7), hover: Color(0xFF9333EA), text: Color(0xFF4C1D95), ring: Color(0xFFE9D5FF)),
  'blue': _EmotionPalette(base: Color(0xFF38BDF8), hover: Color(0xFF0EA5E9), text: Color(0xFF0F172A), ring: Color(0xFFBAE6FD)),
  'teal': _EmotionPalette(base: Color(0xFF2DD4BF), hover: Color(0xFF14B8A6), text: Color(0xFF134E4A), ring: Color(0xFFA7F3D0)),
  'rose': _EmotionPalette(base: Color(0xFFF43F5E), hover: Color(0xFFE11D48), text: Color(0xFF881337), ring: Color(0xFFFECDD3)),
  'amber': _EmotionPalette(base: Color(0xFFFBBF24), hover: Color(0xFFF59E0B), text: Color(0xFF78350F), ring: Color(0xFFFDE68A)),
  'slate': _EmotionPalette(base: Color(0xFF6B7280), hover: Color(0xFF4B5563), text: Color(0xFF1F2937), ring: Color(0xFFE5E7EB)),
};

const Map<String, _EmotionPalette> _auroraDarkPalette = <String, _EmotionPalette>{
  'purple': _EmotionPalette(base: Color(0xFF8B5CF6), hover: Color(0xFF7C3AED), text: Color(0xFFE9D5FF), ring: Color(0xFFB19CFD)),
  'blue': _EmotionPalette(base: Color(0xFF60A5FA), hover: Color(0xFF3B82F6), text: Color(0xFFDCEBFF), ring: Color(0xFF94C5FF)),
  'teal': _EmotionPalette(base: Color(0xFF2DD4BF), hover: Color(0xFF14B8A6), text: Color(0xFFCCFBF1), ring: Color(0xFF5EEAD4)),
  'rose': _EmotionPalette(base: Color(0xFFF472B6), hover: Color(0xFFE11D48), text: Color(0xFFFBCFE8), ring: Color(0xFFF9A8D4)),
  'amber': _EmotionPalette(base: Color(0xFFFBBF24), hover: Color(0xFFF59E0B), text: Color(0xFFFFE8BA), ring: Color(0xFFFDE68A)),
  'slate': _EmotionPalette(base: Color(0xFF475569), hover: Color(0xFF334155), text: Color(0xFFC7D2FE), ring: Color(0xFF94A3B8)),
};

const Map<String, _EmotionPalette> _calmPalette = <String, _EmotionPalette>{
  'purple': _EmotionPalette(base: Color(0xFF7C3AED), hover: Color(0xFF6D28D9), text: Color(0xFF5B21B6), ring: Color(0xFFDDD6FE)),
  'blue': _EmotionPalette(base: Color(0xFF2563EB), hover: Color(0xFF1D4ED8), text: Color(0xFF1E3A8A), ring: Color(0xFFBFDBFE)),
  'teal': _EmotionPalette(base: Color(0xFF0F766E), hover: Color(0xFF0D5B54), text: Color(0xFF134E4A), ring: Color(0xFF99F6E4)),
  'rose': _EmotionPalette(base: Color(0xFFDB2777), hover: Color(0xFFBE185D), text: Color(0xFF9D174D), ring: Color(0xFFFBCFE8)),
  'amber': _EmotionPalette(base: Color(0xFFF59E0B), hover: Color(0xFFD97706), text: Color(0xFF92400E), ring: Color(0xFFFDE68A)),
  'slate': _EmotionPalette(base: Color(0xFF475569), hover: Color(0xFF334155), text: Color(0xFF1F2937), ring: Color(0xFFE2E8F0)),
};

const Map<String, _EmotionPalette> _duskPalette = <String, _EmotionPalette>{
  'purple': _EmotionPalette(base: Color(0xFF8B5CF6), hover: Color(0xFF7C3AED), text: Color(0xFFDDD6FE), ring: Color(0xFFB19CFD)),
  'blue': _EmotionPalette(base: Color(0xFF60A5FA), hover: Color(0xFF3B82F6), text: Color(0xFFDDEAFE), ring: Color(0xFF9EC4FE)),
  'teal': _EmotionPalette(base: Color(0xFF2DD4BF), hover: Color(0xFF14B8A6), text: Color(0xFFCCFBF1), ring: Color(0xFF5EEAD4)),
  'rose': _EmotionPalette(base: Color(0xFFF43F5E), hover: Color(0xFFE11D48), text: Color(0xFFFDA4AF), ring: Color(0xFFFF7E9B)),
  'amber': _EmotionPalette(base: Color(0xFFFBBF24), hover: Color(0xFFF59E0B), text: Color(0xFFFEF08A), ring: Color(0xFFFFD166)),
  'slate': _EmotionPalette(base: Color(0xFF64748B), hover: Color(0xFF475569), text: Color(0xFFC7D2FE), ring: Color(0xFFA0AEC0)),
};

const Map<String, _EmotionPalette> _tidePalette = <String, _EmotionPalette>{
  'purple': _EmotionPalette(base: Color(0xFF6366F1), hover: Color(0xFF4F46E5), text: Color(0xFFEEF2FF), ring: Color(0xFF9CA3FF)),
  'blue': _EmotionPalette(base: Color(0xFF38BDF8), hover: Color(0xFF0EA5E9), text: Color(0xFFECFEFF), ring: Color(0xFF7DD3FC)),
  'teal': _EmotionPalette(base: Color(0xFF0EA5E9), hover: Color(0xFF0284C7), text: Color(0xFFE0F2FE), ring: Color(0xFF38C4EB)),
  'rose': _EmotionPalette(base: Color(0xFFE11D48), hover: Color(0xFFBE123C), text: Color(0xFFFDA4AF), ring: Color(0xFFF871A6)),
  'amber': _EmotionPalette(base: Color(0xFFF59E0B), hover: Color(0xFFD97706), text: Color(0xFFFDE68A), ring: Color(0xFFEAB308)),
  'slate': _EmotionPalette(base: Color(0xFF1F2937), hover: Color(0xFF111827), text: Color(0xFFCBD5F5), ring: Color(0xFF94A3B8)),
};

const Map<String, _EmotionPalette> _sereneLightPalette = <String, _EmotionPalette>{
  'purple': _EmotionPalette(base: Color(0xFFC084FC), hover: Color(0xFFB779FF), text: Color(0xFF6B21A8), ring: Color(0xFFF3E8FF)),
  'blue': _EmotionPalette(base: Color(0xFF7DD3FC), hover: Color(0xFF38BDF8), text: Color(0xFF0F172A), ring: Color(0xFFE0F2FE)),
  'teal': _EmotionPalette(base: Color(0xFF5EEAD4), hover: Color(0xFF2DD4BF), text: Color(0xFF115E59), ring: Color(0xFFCCFBF1)),
  'rose': _EmotionPalette(base: Color(0xFFF9A8D4), hover: Color(0xFFF472B6), text: Color(0xFF9D174D), ring: Color(0xFFFDE7F3)),
  'amber': _EmotionPalette(base: Color(0xFFFCD34D), hover: Color(0xFFF59E0B), text: Color(0xFF92400E), ring: Color(0xFFFEF08A)),
  'slate': _EmotionPalette(base: Color(0xFFD1D5DB), hover: Color(0xFF9CA3AF), text: Color(0xFF374151), ring: Color(0xFFE5E7EB)),
};

const Map<String, _EmotionPalette> _sereneDarkPalette = <String, _EmotionPalette>{
  'purple': _EmotionPalette(base: Color(0xFF7C3AED), hover: Color(0xFF6D28D9), text: Color(0xFFE9D5FF), ring: Color(0xFFB996FF)),
  'blue': _EmotionPalette(base: Color(0xFF4C8DFF), hover: Color(0xFF2563EB), text: Color(0xFFD9E5FF), ring: Color(0xFFA8C8FF)),
  'teal': _EmotionPalette(base: Color(0xFF2DD4BF), hover: Color(0xFF14B8A6), text: Color(0xFFCFF5EE), ring: Color(0xFF7DE6D3)),
  'rose': _EmotionPalette(base: Color(0xFFF472B6), hover: Color(0xFFE11D48), text: Color(0xFFFCD6E9), ring: Color(0xFFFFAACF)),
  'amber': _EmotionPalette(base: Color(0xFFFBBF24), hover: Color(0xFFF59E0B), text: Color(0xFFFFE8BB), ring: Color(0xFFFFCB6B)),
  'slate': _EmotionPalette(base: Color(0xFF5B4A40), hover: Color(0xFF46362F), text: Color(0xFFEAD8CC), ring: Color(0xFFBFA899)),
};

const Map<String, _EmotionPalette> _forestLightPalette = <String, _EmotionPalette>{
  'purple': _EmotionPalette(base: Color(0xFFA78BFA), hover: Color(0xFF805AD5), text: Color(0xFF352654), ring: Color(0xFFEDE9FF)),
  'blue': _EmotionPalette(base: Color(0xFF60A5FA), hover: Color(0xFF3B82F6), text: Color(0xFF1E3A8A), ring: Color(0xFFDCEBFF)),
  'teal': _EmotionPalette(base: Color(0xFF34D399), hover: Color(0xFF10B981), text: Color(0xFF065F46), ring: Color(0xFFA7F3D0)),
  'rose': _EmotionPalette(base: Color(0xFFF9A8D4), hover: Color(0xFFF472B6), text: Color(0xFF9F1239), ring: Color(0xFFFDE2F5)),
  'amber': _EmotionPalette(base: Color(0xFFFBBF24), hover: Color(0xFFF59E0B), text: Color(0xFF78350F), ring: Color(0xFFFDE68A)),
  'slate': _EmotionPalette(base: Color(0xFF94A3B8), hover: Color(0xFF64748B), text: Color(0xFF1F2937), ring: Color(0xFFE2E8F0)),
};

const Map<String, _EmotionPalette> _forestDarkPalette = <String, _EmotionPalette>{
  'purple': _EmotionPalette(base: Color(0xFF6D28D9), hover: Color(0xFF5B21B6), text: Color(0xFFD9CFFF), ring: Color(0xFFA78BFA)),
  'blue': _EmotionPalette(base: Color(0xFF2563EB), hover: Color(0xFF1D4ED8), text: Color(0xFFD1E7FF), ring: Color(0xFF7AA2FF)),
  'teal': _EmotionPalette(base: Color(0xFF10B981), hover: Color(0xFF0D9488), text: Color(0xFFCFFEE6), ring: Color(0xFF34D399)),
  'rose': _EmotionPalette(base: Color(0xFFE11D48), hover: Color(0xFFBE123C), text: Color(0xFFFFC4D6), ring: Color(0xFFF472B6)),
  'amber': _EmotionPalette(base: Color(0xFFD97706), hover: Color(0xFFB45309), text: Color(0xFFFFD29A), ring: Color(0xFFFBBF24)),
  'slate': _EmotionPalette(base: Color(0xFF2E3B36), hover: Color(0xFF22302A), text: Color(0xFFBFD8CE), ring: Color(0xFF7BA89A)),
};

final Map<String, _ThemeDefinition> _definitions = <String, _ThemeDefinition>{
  'aurora-light': const _ThemeDefinition(
    id: 'aurora-light',
    name: 'Aurora Light',
    isDark: false,
    previewColor: Color(0xFF8B5CF6),
    backgroundPrimary: Color(0xFFF5F7FB),
    backgroundSecondary: Color(0xFFFFFFFF),
    backgroundTertiary: Color(0xFFE6ECFB),
    backgroundHover: Color(0xFFD9E2F7),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textOnAccent: Colors.white,
    borderPrimary: Color(0xFFE2E8F0),
    borderSecondary: Color(0xFFD1D9E5),
    accentPrimary: Color(0xFF7C3AED),
    accentPrimaryHover: Color(0xFF6D28D9),
    accentSecondary: Color(0xFF0EA5E9),
    accentSecondaryHover: Color(0xFF0284C7),
    accentTertiary: Color(0xFFF59E0B),
    accentTertiaryHover: Color(0xFFD97706),
    accentRing: Color(0xFFDDD6FE),
    shadowColor: Color.fromRGBO(17, 24, 39, 0.12),
    palette: _auroraLightPalette,
  ),
  'aurora-dark': const _ThemeDefinition(
    id: 'aurora-dark',
    name: 'Aurora Dark',
    isDark: true,
    previewColor: Color(0xFF6366F1),
    backgroundPrimary: Color(0xFF0B1020),
    backgroundSecondary: Color(0xFF151B2D),
    backgroundTertiary: Color(0xFF20283C),
    backgroundHover: Color(0xFF273145),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF9CA3AF),
    textOnAccent: Colors.white,
    borderPrimary: Color(0xFF1F2937),
    borderSecondary: Color(0xFF2B3547),
    accentPrimary: Color(0xFF6366F1),
    accentPrimaryHover: Color(0xFF4F46E5),
    accentSecondary: Color(0xFF38BDF8),
    accentSecondaryHover: Color(0xFF0EA5E9),
    accentTertiary: Color(0xFFF59E0B),
    accentTertiaryHover: Color(0xFFD97706),
    accentRing: Color(0xFF8B5CF6),
    shadowColor: Color.fromRGBO(8, 12, 24, 0.55),
    palette: _auroraDarkPalette,
  ),
  'calm-light': const _ThemeDefinition(
    id: 'calm-light',
    name: 'Calm Light',
    isDark: false,
    previewColor: Color(0xFF7C3AED),
    backgroundPrimary: Color(0xFFF7FAFC),
    backgroundSecondary: Color(0xFFFFFFFF),
    backgroundTertiary: Color(0xFFEFF4FB),
    backgroundHover: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    textOnAccent: Colors.white,
    borderPrimary: Color(0xFFE2E8F0),
    borderSecondary: Color(0xFFD1D5DB),
    accentPrimary: Color(0xFF7C3AED),
    accentPrimaryHover: Color(0xFF6D28D9),
    accentSecondary: Color(0xFF2563EB),
    accentSecondaryHover: Color(0xFF1D4ED8),
    accentTertiary: Color(0xFF0F766E),
    accentTertiaryHover: Color(0xFF115E59),
    accentRing: Color(0xFFDDD6FE),
    shadowColor: Color.fromRGBO(15, 23, 42, 0.12),
    palette: _calmPalette,
  ),
  'dusk-dark': const _ThemeDefinition(
    id: 'dusk-dark',
    name: 'Dusk Dark',
    isDark: true,
    previewColor: Color(0xFF8B5CF6),
    backgroundPrimary: Color(0xFF111827),
    backgroundSecondary: Color(0xFF1F2937),
    backgroundTertiary: Color(0xFF273248),
    backgroundHover: Color(0xFF334155),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF9CA3AF),
    textOnAccent: Colors.white,
    borderPrimary: Color(0xFF334155),
    borderSecondary: Color(0xFF475569),
    accentPrimary: Color(0xFF8B5CF6),
    accentPrimaryHover: Color(0xFF7C3AED),
    accentSecondary: Color(0xFF60A5FA),
    accentSecondaryHover: Color(0xFF3B82F6),
    accentTertiary: Color(0xFFF59E0B),
    accentTertiaryHover: Color(0xFFD97706),
    accentRing: Color(0xFFB19CFD),
    shadowColor: Color.fromRGBO(0, 0, 0, 0.45),
    palette: _duskPalette,
  ),
  'tide-dark': const _ThemeDefinition(
    id: 'tide-dark',
    name: 'Tide Dark',
    isDark: true,
    previewColor: Color(0xFF38BDF8),
    backgroundPrimary: Color(0xFF081229),
    backgroundSecondary: Color(0xFF0F172A),
    backgroundTertiary: Color(0xFF15213A),
    backgroundHover: Color(0xFF1E2B45),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF94A3B8),
    textOnAccent: Colors.white,
    borderPrimary: Color(0xFF1E40AF),
    borderSecondary: Color(0xFF1C3A6B),
    accentPrimary: Color(0xFF38BDF8),
    accentPrimaryHover: Color(0xFF0EA5E9),
    accentSecondary: Color(0xFF2DD4BF),
    accentSecondaryHover: Color(0xFF14B8A6),
    accentTertiary: Color(0xFFF472B6),
    accentTertiaryHover: Color(0xFFE11D48),
    accentRing: Color(0xFF7DD3FC),
    shadowColor: Color.fromRGBO(8, 18, 41, 0.55),
    palette: _tidePalette,
  ),
  'serene-light': const _ThemeDefinition(
    id: 'serene-light',
    name: 'Serene Light',
    isDark: false,
    previewColor: Color(0xFFEE8F57),
    backgroundPrimary: Color(0xFFFFFBF5),
    backgroundSecondary: Color(0xFFFFF7ED),
    backgroundTertiary: Color(0xFFF8EFE5),
    backgroundHover: Color(0xFFEBDACF),
    textPrimary: Color(0xFF3D2F2F),
    textSecondary: Color(0xFF7A6759),
    textOnAccent: Colors.white,
    borderPrimary: Color(0xFFEAD9C9),
    borderSecondary: Color(0xFFD6C2B2),
    accentPrimary: Color(0xFFEE8F57),
    accentPrimaryHover: Color(0xFFDD7A42),
    accentSecondary: Color(0xFFC084FC),
    accentSecondaryHover: Color(0xFFB779FF),
    accentTertiary: Color(0xFF34D399),
    accentTertiaryHover: Color(0xFF10B981),
    accentRing: Color(0xFFFFDBC2),
    shadowColor: Color.fromRGBO(115, 72, 32, 0.12),
    palette: _sereneLightPalette,
  ),
  'serene-dark': const _ThemeDefinition(
    id: 'serene-dark',
    name: 'Serene Dark',
    isDark: true,
    previewColor: Color(0xFFF39A62),
    backgroundPrimary: Color(0xFF201915),
    backgroundSecondary: Color(0xFF2A221D),
    backgroundTertiary: Color(0xFF362C26),
    backgroundHover: Color(0xFF43352D),
    textPrimary: Color(0xFFF7E9DF),
    textSecondary: Color(0xFFD7C2B4),
    textOnAccent: Colors.white,
    borderPrimary: Color(0xFF4A3A2F),
    borderSecondary: Color(0xFF5D483D),
    accentPrimary: Color(0xFFF39A62),
    accentPrimaryHover: Color(0xFFE1834C),
    accentSecondary: Color(0xFFC084FC),
    accentSecondaryHover: Color(0xFFB779FF),
    accentTertiary: Color(0xFF38BDF8),
    accentTertiaryHover: Color(0xFF0EA5E9),
    accentRing: Color(0xFFFFD7B7),
    shadowColor: Color.fromRGBO(0, 0, 0, 0.55),
    palette: _sereneDarkPalette,
  ),
  'forest-light': const _ThemeDefinition(
    id: 'forest-light',
    name: 'Forest Light',
    isDark: false,
    previewColor: Color(0xFF2F855A),
    backgroundPrimary: Color(0xFFF1F8F4),
    backgroundSecondary: Color(0xFFFFFFFF),
    backgroundTertiary: Color(0xFFE3F2EA),
    backgroundHover: Color(0xFFD1E8DD),
    textPrimary: Color(0xFF1E3A32),
    textSecondary: Color(0xFF527269),
    textOnAccent: Colors.white,
    borderPrimary: Color(0xFFCCE2D6),
    borderSecondary: Color(0xFFB5D5C7),
    accentPrimary: Color(0xFF2F855A),
    accentPrimaryHover: Color(0xFF276749),
    accentSecondary: Color(0xFF2563EB),
    accentSecondaryHover: Color(0xFF1D4ED8),
    accentTertiary: Color(0xFFF59E0B),
    accentTertiaryHover: Color(0xFFD97706),
    accentRing: Color(0xFFA7F3D0),
    shadowColor: Color.fromRGBO(17, 34, 27, 0.12),
    palette: _forestLightPalette,
  ),
  'forest-dark': const _ThemeDefinition(
    id: 'forest-dark',
    name: 'Forest Dark',
    isDark: true,
    previewColor: Color(0xFF34D399),
    backgroundPrimary: Color(0xFF0F1C18),
    backgroundSecondary: Color(0xFF152825),
    backgroundTertiary: Color(0xFF1E3731),
    backgroundHover: Color(0xFF24423D),
    textPrimary: Color(0xFFE2F5ED),
    textSecondary: Color(0xFF9BC9B9),
    textOnAccent: Colors.white,
    borderPrimary: Color(0xFF1F4237),
    borderSecondary: Color(0xFF2E5C4B),
    accentPrimary: Color(0xFF34D399),
    accentPrimaryHover: Color(0xFF10B981),
    accentSecondary: Color(0xFF60A5FA),
    accentSecondaryHover: Color(0xFF3B82F6),
    accentTertiary: Color(0xFFFBBF24),
    accentTertiaryHover: Color(0xFFF59E0B),
    accentRing: Color(0xFF6EE7B7),
    shadowColor: Color.fromRGBO(0, 0, 0, 0.5),
    palette: _forestDarkPalette,
  ),
};
