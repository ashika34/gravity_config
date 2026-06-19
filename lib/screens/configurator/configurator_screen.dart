import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/design_provider.dart';
import '../../models/seat_design_detail_model.dart';
import '../../core/theme/app_theme.dart';

class ConfiguratorScreen extends StatefulWidget {
  final int designId;

  const ConfiguratorScreen({super.key, required this.designId});

  @override
  State<ConfiguratorScreen> createState() => _ConfiguratorScreenState();
}

class _ConfiguratorScreenState extends State<ConfiguratorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DesignDetailProvider>().fetchDetail(widget.designId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurator',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<DesignDetailProvider>(
        builder: (context, provider, _) {
          switch (provider.status) {
            case LoadingStatus.loading:
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.accentColor),
              );

            case LoadingStatus.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.accentColor, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage ?? 'Failed to load design',
                      style: const TextStyle(color: AppTheme.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          provider.fetchDetail(widget.designId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );

            case LoadingStatus.success:
            case LoadingStatus.idle:
              if (provider.detail == null) return const SizedBox.shrink();
              return _ConfiguratorBody(provider: provider);
          }
        },
      ),
    );
  }
}

class _ConfiguratorBody extends StatelessWidget {
  final DesignDetailProvider provider;

  const _ConfiguratorBody({required this.provider});

  @override
  Widget build(BuildContext context) {
    final detail = provider.detail!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        if (isWide) {
          return _WideLayout(detail: detail, provider: provider);
        }
        return _NarrowLayout(detail: detail, provider: provider);
      },
    );
  }
}

// ─── Wide layout (tablet / web) ──────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final SeatDesignDetail detail;
  final DesignDetailProvider provider;

  const _WideLayout({required this.detail, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: stacked image
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DesignHeader(detail: detail),
                const SizedBox(height: 20),
                Expanded(child: _LayeredImage(provider: provider)),
              ],
            ),
          ),
        ),
        // Right: layer selectors
        Expanded(
          flex: 4,
          child: _LayerSelectorPanel(detail: detail, provider: provider),
        ),
      ],
    );
  }
}

// ─── Narrow layout (mobile) ───────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final SeatDesignDetail detail;
  final DesignDetailProvider provider;

  const _NarrowLayout({required this.detail, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _DesignHeader(detail: detail),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _LayeredImage(provider: provider),
            ),
          ),
          const SizedBox(height: 4),
          _LayerSelectorPanel(detail: detail, provider: provider),
        ],
      ),
    );
  }
}

// ─── Design header (name + type) ─────────────────────────────────────────────

class _DesignHeader extends StatelessWidget {
  final SeatDesignDetail detail;

  const _DesignHeader({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.nameEn,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentColor, width: 1),
              ),
              child: Text(
                detail.type,
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                detail.currency,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Stacked / layered image ──────────────────────────────────────────────────

class _LayeredImage extends StatelessWidget {
  final DesignDetailProvider provider;

  const _LayeredImage({required this.provider});

  @override
  Widget build(BuildContext context) {
    final detail = provider.detail!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [

          // Variant layers in sort_order (layers are already sorted)
          for (var i = 0; i < detail.layers.length; i++)
            Builder(builder: (ctx) {
              final variant = provider.getSelectedVariant(i);
              if (variant == null) return const SizedBox.shrink();
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _NetworkLayerImage(
                  key: ValueKey(variant.image),
                  url: variant.image,
                ),
              );
            }),
          // Base image (bottom layer)
          if (detail.baseImage != null)
            _NetworkLayerImage(url: detail.baseImage!)
          else
            Container(color: AppTheme.surfaceColor),
        ],
      ),
    );
  }
}

class _NetworkLayerImage extends StatelessWidget {
  final String url;

  const _NetworkLayerImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => const SizedBox.shrink(),
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

// ─── Layer selector panel ─────────────────────────────────────────────────────

class _LayerSelectorPanel extends StatelessWidget {
  final SeatDesignDetail detail;
  final DesignDetailProvider provider;

  const _LayerSelectorPanel(
      {required this.detail, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: detail.layers.length,
      itemBuilder: (context, layerIndex) {
        final layer = detail.layers[layerIndex];
        return _LayerRow(
          layer: layer,
          layerIndex: layerIndex,
          provider: provider,
        );
      },
    );
  }
}

class _LayerRow extends StatelessWidget {
  final DesignLayer layer;
  final int layerIndex;
  final DesignDetailProvider provider;

  const _LayerRow({
    required this.layer,
    required this.layerIndex,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layer name
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                layer.name,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${layer.variants.length} options',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal variant scroll
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: layer.variants.length,
              itemBuilder: (context, variantIndex) {
                final variant = layer.variants[variantIndex];
                final selectedIndex =
                    provider.selectedVariants[layerIndex] ?? 0;
                final isSelected = selectedIndex == variantIndex;

                return _VariantTile(
                  variant: variant,
                  isSelected: isSelected,
                  onTap: () =>
                      provider.selectVariant(layerIndex, variantIndex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  final DesignVariant variant;
  final bool isSelected;
  final VoidCallback onTap;

  const _VariantTile({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  Color _hexColor(String hex) {
    final sanitized = hex.replaceAll('#', '');
    final value = int.tryParse('FF$sanitized', radix: 16) ?? 0xFFAAAAAA;
    return Color(value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withAlpha(38)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Color swatch
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _hexColor(variant.colorCode),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.accentColor : Colors.white24,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.accentColor.withAlpha(77),
                          blurRadius: 6,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                variant.name.split('-').last.trim(),
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.accentColor
                      : AppTheme.textMuted,
                  fontSize: 9,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
