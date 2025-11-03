import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PositiveReinforcementBanner extends StatefulWidget {
  const PositiveReinforcementBanner({
    super.key,
    required this.headline,
    required this.detail,
    required this.onDismissed,
    this.displayDuration = const Duration(seconds: 6),
  });

  final String headline;
  final String detail;
  final VoidCallback onDismissed;
  final Duration displayDuration;

  @override
  State<PositiveReinforcementBanner> createState() => _PositiveReinforcementBannerState();
}

class _PositiveReinforcementBannerState extends State<PositiveReinforcementBanner> with SingleTickerProviderStateMixin {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
      _timer = Timer(widget.displayDuration, _handleDismiss);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleDismiss() {
    if (!mounted) return;
    setState(() => _visible = false);
    Future<void>.delayed(const Duration(milliseconds: 240), () {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Dismissible(
        key: const ValueKey('positive-reinforcement-banner'),
        direction: DismissDirection.up,
        onDismissed: (_) => _handleDismiss(),
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 0.4),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            opacity: _visible ? 1 : 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.backgroundSecondary.withValues(alpha: tokens.isDark ? 0.92 : 0.96),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: tokens.accentRing.withValues(alpha: 0.32)),
                boxShadow: [
                  BoxShadow(
                    color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.36 : 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.accentPrimary.withValues(alpha: 0.15),
                      ),
                      child: Icon(Icons.auto_awesome, color: tokens.accentPrimary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.headline,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.detail,
                            style: textTheme.bodySmall?.copyWith(
                              color: tokens.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dismiss',
                      onPressed: _handleDismiss,
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
