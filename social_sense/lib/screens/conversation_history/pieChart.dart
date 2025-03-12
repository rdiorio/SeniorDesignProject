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

  // Fetch classification data from Firestore
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
    return Scaffold(
      appBar: AppBar(title: Text("Conversation Analysis")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : classificationData == null
                ? Center(
                    child: Text(
                      "No classification data found.",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Classification Breakdown",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Pie Chart
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _generatePieChartSections(),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  // Generate Pie Chart Data
  List<PieChartSectionData> _generatePieChartSections() {
    if (classificationData == null) return [];

    Map<String, Color> categoryColors = {
      "positive": Colors.green,
      "neutral": Colors.blue,
      "off-topic": Colors.orange,
      "inappropriate": Colors.red,
      "non-responsive": Colors.grey,
    };

    return classificationData!.entries.map((entry) {
      String category = entry.key;
      int value = entry.value ?? 0;

      return PieChartSectionData(
        color: categoryColors[category] ?? Colors.black,
        value: value.toDouble(),
        title: "$category\n$value",
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
