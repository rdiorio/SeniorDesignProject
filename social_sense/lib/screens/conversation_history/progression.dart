import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressionScreen extends StatelessWidget {
  final List<int> scores; // List of scores to be plotted

  ProgressionScreen({required this.scores});

  @override
  Widget build(BuildContext context) {
    // Reverse scores for correct order
    List<FlSpot> spots = List.generate(
      scores.length,
      (index) => FlSpot(
        (scores.length - 1 - index).toDouble(), // Reverse X-axis order
        scores[index].toDouble(), // Y-axis values stay same
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text("Progression")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: scores.isEmpty
            ? Center(
                child: Text(
                  "No data available",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : Column(
                children: [
                  Text(
                    "Score Progression",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(),
                                    style: TextStyle(fontSize: 12));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < scores.length) {
                                  return Text(
                                    "${(scores.length - index)}",
                                    style: TextStyle(fontSize: 12),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Colors.blueAccent,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: false),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
