import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'gallery/gallery.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    for (final name in ['NotoSansSC', 'RobotoMono']) {
      yield LicenseEntryWithLineBreaks([
        name,
      ], await rootBundle.loadString('assets/fonts/$name-OFL.txt'));
    }
  });
  runApp(const GalleryApp());
}

class GalleryApp extends StatefulWidget {
  const GalleryApp({
    super.key,
    this.initialThemeMode,
    this.initialPage,
    this.initialDensity = IanvsDensity.compact,
  });
  final ThemeMode? initialThemeMode;
  final String? initialPage;
  final IanvsDensity initialDensity;
  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late ThemeMode mode;
  late IanvsDensity density;
  late String page;
  Brightness? windowBrightness;
  @override
  void initState() {
    super.initState();
    final params = Uri.base.queryParameters;
    mode =
        widget.initialThemeMode ??
        switch (params['theme']) {
          'light' => ThemeMode.light,
          'system' => ThemeMode.system,
          _ => ThemeMode.dark,
        };
    density = widget.initialDensity;
    page = widget.initialPage ?? params['page'] ?? 'connection';
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Ianvs Design',
    debugShowCheckedModeBanner: false,
    theme: IanvsTheme.build(
      brightness: Brightness.light,
      density: density,
      platform: TargetPlatform.macOS,
      fontFamily: kIsWeb ? 'GallerySans' : null,
      fontFamilyFallback: const ['GallerySans', 'PingFang SC'],
    ),
    darkTheme: IanvsTheme.build(
      brightness: Brightness.dark,
      density: density,
      platform: TargetPlatform.macOS,
      fontFamily: kIsWeb ? 'GallerySans' : null,
      fontFamilyFallback: const ['GallerySans', 'PingFang SC'],
    ),
    themeMode: mode,
    themeAnimationDuration:
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations
        ? Duration.zero
        : IanvsMotion.standard,
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, child) {
      final brightness = Theme.of(context).brightness;
      if (!kIsWeb &&
          defaultTargetPlatform == TargetPlatform.macOS &&
          windowBrightness != brightness) {
        windowBrightness = brightness;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await const MethodChannel(
              'ianvs_design_gallery/window',
            ).invokeMethod<void>('appearance', brightness.name);
          } on MissingPluginException {
            // Widget tests and other hosts do not install the gallery bridge.
          }
        });
      }
      final scale =
          double.tryParse(Uri.base.queryParameters['scale'] ?? '') ?? 1;
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(context).clamp(
            minScaleFactor: scale,
            maxScaleFactor: scale < 1 ? 1 : double.infinity,
          ),
        ),
        child: child!,
      );
    },
    home: GalleryHome(
      initialPage: page,
      themeMode: mode,
      density: density,
      onThemeChanged: (value) => setState(() => mode = value),
      onDensityChanged: (value) => setState(() => density = value),
    ),
  );
}
