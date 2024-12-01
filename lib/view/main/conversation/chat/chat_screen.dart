import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart'
    as app_auth_provider;

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String contactId;
  final String contactName;
  final String contactProfilePicture;

  const ChatScreen({
    required this.conversationId,
    required this.contactId,
    required this.contactName,
    required this.contactProfilePicture,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  late final int _currentUserId;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _currentUserId =
        Provider.of<app_auth_provider.AuthProvider>(context, listen: false)
            .user!
            .id;
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final conversationRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId);

      final messageRef = conversationRef.collection('messages').doc();

      final messageData = {
        'message_id': messageRef.id,
        'content': messageText,
        'sender_id': _currentUserId.toString(),
        'receiver_id': widget.contactId,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      };

      final batch = FirebaseFirestore.instance.batch();
      batch.set(messageRef, messageData);
      batch.update(conversationRef, {'last_message_ref': messageRef});
      await batch.commit();

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    final isSentByCurrentUser =
        messageData['sender_id'] == _currentUserId.toString();
    final createdAt = messageData['created_at'] as Timestamp?;
    final displayTime =
        createdAt != null ? AppUtils.formatTimestamp(createdAt) : 'Sending...';

    return Column(
      crossAxisAlignment: isSentByCurrentUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Bubble(
          margin: const BubbleEdges.only(top: 10),
          alignment:
              isSentByCurrentUser ? Alignment.topRight : Alignment.topLeft,
          nip: isSentByCurrentUser ? BubbleNip.rightTop : BubbleNip.leftTop,
          color: isSentByCurrentUser
              ? const Color.fromARGB(255, 44, 2, 51)
              : Colors.blue,
          child: Text(
            messageData['content'],
            style: TextStyle(
                color: isSentByCurrentUser ? Colors.grey[300] : Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text(
            displayTime,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  /* Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    final isSentByCurrentUser =
        messageData['sender_id'] == _currentUserId.toString();

    return Bubble(
      margin: const BubbleEdges.only(top: 10),
      alignment: isSentByCurrentUser ? Alignment.topRight : Alignment.topLeft,
      nip: isSentByCurrentUser ? BubbleNip.rightTop : BubbleNip.leftTop,
      color: isSentByCurrentUser ? Colors.blue : Colors.grey[300],
      child: Text(
        messageData['content'],
        style:
            TextStyle(color: isSentByCurrentUser ? Colors.white : Colors.black),
      ),
    );
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.contactProfilePicture,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.contactName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    return _buildMessageBubble(messageData);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSendingMessage
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _isSendingMessage ? null : _sendMessage,
                  color: const Color.fromARGB(255, 44, 2, 51),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
