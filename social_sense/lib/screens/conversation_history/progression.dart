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
      scores.length,
      (index) => FlSpot(index.toDouble(), scores[index].toDouble()),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background
          SizedBox.expand(
            child: Image.asset(
              "assets/topOrange_background.png",
              fit: BoxFit.cover,
            ),
          ),

          // Back button (top right, scalable)
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

          // Chart content
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
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.09),
                      SizedBox(
                        height: screenHeight * 0.65,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameSize: screenWidth * 0.08,
                                axisNameWidget: Padding(
                                  padding: EdgeInsets.only(
                                      right: screenWidth * 0.02),
                                  child: Text(
                                    'Score',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.055,
                                    ),
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: screenWidth * 0.08,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          right: screenWidth * 0.01),
                                      child: Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameSize: screenHeight * 0.06,
                                axisNameWidget: Padding(
                                  padding: EdgeInsets.only(
                                      top: screenHeight * 0.015),
                                  child: Text(
                                    'Session',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.055,
                                    ),
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: screenHeight * 0.04,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 0 && index < scores.length) {
                                      return Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                        ),
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
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: Colors.blueAccent,
                                barWidth: screenWidth * 0.008,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
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
                          ),
                        ),
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
