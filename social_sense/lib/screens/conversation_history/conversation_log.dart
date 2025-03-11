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

  //Loads both conversation data and user/buddy info before showing UI
  void _initializeData() async {
    await Future.wait([
      _loadConversationData(),
      _loadUserData(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  // Fetch full conversation data
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

  // Fetch user and buddy info
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
    return Scaffold(
      appBar: AppBar(title: Text("Conversation Log")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator until all data is ready
            : conversationData == null
                ? Center(
                    child: Text(
                      "No conversation data found.",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Date, Topic, and Score
                      Text(
                        widget.topic,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Score: ${conversationData!["score"] ?? "N/A"}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Conversation Log
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              conversationData!["conversationLog"]?.length ?? 0,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> message =
                                conversationData!["conversationLog"][index];
                            bool isUser = message["role"] == "user";
                            String speakerName = isUser ? userName : buddyName;
                            String speakerAvatar = isUser
                                ? "assets/user_avatar.png"
                                : "assets/animal_${buddyType}.png";

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                // **Buddy Avatar & Name (LEFT)**
                                if (!isUser)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                if (!isUser)
                                  SizedBox(
                                      width:
                                          10), // Space between buddy's avatar and message

                                // Speech Bubble
                                Flexible(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 5),
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
                                if (isUser)
                                  SizedBox(
                                      width:
                                          10), // Space between user message and avatar

                                // **User Avatar & Name (RIGHT)**
                                if (isUser)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          color: Colors.grey[700],
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
    );
  }
}
