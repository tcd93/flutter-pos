import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../common/common.dart';
import '../../../theme/rally.dart';

import '../../../provider/src.dart';

class HistoryOrderLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryOrderSupplier>(context);
    final displayMultipleDays = provider.selectedRange.duration.inDays >= 1;

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(48, 60, 48, 48),
      child: _drawLineChart(
        context,
        _group(
          provider.orders,
          provider.selectedRange,
          provider.discountFlag,
          displayMultipleDays,
        ),
        displayMultipleDays,
      ),
    );
  }

  /// Returns an ordered map [LinkedHashMap]:
  ///   - If ranges over multiple days, then group by day: {[seconds since epoch]: value}
  ///   - If ranges over one day, then group by time: {[seconds since midnight]: value}
  LinkedHashMap<int, double> _group(
    List<Order> orders,
    DateTimeRange dateRange,
    bool discountFlag,
    bool displayMultipleDays,
  ) {
    return orders.fold(
      LinkedHashMap(),
      (groupedObject, o) {
        int xAxis;
        if (displayMultipleDays) {
          xAxis = (DateUtils.dateOnly(o.checkoutTime).millisecondsSinceEpoch / 1000).floor();
        } else {
          xAxis = _secondsSinceMidnight(o.checkoutTime);
        }

        groupedObject[xAxis] = (groupedObject[xAxis] ?? 0) + o.saleAmount(discountFlag);

        return groupedObject;
      },
    );
  }

  // Extract the seconds since midnight
  int _secondsSinceMidnight(DateTime dateTime) =>
      dateTime.difference(DateUtils.dateOnly(dateTime)).inSeconds;

  // Show in 'hh:mm' format
  String _reverSecondsSinceMidnight(double s) {
    int hour = ((s / 3600) % 24).floor();
    int minute = ((s / 60) % 60).floor();
    // int second = (s.floor()) - (hour * 3600 + minute * 60);
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// for bigger number `getEfficientInterval` still display too much
  /// this is a adjustment to that issue
  num _interval(Iterable<num> array, [int maxSteps = 19]) {
    final maxVal = array.fold<num>(0.0, (prev, curr) {
      if (prev < curr) {
        return curr;
      }
      return prev;
    });
    final minVal = array.fold<num>(double.maxFinite, (prev, curr) {
      if (prev >= curr && curr > 0) {
        return curr;
      }
      return prev;
    });
    final expectedInterval = (maxVal % minVal) != 0 ? (maxVal % minVal) : minVal;
    final expectedSteps = maxVal ~/ expectedInterval;
    final modifier = expectedSteps > maxSteps ? (expectedSteps ~/ maxSteps) + 1 : 1;
    return expectedInterval * modifier;
  }

  Widget _drawLineChart(
    BuildContext context,
    LinkedHashMap<int, double> groupedData,
    bool displayMultipleDays,
  ) {
    var showTooltipsOnAllSpots = false;

    final spots = _mapGroupDataToSpots(groupedData);

    final mainChart = LineChartBarData(
      spots: spots,
      color: RallyColors.primaryColor,
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
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _interval(groupedData.values).toDouble(),
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _interval(groupedData.keys, 23).toDouble(),
                      reservedSize: 40,
                      getTitlesWidget: (x, _) {
                        String text;
                        if (displayMultipleDays) {
                          text = Common.extractYYYYMMDD2(
                            DateTime.fromMillisecondsSinceEpoch((x * 1000).floor()),
                          );
                        } else {
                          text = _reverSecondsSinceMidnight(x);
                        }
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(text),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(),
                  rightTitles: AxisTitles(),
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

  List<FlSpot> _mapGroupDataToSpots(LinkedHashMap<int, double> groupedData) {
    return groupedData.map((x, y) => MapEntry(x, FlSpot(x.toDouble(), y))).values.toList();
  }
}
