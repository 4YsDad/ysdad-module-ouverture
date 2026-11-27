import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ysdad_ouverture/ysdad_ouverture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Test',
      packageName: 'ca.ysdad.test',
      version: '1.0.31',
      buildNumber: '2031',
      buildSignature: '',
    );
  });

  test('ysdadFormatVersionLabel compose le libellé habituel', () {
    expect(
      ysdadFormatVersionLabel(version: '1.0.31', buildNumber: '2031'),
      'Version 1.0.31 (2031)',
    );
    expect(
      ysdadFormatVersionLabel(version: '1.0.31', buildNumber: ''),
      'Version 1.0.31',
    );
    expect(ysdadFormatVersionLabel(version: '', buildNumber: ''), isNull);
  });

  testWidgets('logo 3 s puis l\'appli (sans image d\'appli)', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          child: Text('Accueil'),
        ),
      ),
    );
    expect(find.text('Accueil'), findsNothing);
    expect(find.byKey(const Key('ysdad-ouverture-image')), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    expect(find.text('Accueil'), findsOneWidget);
  });

  testWidgets('l\'image d\'ouverture reste entière (BoxFit.contain)', (
    t,
  ) async {
    await t.pumpWidget(
      const MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: Duration(days: 1),
          child: Text('Accueil'),
        ),
      ),
    );
    final image = t.widget<Image>(
      find.byKey(const Key('ysdad-ouverture-image')),
    );
    expect(image.fit, BoxFit.contain);
    expect(find.text('Accueil'), findsNothing);
  });

  testWidgets('sans backgroundColor, un fond flouté assorti est affiché', (
    t,
  ) async {
    await t.pumpWidget(
      const MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: Duration(days: 1),
          child: Text('Accueil'),
        ),
      ),
    );
    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(
      t.widget<Image>(find.byKey(const Key('ysdad-ouverture-image'))).fit,
      BoxFit.contain,
    );
  });

  testWidgets('backgroundColor uni désactive le fond flouté', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: Duration(days: 1),
          backgroundColor: kYsdadSplashBackground,
          child: Text('Accueil'),
        ),
      ),
    );
    expect(find.byType(ImageFiltered), findsNothing);
    expect(
      t.widget<Image>(find.byKey(const Key('ysdad-ouverture-image'))).fit,
      BoxFit.contain,
    );
  });

  testWidgets('affiche la version automatique dès le logo Ysdad', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: Duration(days: 1),
          child: Text('Accueil'),
        ),
      ),
    );
    await t.pump();
    expect(find.text('Version 1.0.31 (2031)'), findsOneWidget);
    expect(find.byKey(const Key('ysdad-ouverture-version')), findsOneWidget);
    expect(
      t.widget<Image>(find.byKey(const Key('ysdad-ouverture-image'))).fit,
      BoxFit.contain,
    );
  });

  testWidgets('affiche encore la version pendant l\'image de l\'appli', (
    t,
  ) async {
    await t.pumpWidget(
      const MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          appImage: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: Duration(milliseconds: 50),
          appImageDuration: Duration(days: 1),
          fadeDuration: Duration(milliseconds: 1),
          child: Text('Accueil'),
        ),
      ),
    );
    await t.pump();
    expect(find.text('Version 1.0.31 (2031)'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 50));
    await t.pumpAndSettle();
    expect(find.text('Accueil'), findsNothing);
    expect(find.text('Version 1.0.31 (2031)'), findsOneWidget);
    expect(
      t.widget<Image>(find.byKey(const Key('ysdad-ouverture-image'))).fit,
      BoxFit.contain,
    );
  });

  testWidgets('versionLabel impose le libellé affiché', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: Duration(days: 1),
          versionLabel: 'Version 9.9.9 (999)',
          child: Text('Accueil'),
        ),
      ),
    );
    await t.pump();
    expect(find.text('Version 9.9.9 (999)'), findsOneWidget);
    expect(find.text('Version 1.0.31 (2031)'), findsNothing);
  });

  testWidgets('showVersion: false masque la version', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: Duration(days: 1),
          showVersion: false,
          versionLabel: 'Version 9.9.9 (999)',
          child: Text('Accueil'),
        ),
      ),
    );
    await t.pump();
    expect(find.byKey(const Key('ysdad-ouverture-version')), findsNothing);
    expect(find.text('Version 9.9.9 (999)'), findsNothing);
    expect(find.text('Version 1.0.31 (2031)'), findsNothing);
  });

  test('ysdadFormatBuildDate utilise le français et l\'heure de Montréal', () {
    expect(
      ysdadFormatBuildDate(DateTime.parse('2026-11-26T19:15:00-05:00')),
      'publiée le 26 nov. 2026 à 19 h 15',
    );
    expect(
      ysdadFormatBuildDate(DateTime.parse('2026-07-01T23:15:00Z')),
      'publiée le 1 juill. 2026 à 19 h 15',
    );
    expect(
      ysdadFormatBuildDate(DateTime.parse('2026-11-27T00:15:00Z')),
      'publiée le 26 nov. 2026 à 19 h 15',
    );
  });

  test('ysdadParseBuildDate accepte ISO avec ou sans décalage, et -0500', () {
    expect(
      ysdadFormatBuildDate(ysdadParseBuildDate('2026-11-26T19:15:00-05:00')!),
      'publiée le 26 nov. 2026 à 19 h 15',
    );
    expect(
      ysdadFormatBuildDate(ysdadParseBuildDate('2026-11-26T19:15:00-0500')!),
      'publiée le 26 nov. 2026 à 19 h 15',
    );
    expect(
      ysdadFormatBuildDate(ysdadParseBuildDate('2026-11-26T19:15:00')!),
      'publiée le 26 nov. 2026 à 19 h 15',
    );
    expect(
      ysdadFormatBuildDate(ysdadParseBuildDate('2026-07-01T19:15:00')!),
      'publiée le 1 juill. 2026 à 19 h 15',
    );
    expect(ysdadParseBuildDate(''), isNull);
    expect(ysdadParseBuildDate('pas-une-date'), isNull);
  });

  test(
    'ysdadFormatVersionLabel ajoute la date seulement si elle est fournie',
    () {
      expect(
        ysdadFormatVersionLabel(version: '1.0.31', buildNumber: '2031'),
        'Version 1.0.31 (2031)',
      );
      expect(
        ysdadFormatVersionLabel(
          version: '1.0.31',
          buildNumber: '2031',
          buildDate: DateTime.parse('2026-11-26T19:15:00-05:00'),
        ),
        'Version 1.0.31 (2031) · publiée le 26 nov. 2026 à 19 h 15',
      );
      expect(
        ysdadFormatVersionLabel(
          version: '1.0.31',
          buildNumber: '2031',
          buildDate: DateTime.parse('2026-11-26T19:15:00-05:00'),
          showBuildDate: false,
        ),
        'Version 1.0.31 (2031)',
      );
    },
  );

  testWidgets('affiche la date de publication avec la version', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: const Duration(days: 1),
          buildDate: DateTime.parse('2026-11-26T19:15:00-05:00'),
          child: const Text('Accueil'),
        ),
      ),
    );
    await t.pump();
    expect(
      find.text('Version 1.0.31 (2031) · publiée le 26 nov. 2026 à 19 h 15'),
      findsOneWidget,
    );
    expect(
      t.widget<Image>(find.byKey(const Key('ysdad-ouverture-image'))).fit,
      BoxFit.contain,
    );
    expect(find.byType(ImageFiltered), findsOneWidget);
  });

  testWidgets('sans date, seule la version s\'affiche', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: Duration(days: 1),
          child: Text('Accueil'),
        ),
      ),
    );
    await t.pump();
    expect(find.text('Version 1.0.31 (2031)'), findsOneWidget);
    expect(find.textContaining('publiée le'), findsNothing);
  });

  testWidgets('showBuildDate: false masque la date même si elle est fournie', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: YsdadSplash(
          programmerLogoAsset: kYsdadProgrammerLogoPackageAsset,
          programmerDuration: const Duration(days: 1),
          buildDate: DateTime.parse('2026-11-26T19:15:00-05:00'),
          showBuildDate: false,
          child: const Text('Accueil'),
        ),
      ),
    );
    await t.pump();
    expect(find.text('Version 1.0.31 (2031)'), findsOneWidget);
    expect(find.textContaining('publiée le'), findsNothing);
  });
}
