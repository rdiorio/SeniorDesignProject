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
          "non_responsive": conversationData["non_responsive"] ?? 0,
          "off_topic": conversationData["off_topic"] ?? 0,
          "positive": conversationData["positive"] ?? 0,
        };
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              "assets/bottomPurple_background.png",
              fit: BoxFit.cover,
            ),
          ),

          // Back button in top right corner (scalable and consistent)
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

          // Main chart content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60.0),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : classificationData == null
                    ? Center(
                        child: Text(
                          "No classification data found.",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Classification Breakdown",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20), //move text up and down
                          SizedBox(
                            height: 700,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: _generatePieChartSections(),
                              ),
                            ),
                          ),
                          SizedBox(height: 180),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    if (classificationData == null) return [];

    Map<String, Color> categoryColors = {
      "positive": Colors.green,
      "neutral": Colors.blue,
      "off_topic": Colors.orange,
      "inappropriate": Colors.red,
      "non_responsive": Colors.grey,
    };

    return classificationData!.entries.map((entry) {
      String category = entry.key;
      int value = entry.value ?? 0;

      return PieChartSectionData(
        color: categoryColors[category] ?? Colors.black,
        value: value.toDouble(),
        title: "$category\n$value",
        radius: 180,
        titleStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
