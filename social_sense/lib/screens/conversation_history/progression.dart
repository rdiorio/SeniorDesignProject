import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressionScreen extends StatelessWidget {
  final List<int> scores;

  ProgressionScreen({required this.scores});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    List<FlSpot> spots = List.generate(
      scores.reversed.toList().length, // Reverse the list
      (index) => FlSpot(
          (index + 1).toDouble(), scores.reversed.toList()[index].toDouble()),
    );

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/topOrange_background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            right: screenWidth * 0.04,
            child: SizedBox(
              width: screenWidth * 0.24,
              height: screenHeight * 0.05,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Back",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: scores.isEmpty
                ? Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.12),
                      Text(
                        "Score Progression",
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.09),
                      SizedBox(
                        height: screenHeight * 0.65,
                        child: LineChart(LineChartData(
                          minY: scores
                                  .reduce((a, b) => a < b ? a : b)
                                  .toDouble() -
                              4,
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Score',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              axisNameSize: screenHeight * 0.04,
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                reservedSize: screenWidth * 0.08,
                                getTitlesWidget: (value, meta) {
                                  final minY = scores
                                          .reduce((a, b) => a < b ? a : b)
                                          .toDouble() -
                                      4;

                                  if (value < minY) return Container();
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 4,
                                    child: Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Attempts',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              axisNameSize: screenHeight * 0.04,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: screenHeight * 0.04,
                                interval: (scores.length / 6).ceilToDouble(),
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 1 && index <= scores.length) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 4,
                                      child: Text(
                                        '$index',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: false,
                              color: Colors.blueAccent,
                              barWidth: screenWidth * 0.008,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: screenWidth * 0.012,
                                    color: Colors.blueAccent,
                                    strokeWidth: 0,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        )),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
