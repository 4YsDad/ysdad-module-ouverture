// Module « Ouverture » — Ysdad 💙
// Écran d'ouverture réutilisable : logo programmeur (3 s), puis image de l'appli (2 s).
// Voir LISEZMOI.md pour l'installation.

import 'dart:async';

import 'package:flutter/material.dart';

/// Couleur de fond sombre assortie au logo Ysdad (évite le flash blanc).
const Color kYsdadSplashBackground = Color(0xFF121212);

/// Chemin d'asset du logo programmeur Ysdad (à déclarer dans pubspec.yaml).
/// Valeur par défaut, pour les applis qui ont copié le logo dans leur `assets/`.
const String kYsdadProgrammerLogoAsset = 'assets/ysdad-logo.png';

/// Logo programmeur inclus dans le paquet `ysdad_ouverture` (dépendance Git) :
/// `YsdadSplash(programmerLogoAsset: kYsdadProgrammerLogoPackageAsset, ...)`.
const String kYsdadProgrammerLogoPackageAsset = 'packages/ysdad_ouverture/assets/ysdad-logo.png';

/// Écran d'ouverture Ysdad.
///
/// 1. Affiche le logo programmeur pendant [programmerDuration] (3 s par défaut)
///    avec un fondu doux.
/// 2. Si [appImage] est fourni et charge correctement, affiche cette image
///    pendant [appImageDuration] (2 s par défaut).
/// 3. Sinon (null ou échec de chargement), passe directement à [child]
///    (ou appelle [onFinished]) après le logo programmeur.
///
/// Ordre recommandé dans l'appli :
/// `YsdadSplash` → (popup À propos 1re ouverture) → `YsdadAuthGate` → accueil.
class YsdadSplash extends StatefulWidget {
  const YsdadSplash({
    super.key,
    required this.child,
    this.appImage,
    this.programmerLogoAsset = kYsdadProgrammerLogoAsset,
    this.programmerDuration = const Duration(seconds: 3),
    this.appImageDuration = const Duration(seconds: 2),
    this.backgroundColor = kYsdadSplashBackground,
    this.fadeDuration = const Duration(milliseconds: 450),
    this.onFinished,
    this.logoMaxWidth = 280,
  });

  /// Contenu affiché une fois l'ouverture terminée (accueil, AuthGate, etc.).
  final Widget child;

  /// Asset de l'image de l'appli (facultatif). Si null ou si le chargement
  /// échoue, on passe directement à [child] après le logo programmeur.
  final String? appImage;

  /// Asset du logo programmeur (par défaut `assets/ysdad-logo.png`).
  final String programmerLogoAsset;

  /// Durée d'affichage du logo programmeur (défaut : 3 s).
  final Duration programmerDuration;

  /// Durée d'affichage de l'image de l'appli (défaut : 2 s).
  final Duration appImageDuration;

  /// Fond sombre (défaut : #121212).
  final Color backgroundColor;

  /// Durée du fondu entre les phases.
  final Duration fadeDuration;

  /// Appelé juste avant d'afficher [child] (facultatif).
  final VoidCallback? onFinished;

  /// Largeur max du logo / de l'image (centrés).
  final double logoMaxWidth;

  @override
  State<YsdadSplash> createState() => _YsdadSplashState();
}

enum _SplashPhase { programmer, appImage, done }

class _YsdadSplashState extends State<YsdadSplash>
    with SingleTickerProviderStateMixin {
  _SplashPhase _phase = _SplashPhase.programmer;
  late final AnimationController _fade;
  late final Animation<double> _opacity;
  Timer? _timer;
  bool _appImageFailed = false;
  bool _precacheStarted = false;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: widget.fadeDuration);
    _opacity = CurvedAnimation(parent: _fade, curve: Curves.easeInOut);
    _fade.forward();
    final path = widget.appImage;
    if (path == null || path.isEmpty) {
      _appImageFailed = true;
    }
    _scheduleNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;
    _precacheAppImage();
  }

  Future<void> _precacheAppImage() async {
    final path = widget.appImage;
    if (path == null || path.isEmpty) {
      _appImageFailed = true;
      return;
    }
    try {
      await precacheImage(AssetImage(path), context);
    } catch (_) {
      _appImageFailed = true;
    }
  }

  void _scheduleNext() {
    _timer?.cancel();
    final wait = _phase == _SplashPhase.programmer
        ? widget.programmerDuration
        : widget.appImageDuration;
    _timer = Timer(wait, _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted || _phase == _SplashPhase.done) return;

    if (_phase == _SplashPhase.programmer) {
      // Afficher l'image d'appli si fournie et pas en échec connu.
      // (Le préchargement accélère l'affichage; errorBuilder gère un échec tardif.)
      final showApp = widget.appImage != null &&
          widget.appImage!.isNotEmpty &&
          !_appImageFailed;
      if (showApp) {
        await _fadeOutIn(() {
          _phase = _SplashPhase.appImage;
        });
        if (mounted) _scheduleNext();
        return;
      }
    }

    await _finish();
  }

  Future<void> _fadeOutIn(VoidCallback changePhase) async {
    if (!mounted) return;
    await _fade.reverse();
    if (!mounted) return;
    setState(changePhase);
    await _fade.forward();
  }

  Future<void> _finish() async {
    if (!mounted || _phase == _SplashPhase.done) return;
    await _fade.reverse();
    if (!mounted) return;
    widget.onFinished?.call();
    setState(() => _phase = _SplashPhase.done);
  }

  void _onImageError() {
    if (_phase == _SplashPhase.programmer) {
      _timer?.cancel();
      _finish();
      return;
    }
    if (_phase == _SplashPhase.appImage) {
      _appImageFailed = true;
      _timer?.cancel();
      _finish();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _SplashPhase.done) {
      return widget.child;
    }

    final String asset = _phase == _SplashPhase.appImage
        ? widget.appImage!
        : widget.programmerLogoAsset;

    return ColoredBox(
      color: widget.backgroundColor,
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.logoMaxWidth),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stack) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _onImageError();
                    });
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
