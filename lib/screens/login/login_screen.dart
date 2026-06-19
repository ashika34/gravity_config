import 'package:flutter/material.dart';
import 'package:flutter_3d_carousel/flutter_3d_carousel.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../commondesign/common_wave_design.dart';

const List<String> _carouselImages = [
  'assets/images/pic1.png',
  'assets/images/pic2.png',
  'assets/images/pic3.png',
  'assets/images/pic4.png',
  'assets/images/pic5.png',
  'assets/images/pic6.png',
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleGetStarted(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    authProvider.login();
    Navigator.of(context).pushReplacementNamed('/designs');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = MediaQuery.sizeOf(context);
          final screenWidth = screenSize.width;
          final contentHeight = constraints.maxHeight < 700
              ? 700.0
              : constraints.maxHeight;
          final contentWidth = screenWidth.clamp(320.0, 520.0).toDouble();
          final carouselHeight = (contentHeight * 0.32)
              .clamp(220.0, 310.0)
              .toDouble();
          final carouselImageWidth = (contentWidth * 0.70).clamp(230.0, 360.0);
          final titleTopPadding = (contentHeight * 0.10)
              .clamp(56.0, 88.0)
              .toDouble();
          final carouselTop = (contentHeight * 0.29)
              .clamp(190.0, 300.0)
              .toDouble();
          final buttonBottom = (contentHeight * 0.24)
              .clamp(150.0, 240.0)
              .toDouble();
          final horizontalButtonInset =
              (((screenWidth - contentWidth) / 2) + 60).clamp(
                16.0,
                double.infinity,
              );

          return SingleChildScrollView(
            physics: contentHeight > constraints.maxHeight
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: contentHeight,
              width: screenWidth,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const CommonWaveDesign(),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Padding(
                          padding: EdgeInsets.only(top: titleTopPadding),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'GRAVITY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF202020),
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.8,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Configurator',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFE94560),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: carouselTop,
                    left: 0,
                    right: 0,
                    height: carouselHeight,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: CarouselWidget3D(
                        radius: contentWidth,
                        childScale: 0.9,
                        dragEndBehavior: DragEndBehavior.snapToNearest,
                        backgroundTapBehavior:
                            BackgroundTapBehavior.startAndSnapToNearest,
                        childTapBehavior: ChildTapBehavior.transparent,
                        isDragInteractive: true,
                        onlyRenderForeground: false,
                        clockwise: false,
                        backgroundBlur: 3,
                        spinWhileRotating: true,
                        shouldRotate: true,
                        timeForFullRevolution: 20000,
                        snapTimeInMillis: 100,
                        perspectiveStrength: 0.001,
                        dragSensitivity: 1.0,
                        onValueChanged: (newValue) {
                          debugPrint('$newValue');
                        },
                        background: null,
                        core: null,
                        children: List.generate(
                          _carouselImages.length,
                          (index) => CarouselChild(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: carouselImageWidth,
                                height: carouselHeight,
                                child: Image.asset(
                                  _carouselImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: horizontalButtonInset,
                    right: horizontalButtonInset,
                    bottom: buttonBottom,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Luxury Meets Comfort',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF202020),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 54,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _handleGetStarted(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 8,
                                  shadowColor: AppTheme.accentColor.withAlpha(
                                    128,
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: Colors.transparent,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
