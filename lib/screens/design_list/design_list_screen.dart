import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/design_provider.dart';
import '../../models/seat_design_model.dart';
import '../../core/theme/app_theme.dart';
import '../commondesign/common_wave_design.dart';

class DesignListScreen extends StatefulWidget {
  const DesignListScreen({super.key});

  @override
  State<DesignListScreen> createState() => _DesignListScreenState();
}

class _DesignListScreenState extends State<DesignListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final authenticated = auth.status == AuthStatus.authenticated
          ? true
          : await auth.login();
      if (!mounted) return;
      if (authenticated) {
        context.read<DesignListProvider>().fetchDesigns();
      } else {
        Navigator.of(context).pushReplacementNamed('/');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Login failed'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    });
  }

  int _gridCrossAxisCount(double width) {
    if (width >= 1500) return 5;
    if (width >= 1100) return 4;
    if (width >= 760) return 3;
    if (width >= 360) return 2;
    return 1;
  }

  double _gridAspectRatio(double width) {
    if (width >= 760) return 0.82;
    if (width < 360) return 0.92;
    return 0.78;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202020),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Get Started',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/get-started');
          },
        ),
        title: const Text(
          'Seat Designs',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CommonWaveDesign(),
          if (context.watch<AuthProvider>().status == AuthStatus.loading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            )
          else
            Consumer<DesignListProvider>(
              builder: (context, provider, _) {
                switch (provider.status) {
                  case LoadingStatus.loading:
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentColor,
                      ),
                    );

                  case LoadingStatus.error:
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.accentColor,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.errorMessage ?? 'Failed to load designs',
                            style: const TextStyle(color: AppTheme.textMuted),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: provider.fetchDesigns,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );

                  case LoadingStatus.success:
                  case LoadingStatus.idle:
                    if (provider.designs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No designs available',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final gridWidth = constraints.maxWidth
                            .clamp(0.0, 1440.0)
                            .toDouble();
                        final crossAxisCount = _gridCrossAxisCount(
                          constraints.maxWidth,
                        );
                        final horizontalPadding = constraints.maxWidth >= 760
                            ? 24.0
                            : 16.0;
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1440),
                            child: GridView.builder(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                16,
                                horizontalPadding,
                                150,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: _gridAspectRatio(
                                      gridWidth,
                                    ),
                                  ),
                              itemCount: provider.designs.length,
                              itemBuilder: (context, index) {
                                return _DesignCard(
                                  design: provider.designs[index],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                }
              },
            ),
        ],
      ),
    );
  }
}

class _DesignCard extends StatelessWidget {
  final SeatDesign design;

  const _DesignCard({required this.design});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/configurator', arguments: design.id);
      },
      child: Card(
        color: Colors.white,
        elevation: 7,
        shadowColor: Colors.black.withAlpha(46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E2E2), width: 1.4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: design.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.white,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  // Type badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withAlpha(230),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        design.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    design.nameEn,
                    style: const TextStyle(
                      color: Color(0xFF202020),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.style,
                        size: 13,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          design.type,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppTheme.accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
