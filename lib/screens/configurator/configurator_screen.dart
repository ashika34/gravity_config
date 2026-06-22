import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/design_provider.dart';
import '../../models/seat_design_detail_model.dart';
import '../../core/theme/app_theme.dart';
import '../commondesign/common_wave_design.dart';

const List<String> _layerDisplayNames = [
  'Primary Color',
  'Central Panel',
  'Thread Color',
];

String _displayLayerName(int index, String fallback) {
  if (index < _layerDisplayNames.length) return _layerDisplayNames[index];
  return fallback;
}

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202020),
        title: const Text(
          'Configurator',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Seat Designs',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/designs');
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CommonWaveDesign(),
          Consumer<DesignDetailProvider>(
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
        ],
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
        final isWide = constraints.maxWidth >= 900;
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1320),
        child: Row(
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
                    Expanded(child: _SeatPreview(provider: provider)),
                  ],
                ),
              ),
            ),
            // Right: layer selectors
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 96),
                child: _LayerSelectorPanel(detail: detail, provider: provider),
              ),
            ),
          ],
        ),
      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageAspectRatio = constraints.maxWidth < 360 ? 0.98 : 1.1;
        final horizontalInset = constraints.maxWidth < 360 ? 8.0 : 10.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalInset + 6,
                      16,
                      horizontalInset + 6,
                      0,
                    ),
                    child: _DesignHeader(detail: detail),
                  ),
                  const SizedBox(height: 12),
                  AspectRatio(
                    aspectRatio: imageAspectRatio,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalInset,
                      ),
                      child: _SeatPreview(provider: provider),
                    ),
                  ),
                  _LayerSelectorPanel(detail: detail, provider: provider),
                ],
              ),
            ),
          ),
        );
      },
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFE2E2E2), width: 1),
              ),
              child: Text(
                detail.currency,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Stacked / layered image ──────────────────────────────────────────────────

enum _SeatBackground {
  white('White', Colors.white),
  grey('Grey', Color(0xFF9E9E9E)),
  black('Black', Colors.black);

  final String label;
  final Color color;

  const _SeatBackground(this.label, this.color);
}

class _SeatPreview extends StatefulWidget {
  final DesignDetailProvider provider;

  const _SeatPreview({required this.provider});

  @override
  State<_SeatPreview> createState() => _SeatPreviewState();
}

class _SeatPreviewState extends State<_SeatPreview> {
  _SeatBackground _selectedBackground = _SeatBackground.white;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Center(
          child: SizedBox.square(
            dimension: side,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _selectedBackground.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _LayeredImage(provider: widget.provider),
                  Positioned(
                    right: 14,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final option in _SeatBackground.values) ...[
                            _BackgroundSwatch(
                              option: option,
                              isSelected: option == _selectedBackground,
                              onTap: () =>
                                  setState(() => _selectedBackground = option),
                            ),
                            if (option != _SeatBackground.values.last)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BackgroundSwatch extends StatelessWidget {
  final _SeatBackground option;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundSwatch({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: option.label,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '${option.label} seat background',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isSelected
                    ? AppTheme.accentColor
                    : const Color(0xFF5A5A5A),
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                border: option == _SeatBackground.white
                    ? Border.all(color: const Color(0xFFD0D0D0))
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 18,
                      color: option == _SeatBackground.black
                          ? Colors.white
                          : Colors.black,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _LayeredImage extends StatelessWidget {
  final DesignDetailProvider provider;

  const _LayeredImage({required this.provider});

  @override
  Widget build(BuildContext context) {
    final detail = provider.detail!;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Variant layers in sort_order (layers are already sorted)
        for (var i = 0; i < detail.layers.length; i++)
          Builder(
            builder: (ctx) {
              final variant = provider.getSelectedVariant(i);
              if (variant == null) return const SizedBox.shrink();
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _NetworkLayerImage(
                  key: ValueKey(variant.image),
                  url: variant.image,
                ),
              );
            },
          ),
        // Base image (bottom layer)
        if (detail.baseImage != null)
          _NetworkLayerImage(url: detail.baseImage!)
        else
          Container(color: Colors.white),
      ],
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

class _LayerSelectorPanel extends StatefulWidget {
  final SeatDesignDetail detail;
  final DesignDetailProvider provider;

  const _LayerSelectorPanel({required this.detail, required this.provider});

  @override
  State<_LayerSelectorPanel> createState() => _LayerSelectorPanelState();
}

class _LayerSelectorPanelState extends State<_LayerSelectorPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int get _tabCount =>
      widget.detail.layers.length < 3 ? widget.detail.layers.length : 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void didUpdateWidget(covariant _LayerSelectorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCount = oldWidget.detail.layers.length < 3
        ? oldWidget.detail.layers.length
        : 3;
    if (oldCount != _tabCount) {
      _tabController.dispose();
      _tabController = TabController(length: _tabCount, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E2E2), width: 1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorColor: AppTheme.accentColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppTheme.accentColor,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: List.generate(
                _tabCount,
                (index) => Tab(
                  text: _displayLayerName(
                    index,
                    widget.detail.layers[index].name,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (
            var layerIndex = 0;
            layerIndex < widget.detail.layers.length;
            layerIndex++
          )
            _LayerRow(
              layer: widget.detail.layers[layerIndex],
              layerIndex: layerIndex,
              provider: widget.provider,
              showHeader: layerIndex >= _tabCount,
              onVariantSelected: () {
                if (layerIndex < _tabCount) {
                  _tabController.animateTo(
                    layerIndex,
                    duration: const Duration(milliseconds: 180),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

class _LayerRow extends StatelessWidget {
  final DesignLayer layer;
  final int layerIndex;
  final DesignDetailProvider provider;
  final bool showHeader;
  final VoidCallback onVariantSelected;

  const _LayerRow({
    required this.layer,
    required this.layerIndex,
    required this.provider,
    this.showHeader = true,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layer name
          if (showHeader) ...[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  _displayLayerName(layerIndex, layer.name),
                  style: const TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${layer.variants.length} options',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
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
                  onTap: () {
                    onVariantSelected();
                    provider.selectVariant(layerIndex, variantIndex);
                  },
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
          color: isSelected ? AppTheme.accentColor.withAlpha(38) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : const Color(0xFFE2E2E2),
            width: 2,
          ),
          boxShadow: isSelected
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
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
                        ),
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
                  color: isSelected ? AppTheme.accentColor : AppTheme.textMuted,
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
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
