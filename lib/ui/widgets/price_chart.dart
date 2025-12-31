import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/models/price_history.dart';

class PriceChart extends StatelessWidget {
  final List<PriceHistory> priceHistory;

  const PriceChart({super.key, required this.priceHistory});

  @override
  Widget build(BuildContext context) {
    if (priceHistory.isEmpty) {
      return const Center(child: Text('Sin historial de precios'));
    }

    final sortedHistory = List<PriceHistory>.from(priceHistory)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final spots = sortedHistory.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.price,
      );
    }).toList();

    final minPrice = sortedHistory
        .map((e) => e.price)
        .reduce((a, b) => a < b ? a : b);
    final maxPrice = sortedHistory
        .map((e) => e.price)
        .reduce((a, b) => a > b ? a : b);

    final priceRange = maxPrice - minPrice;
    final padding = priceRange * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: priceRange > 0 ? priceRange / 4 : 1000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedHistory.length) {
                  return const SizedBox.shrink();
                }

                // Show only first, middle, and last dates
                if (index != 0 &&
                    index != sortedHistory.length - 1 &&
                    index != sortedHistory.length ~/ 2) {
                  return const SizedBox.shrink();
                }

                final date = sortedHistory[index].recordedAt;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: priceRange > 0 ? priceRange / 4 : 1000,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatPrice(value),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
            left: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
        minX: 0,
        maxX: (sortedHistory.length - 1).toDouble(),
        minY: minPrice - padding,
        maxY: maxPrice + padding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final history = sortedHistory[index];
                return LineTooltipItem(
                  '${history.formattedPrice}\n${DateFormat('dd/MM/yyyy').format(history.recordedAt)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M€';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K€';
    }
    return '${price.toStringAsFixed(0)}€';
  }
}
