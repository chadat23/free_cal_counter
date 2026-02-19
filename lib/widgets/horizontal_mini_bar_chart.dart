import 'package:flutter/material.dart';

class HorizontalMiniBarChart extends StatelessWidget {
  final double consumed;
  final double target;
  final Color color;
  final String macroLabel;
  final String unitLabel;
  final bool showConsumed;

  static const double _maxVisualRatio = 1.15;

  const HorizontalMiniBarChart({
    super.key,
    required this.consumed,
    required this.target,
    required this.color,
    required this.macroLabel,
    this.unitLabel = '',
    this.showConsumed = true,
  });

  @override
  Widget build(BuildContext context) {
    final double displayValue = showConsumed ? consumed : (target - consumed);

    final double rawRatio = target > 0 ? displayValue / target : 0.0;

    final double clampedRatio = rawRatio.clamp(0.0, _maxVisualRatio);

    final double visualRatio = clampedRatio / _maxVisualRatio;

    final double hundredPercentX = 1.0 / _maxVisualRatio;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$macroLabel '
            '${displayValue.toStringAsFixed(0)} / '
            '${target.toStringAsFixed(0)}$unitLabel',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, barConstraints) {
              return SizedBox(
                width: barConstraints.maxWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: visualRatio,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    if (target > 0)
                      Positioned(
                        left: barConstraints.maxWidth * hundredPercentX - 1,
                        top: 1,
                        bottom: 1,
                        child: Container(width: 2, color: Colors.white),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
