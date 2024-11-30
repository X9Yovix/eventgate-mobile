import 'package:eventgate_flutter/model/message.dart';

class Conversation {
  final int id;
  final List<String> participants;
  final List<Message> messages;
  final String? lastMessageId;

  Conversation({
    required this.id,
    required this.participants,
    this.messages = const [],
    this.lastMessageId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'lastMessageId': lastMessageId,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participants: List<String>.from(json['participants']),
      messages: (json['messages'] as List)
          .map((msg) => Message.fromJson(msg))
          .toList(),
      lastMessageId: json['lastMessageId'],
    );
  }
}
