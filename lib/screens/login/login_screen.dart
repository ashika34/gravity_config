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
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CommonWaveDesign(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final horizontalPadding = screenWidth < 360 ? 16.0 : 24.0;
                final contentWidth = (screenWidth - horizontalPadding * 2)
                    .clamp(0.0, 520.0)
                    .toDouble();
                final viewportHeight = constraints.maxHeight;
                final contentHeight = viewportHeight < 620
                    ? 620.0
                    : viewportHeight;
                final logoWidth = contentWidth < 190
                    ? contentWidth
                    : (contentWidth * 0.52).clamp(190.0, 260.0).toDouble();
                final carouselHeight = (contentHeight * 0.30)
                    .clamp(180.0, 300.0)
                    .toDouble();
                final carouselImageWidth = contentWidth < 210
                    ? contentWidth
                    : (contentWidth * 0.72).clamp(210.0, 360.0).toDouble();
                final buttonWidth = contentWidth < 260
                    ? contentWidth
                    : (contentWidth * 0.76).clamp(260.0, 400.0).toDouble();
                final topGap = (contentHeight * 0.004)
                    .clamp(0.0, 4.0)
                    .roundToDouble();
                final brandToCarouselGap = (contentHeight * 0.045)
                    .clamp(18.0, 42.0)
                    .toDouble();
                final carouselToCtaGap = (contentHeight * 0.028)
                    .clamp(12.0, 30.0)
                    .toDouble();
                final bottomGap = (contentHeight * 0.055)
                    .clamp(28.0, 60.0)
                    .toDouble();

                return SingleChildScrollView(
                  physics: contentHeight > viewportHeight
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewportHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: contentWidth,
                          child: Column(
                            children: [
                              SizedBox(height: topGap),
                              Transform.translate(
                                offset: const Offset(0, -42),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/yaco1.png',
                                      width: logoWidth,
                                      filterQuality: FilterQuality.high,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 15),
                                    const Text(
                                      'CONFIGURATOR',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFE0182D),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: brandToCarouselGap),
                              SizedBox(
                                height: carouselHeight,
                                width: double.infinity,
                                child: FadeTransition(
                                  opacity: _fadeAnim,
                                  child: CarouselWidget3D(
                                    radius: contentWidth,
                                    childScale: 0.9,
                                    dragEndBehavior:
                                        DragEndBehavior.snapToNearest,
                                    backgroundTapBehavior: BackgroundTapBehavior
                                        .startAndSnapToNearest,
                                    childTapBehavior:
                                        ChildTapBehavior.transparent,
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
                                    background: null,
                                    core: null,
                                    children: List.generate(
                                      _carouselImages.length,
                                      (index) => CarouselChild(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                              SizedBox(height: carouselToCtaGap),
                              SlideTransition(
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
                                        width: buttonWidth,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _handleGetStarted(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.accentColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            elevation: 8,
                                            shadowColor: AppTheme.accentColor
                                                .withAlpha(128),
                                            splashFactory:
                                                NoSplash.splashFactory,
                                            overlayColor: Colors.transparent,
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: bottomGap),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
