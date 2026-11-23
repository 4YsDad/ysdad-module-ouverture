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
}
