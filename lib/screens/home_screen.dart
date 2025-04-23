import 'dart:async';

import 'package:app/services/matching_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  StreamSubscription<DatabaseEvent>? streamSubscription;

  bool loader = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random Chat')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Random Chat',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'End-to-end encryption protects your chats. We have no access to your conversations — they’re never stored, shared, or processed.',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  focusNode: FocusNode(),
                  controller: _usernameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter your display name',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., John Doe',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a display name';
                    }
                    if (value.length < 3) {
                      return 'Display name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                loader
                    ? SizedBox(
                      height: 48,
                      width: 48,
                      child: CircularProgressIndicator.adaptive(),
                    )
                    : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(context).size.width / 2,
                          48,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      label: Text("Start Random Chat"),
                      onPressed: () async {
                        _onPressed(context);
                      },
                      icon: const Icon(Icons.shuffle_rounded),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final name = _usernameController.text;
      setState(() {
        loader = true;
      });
      String? chatRoomId = await MatchingService.startMatching(name);

      if (context.mounted) {
        if (chatRoomId != null) {
          _navigateToChat(context, chatRoomId);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Wait for a match...")));
          streamSubscription = MatchingService.getMatchingQueueStream().listen((
            event,
          ) {
            if (event.snapshot.exists) {
              if (event.snapshot.value != null &&
                  event.snapshot.value.toString().isNotEmpty &&
                  context.mounted) {
                String chatRoomId = event.snapshot.value.toString();
                _navigateToChat(context, chatRoomId);
              }
            }
          });
        }
      }
    }
  }

  void _navigateToChat(BuildContext context, String chatRoomId) {
    streamSubscription?.cancel();
    setState(() {
      loader = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatRoomId: chatRoomId,onNewChat: onNewChat,),
      ),
    );
  }

  void onNewChat() {
    _onPressed(context);
  }
}
