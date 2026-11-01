import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/claim.dart';
import '../../../themes/themes.dart';

/// Touch-interactive bar or line chart for claim evidence data.
class ClaimEvidenceChart extends StatefulWidget {
  const ClaimEvidenceChart({
    super.key,
    required this.chartData,
  });

  final ClaimChartData chartData;

  @override
  State<ClaimEvidenceChart> createState() => _ClaimEvidenceChartState();
}

class _ClaimEvidenceChartState extends State<ClaimEvidenceChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);
    final data = widget.chartData;
    final isLine = data.type == 'line';

    return SdCard(
      accentColor: sd.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SdSectionHeader(
            title: data.title,
            accentColor: sd.accentGold,
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: isLine ? _buildLineChart(sd) : _buildBarChart(sd),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              for (var i = 0; i < data.datasets.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _datasetColor(sd, i),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(data.datasets[i].label, style: theme.textTheme.labelSmall),
                  ],
                ),
            ],
          ),
          if (_touchedIndex != null && _touchedIndex! < data.labels.length) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: sd.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sd.accentGold.withValues(alpha: 0.35)),
              ),
              child: Text(
                _tooltipText(_touchedIndex!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: sd.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _tooltipText(int index) {
    final parts = <String>[widget.chartData.labels[index]];
    for (final ds in widget.chartData.datasets) {
      if (index < ds.values.length) {
        parts.add('${ds.label}: ${ds.values[index]}');
      }
    }
    return parts.join(' · ');
  }

  Widget _buildBarChart(SdTheme sd) {
    final dataset = widget.chartData.datasets.first;
    final maxY = dataset.values.reduce((a, b) => a > b ? a : b) * 1.15;

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: sd.borderSubtle.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= widget.chartData.labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    widget.chartData.labels[i],
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < dataset.values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: dataset.values[i],
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  color: _touchedIndex == i
                      ? sd.accentGold
                      : sd.accentGold.withValues(alpha: 0.65),
                ),
              ],
            ),
        ],
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions) {
              setState(() => _touchedIndex = null);
              return;
            }
            setState(() {
              _touchedIndex = response?.spot?.touchedBarGroupIndex;
            });
          },
        ),
      ),
      duration: AppMotion.standard,
      curve: AppMotion.standardCurve,
    );
  }

  Widget _buildLineChart(SdTheme sd) {
    final dataset = widget.chartData.datasets.first;
    final maxY = dataset.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: sd.borderSubtle.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(v < 10 ? 1 : 0),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= widget.chartData.labels.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  widget.chartData.labels[i],
                  style: Theme.of(context).textTheme.labelSmall,
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions) {
              setState(() => _touchedIndex = null);
              return;
            }
            setState(() {
              _touchedIndex = response?.lineBarSpots?.firstOrNull?.x.toInt();
            });
          },
          touchTooltipData: const LineTouchTooltipData(showOnTopOfTheChartBoxArea: false),
        ),
        lineBarsData: [
          for (var d = 0; d < widget.chartData.datasets.length; d++)
            LineChartBarData(
              spots: [
                for (var i = 0; i < widget.chartData.datasets[d].values.length; i++)
                  FlSpot(i.toDouble(), widget.chartData.datasets[d].values[i]),
              ],
              isCurved: true,
              color: _datasetColor(sd, d),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: _touchedIndex == spot.x.toInt() ? 6 : 4,
                  color: _datasetColor(sd, d),
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: d == 0,
                color: _datasetColor(sd, d).withValues(alpha: 0.12),
              ),
            ),
        ],
      ),
      duration: AppMotion.standard,
      curve: AppMotion.standardCurve,
    );
  }

  Color _datasetColor(SdTheme sd, int index) {
    if (index == 0) return sd.accentGold;
    if (index == 1) return AppColors.success;
    return AppColors.info;
  }
}