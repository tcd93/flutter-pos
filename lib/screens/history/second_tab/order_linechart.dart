import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../theme/rally.dart';

import '../../../provider/src.dart';

class HistoryOrderLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryOrderSupplier>(context);

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(48, 60, 48, 48),
      child: _drawLineChart(context, provider.group()),
    );
  }

  /// for bigger number `getEfficientInterval` still display too much
  /// this is a adjustment to that issue
  double _interval(List<List<dynamic>> groupedData) {
    final maxVal = groupedData.fold<double>(0.0, (prev, e) {
      if (prev < e[1]) {
        return e[1];
      }
      return prev;
    });
    final minVal = groupedData.fold<double>(double.maxFinite, (prev, e) {
      if (prev >= e[1] && e[1] > 0) {
        return e[1];
      }
      return prev;
    });
    const maxSteps = 19;
    final expectedInterval = (maxVal % minVal) != 0 ? (maxVal % minVal) : minVal;
    final expectedSteps = maxVal ~/ expectedInterval;
    final modifier = (expectedSteps ~/ maxSteps) + 1;
    return expectedInterval * modifier;
  }

  Widget _drawLineChart(BuildContext context, List<List<dynamic>> groupedData) {
    var showTooltipsOnAllSpots = false;
    final spots = _mapGroupDataToSpots(groupedData);
    final mainChart = LineChartBarData(
      spots: spots,
      colors: [
        RallyColors.primaryColor,
      ],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      isCurved: true,
      curveSmoothness: 0.2,
      preventCurveOverShooting: true,
      belowBarData: BarAreaData(show: false),
    );
    return spots.isEmpty
        ? const Center(child: Text('No data'))
        : StatefulBuilder(
            builder: (context, setState) => LineChart(
              LineChartData(
                backgroundColor: RallyColors.primaryBackground,
                lineTouchData: LineTouchData(
                  // show tooltips on all spots on long tap
                  touchCallback: (FlTouchEvent event, BaseTouchResponse? touchResponse) {
                    if (event is FlLongPressStart) {
                      setState(() => showTooltipsOnAllSpots = true);
                    } else if (event is FlLongPressEnd) {
                      setState(() => showTooltipsOnAllSpots = false);
                    }
                  },
                  // must disable this for showingTooltipIndicators to work
                  handleBuiltInTouches: !showTooltipsOnAllSpots,
                  touchSpotThreshold: 20.0,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: RallyColors.gray),
                    bottom: BorderSide(color: RallyColors.gray),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (_, __) => Theme.of(context).textTheme.bodyText2,
                    margin: 12.0,
                    interval: _interval(groupedData),
                  ),
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (_, __) => Theme.of(context).textTheme.bodyText2,
                    margin: 24.0,
                    // convert index value back to yyyymmdd
                    getTitles: (idx) => groupedData[idx.toInt()][0],
                  ),
                ),
                gridData: FlGridData(show: false),
                minY: 0.0,
                showingTooltipIndicators: showTooltipsOnAllSpots
                    ? [
                        ...spots.map(
                          (spot) => ShowingTooltipIndicators([LineBarSpot(mainChart, 0, spot)]),
                        ),
                      ]
                    : [],
                lineBarsData: [mainChart],
              ),
            ),
          );
  }

  List<FlSpot> _mapGroupDataToSpots(List<List<dynamic>> groupedData) {
    return groupedData.asMap().entries.map((entry) {
      // second element of the inner list is set as the value
      return FlSpot(entry.key.toDouble(), entry.value[1]);
    }).toList();
  }
}
