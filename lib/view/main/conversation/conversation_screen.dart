import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:eventgate_flutter/view/main/conversation/chat/chat_screen.dart';
import 'package:flutter/material.dart';

///import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart'
    as app_auth_provider;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsState();
}

class _ConversationsState extends State<ConversationsScreen> {
  late final int _currentUserId;
  late final String _currentUserIdString;
  final ScrollController _scrollController = ScrollController();
  final baseUrlApi = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    _currentUserId =
        Provider.of<app_auth_provider.AuthProvider>(context, listen: false)
            .user!
            .id;
    _currentUserIdString = _currentUserId.toString();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserData(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrlApi/api/profiles/user/basic?user_id=$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['user'];
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: _currentUserIdString)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No conversations found'));
          }

          final conversations = snapshot.data!.docs;

          return ListView.builder(
            controller: _scrollController,
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];

              final participants =
                  List<String>.from(conversation['participants']);
              final lastMessageRef = conversation['last_message_ref'];
              final contactId =
                  participants.firstWhere((id) => id != _currentUserIdString);

              return _buildConversationTile(
                  conversation.id, contactId, lastMessageRef);
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(String conversationId, String contactId,
      DocumentReference lastMessageRefPath) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(int.parse(contactId)),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(),
            title: Text('Loading user...'),
            subtitle: Text(''),
          );
        }

        if (userSnapshot.hasError) {
          return const ListTile(
            title: Text('Error fetching user'),
            subtitle: Text(''),
          );
        }

        final userData = userSnapshot.data!;
        final profilePicture = userData['profile_picture'] != null
            ? baseUrlApi + userData['profile_picture']
            : 'https://placehold.co/200';
        final name = '${userData['first_name']} ${userData['last_name']}';

        return FutureBuilder<DocumentSnapshot>(
          future: lastMessageRefPath.get(),
          builder: (context, messageSnapshot) {
            if (messageSnapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                leading: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: profilePicture,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.red)),
                  ),
                ),
                title: Text(name),
                subtitle: const Text('Loading message...'),
              );
            }

            if (!messageSnapshot.hasData || !messageSnapshot.data!.exists) {
              return ListTile(
                leading: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: profilePicture,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.red)),
                  ),
                ),
                title: Text(name),
                subtitle: const Text('No message'),
              );
            }

            final messageData =
                messageSnapshot.data!.data() as Map<String, dynamic>;

            //print("Message Data: $messageData");
            //print("Keys: ${messageData.keys}");
            //print("Content: ${messageData['content']}");
            //print("Type of messageData: ${messageData.runtimeType}");

            final lastMessage = messageData['content'] ?? 'No message';
            final timestamp = messageData['updated_at'] as Timestamp?;

            return ListTile(
              leading: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: profilePicture,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error, color: Colors.red)),
                ),
              ),
              title: Text(name),
              subtitle: Text(lastMessage),
              trailing: Text(
                AppUtils.formatTimestamp(timestamp),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                AppUtils.navigateWithFade(
                  context,
                  ChatScreen(
                    contactId: contactId,
                    conversationId: conversationId,
                    contactName: name,
                    contactProfilePicture: profilePicture,
                  ),
                );
                //print('Navigate to $contactId');
              },
            );
          },
        );
      },
    );
  }
}
