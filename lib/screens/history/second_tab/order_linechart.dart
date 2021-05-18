import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../theme/rally.dart';

import '../../../provider/src.dart';

class HistoryOrderLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final groupedData = context.select<HistorySupplierByLine, List<List<dynamic>>>(
      (provider) => provider.groupedData,
    );

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(48, 60, 48, 48),
      child: _drawLineChart(context, groupedData),
    );
  }

  Widget _drawLineChart(BuildContext context, List<List<dynamic>> groupedData) {
    final _spots = _mapGroupDataToSpots(groupedData);
    return _spots.isEmpty
        ? Center(child: Text('No data'))
        : LineChart(
            LineChartData(
              backgroundColor: RallyColors.primaryBackground,
              lineTouchData: LineTouchData(
                touchCallback: (LineTouchResponse touchResponse) {},
                handleBuiltInTouches: true,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: SideTitles(showTitles: false),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: Theme.of(context).textTheme.bodyText2 != null
                      ? (value) => Theme.of(context).textTheme.bodyText2!
                      : null,
                  margin: 24.0,
                  // convert index value back to yyyymmdd
                  getTitles: (idx) => groupedData[idx.toInt()][0],
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: _spots,
                  colors: [
                    RallyColors.primaryColor,
                  ],
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
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
