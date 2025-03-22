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
              "assets/bottomOrange_background.png",
              fit: BoxFit.cover,
            ),
          ),

          // Scalable Back Button (top right)
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.05,
            child: SizedBox(
              width: screenWidth * 0.25,
              height: screenHeight * 0.05,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
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
            padding: const EdgeInsets.all(10.0),
            child: scores.isEmpty
                ? Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(height: screenHeight * 0.16),
                      Text(
                        "Score Progression",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      SizedBox(
                        height: screenHeight * 0.70, // Smaller & responsive
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameSize: 40,
                                axisNameWidget: Padding(
                                  padding: EdgeInsets.only(right: 1),
                                  child: Text(
                                    'Score',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 34,
                                    ),
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (value, meta) {
                                    return Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameSize: 60,
                                axisNameWidget: Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Text(
                                    'Session',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 34,
                                    ),
                                  ),
                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 0 && index < scores.length) {
                                      return Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
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
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
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
                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
