import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:social_sense/services/database.dart';

class PieChartScreen extends StatefulWidget {
  final String userId;
  final String topic;
  final String conversationId;

  PieChartScreen({
    required this.userId,
    required this.topic,
    required this.conversationId,
  });

  @override
  _PieChartScreenState createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  Map<String, dynamic>? classificationData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassificationData();
  }

  Future<void> _loadClassificationData() async {
    DatabaseService dbService = DatabaseService(uid: widget.userId);
    Map<String, dynamic>? conversationData =
        await dbService.getConversationData(
      userId: widget.userId,
      topic: widget.topic,
      conversationId: widget.conversationId,
    );

    if (conversationData != null) {
      setState(() {
        classificationData = {
          "inappropriate": conversationData["inappropriate"] ?? 0,
          "neutral": conversationData["neutral"] ?? 0,
          "non-responsive": conversationData["non-responsive"] ?? 0,
          "off-topic": conversationData["off-topic"] ?? 0,
          "positive": conversationData["positive"] ?? 0,
        };
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/bottomPurple_background.png",
              fit: BoxFit.cover,
            ),
          ),
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
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : classificationData == null
                    ? Center(
                        child: Text(
                          "No classification data found.",
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: screenHeight * 0.2),
                          Text(
                            "Classification Breakdown",
                            style: TextStyle(
                              fontSize: screenWidth * 0.075,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: screenWidth * 0.1,
                                sections:
                                    _generatePieChartSections(screenWidth),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.15),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(double screenWidth) {
    if (classificationData == null) return [];

    Map<String, Color> categoryColors = {
      "positive": Colors.green,
      "neutral": Colors.blue,
      "off-topic": Colors.orange,
      "inappropriate": Colors.red,
      "non-responsive": Colors.grey,
    };
    final Map<String, String> categoryNames = {
      "positive": "Positive",
      "neutral": "Neutral",
      "off-topic": "Off-Topic",
      "inappropriate": "Inappropriate",
      "non-responsive": "Non-Responsive",
    };

    return classificationData!.entries.map((entry) {
      String category = entry.key;
      int value = entry.value ?? 0;

      return PieChartSectionData(
        color: categoryColors[category] ?? Colors.black,
        value: value.toDouble(),
        title: "${categoryNames[category]}\n$value",
        radius: screenWidth * 0.3,
        titleStyle: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
