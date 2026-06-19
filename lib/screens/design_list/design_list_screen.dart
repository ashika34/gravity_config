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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DesignListProvider>().fetchDesigns();
    });
  }

  int _gridCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    if (width >= 500) return 2;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202020),
        title: const Text(
          'Seat Designs',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CommonWaveDesign(),
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
                      final crossAxisCount = _gridCrossAxisCount(
                        constraints.maxWidth,
                      );
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: provider.designs.length,
                        itemBuilder: (context, index) {
                          return _DesignCard(design: provider.designs[index]);
                        },
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
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surfaceColor,
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
                      color: AppTheme.textLight,
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
                      Text(
                        design.type,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
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
