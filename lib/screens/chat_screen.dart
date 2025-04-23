import 'dart:async';

import 'package:app/services/matching_service.dart';
import 'package:app/services/user_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final VoidCallback onNewChat;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.onNewChat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final String userId;

  late DatabaseReference _messagesRef;
  final List<Map<dynamic, dynamic>> _messages = [];

  StreamSubscription<DatabaseEvent>? childRemoveSubs;

  @override
  void initState() {
    super.initState();
    getUserId();
    _messagesRef = FirebaseDatabase.instance.ref().child(
      'chats/${widget.chatRoomId}/messages',
    );

    _listenForMessages();
    _listenForChatExist();
  }

  void _listenForChatExist() {
    childRemoveSubs = FirebaseDatabase.instance
        .ref()
        .child('chats/${widget.chatRoomId}')
        .onChildRemoved
        .listen(listenEvent);
  }

  void _listenForMessages() {
    _messagesRef.orderByChild('timestamp').onChildAdded.listen((event) {
      final msg = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _messages.add(msg);
      });

      // Auto scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messagesRef.push().set({
      'sender': userId,
      'message': text,
      'timestamp': DateTime.now().toUtc().toString(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder(
            future:
                FirebaseDatabase.instance
                    .ref()
                    .child('chats/${widget.chatRoomId}/users')
                    .get(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                final data = snapshot.data!.value as Map;
                String name = "";
                data.forEach((key, value) {
                  if (key != userId) {
                    name = value;
                  }
                });
                return Text(name);
              }
              return Text('Chat Room');
            },
          ),
          leading: BackButton(
            onPressed: () {
              _onBackPressed(context);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['sender'] == userId;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['message'] ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle_rounded),
                    onPressed: () {
                      _onBackPressed(context);
                      widget.onNewChat();
                    },
                    color: Colors.blue,
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: _messageController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    Navigator.pop(context);
    MatchingService.deleteChat(widget.chatRoomId);
  }

  void getUserId() async {
    userId = await UserService.getUserId();
  }

  void listenEvent(DatabaseEvent event) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    childRemoveSubs?.cancel();
    super.dispose();
  }
}
