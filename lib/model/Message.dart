import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String content;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  Message({
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'sent',
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'senderId': senderId,
      'receiverId': receiverId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      createdAt:
          (json['createdAt'] as Timestamp).toDate(),
      updatedAt:
          (json['updatedAt'] as Timestamp).toDate(),
      status: json['status'],
    );
  }
}
