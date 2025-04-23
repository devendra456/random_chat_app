import 'package:firebase_database/firebase_database.dart';

import 'user_service.dart';

class MatchingService {
  static final _db = FirebaseDatabase.instance.ref();

  static Future<String?> startMatching(String name) async {
    final userId = await UserService.getUserId();
    final queueRef = _db.child('matchingQueue');
    final queueSnapshot = await queueRef.get();

    String? matchedUid;
    String matchedUserName = "";
    String? chatRoomId;

    for (var child in queueSnapshot.children) {
      if (child.key != userId) {
        matchedUid = child.key;
        final userMap = child.value as Map;
        final userName = userMap['name'] as String;
        matchedUserName = userName;
        break;
      }
    }

    if (matchedUid != null) {
      final matchedRef = _db.child('matchingQueue/$matchedUid');

      final newChatRef = _db.child('chats').push();
      await newChatRef.set({
        'users': {userId: name, matchedUid: matchedUserName},
        'createdAt': DateTime.now().toUtc().toString(),
      });

      chatRoomId = newChatRef.key;
      await matchedRef.update({'chatRoomId': chatRoomId});
      await matchedRef.remove();
      print('Matched with $matchedUid. Chat Room ID: $chatRoomId');
    } else {
      await _db.child('matchingQueue/$userId').set({
        'timestamp': DateTime.now().toUtc().toString(),
        'name': name,
        'chatRoomId': "",
      });

      print('Added to queue. Waiting for match...');
    }

    return chatRoomId;
  }

  static Stream<DatabaseEvent> getMatchingQueueStream() async* {
    final userId = await UserService.getUserId();

    yield* _db.child('matchingQueue/$userId/chatRoomId').onValue;
  }

  static void deleteChat(String chatRoomId) {
    _db.child("chats/$chatRoomId").remove();
  }
}
