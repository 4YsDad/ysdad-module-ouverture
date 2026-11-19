import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ysdad_ouverture/ysdad_ouverture.dart';

void main() {
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
}
