import 'package:flutter/material.dart';
import 'package:social_sense/services/database.dart';

class ConversationLog extends StatefulWidget {
  final String userId;
  final String topic;
  final String conversationId;

  ConversationLog({
    required this.userId,
    required this.topic,
    required this.conversationId,
  });

  @override
  _ConversationLogState createState() => _ConversationLogState();
}

class _ConversationLogState extends State<ConversationLog> {
  Map<String, dynamic>? conversationData;
  bool isLoading = true;
  String userName = "";
  String buddyName = "";
  String buddyType = "";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await Future.wait([
      _loadConversationData(),
      _loadUserData(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadConversationData() async {
    DatabaseService dbService = DatabaseService(uid: widget.userId);
    Map<String, dynamic>? fetchedData = await dbService.getConversationData(
      userId: widget.userId,
      topic: widget.topic,
      conversationId: widget.conversationId,
    );

    if (mounted) {
      setState(() {
        conversationData = fetchedData;
      });
    }
  }

  Future<void> _loadUserData() async {
    DatabaseService dbService = DatabaseService(uid: widget.userId);
    Map<String, String> buddyData = await dbService.getBuddyInfo();
    Map<String, dynamic>? userData = await dbService.getUserData();

    if (mounted) {
      setState(() {
        buddyName = buddyData["buddyName"] ?? "Buddy";
        buddyType = buddyData["buddy"] ?? "Bear";
        userName = userData?["First Name"] ?? "User";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              "assets/bottomRed_background.png",
              fit: BoxFit.cover,
            ),
          ),

          // Scalable Back button (top right)
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

          // Conversation content
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : conversationData == null
                    ? Center(
                        child: Text(
                          "No conversation data found.",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 100),
                          Text(
                            widget.topic,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 40),
                          Text(
                            "Score: ${conversationData!["score"] ?? "N/A"}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 86, 100, 249),
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: conversationData!["conversationLog"]
                                      ?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> message =
                                    conversationData!["conversationLog"][index];
                                bool isUser = message["role"] == "user";
                                String speakerName =
                                    isUser ? userName : buddyName;
                                String speakerAvatar = isUser
                                    ? "assets/user_avatar.png"
                                    : "assets/animal_${buddyType}.png";

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: isUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    if (!isUser)
                                      Column(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage:
                                                AssetImage(speakerAvatar),
                                            radius: 25,
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            speakerName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (!isUser) SizedBox(width: 10),
                                    Flexible(
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isUser
                                              ? Colors.purple[300]
                                              : Colors.purple[100],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomLeft: isUser
                                                ? Radius.circular(15)
                                                : Radius.zero,
                                            bottomRight: isUser
                                                ? Radius.zero
                                                : Radius.circular(15),
                                          ),
                                        ),
                                        child: Text(
                                          message["content"] ?? "",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isUser) SizedBox(width: 10),
                                    if (isUser)
                                      Column(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage:
                                                AssetImage(speakerAvatar),
                                            radius: 25,
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            speakerName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
