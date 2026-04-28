// lib/features/messages/screens/selected_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:feast/core/core.dart';

class SelectedChatScreen extends StatefulWidget {
  final String chatId;
  const SelectedChatScreen({super.key, required this.chatId});

  @override
  State<SelectedChatScreen> createState() => _SelectedChatScreenState();
}

class _SelectedChatScreenState extends State<SelectedChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onScroll() {
    // For future pagination implementation
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    
    try {
      await FirestoreService.instance.sendMessage(
        chatId: widget.chatId,
        text: text,
      );
      _scrollToBottom();
    } catch (e) {
      debugPrint('Send message error: $e');
      if (mounted) {
        FeastToast.showError(context, 'Failed to send message. Please try again.');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: feastGreen,
        foregroundColor: Colors.white,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FirestorePaths.chats)
              .doc(widget.chatId)
              .snapshots(),
          builder: (_, snap) {
            if (!snap.hasData || snap.data == null) {
              return const Text('Chat', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16));
            }
            final data = snap.data!.data() as Map<String, dynamic>? ?? {};
            final isGroup = data['isGroup'] as bool? ?? false;
            
            if (isGroup) {
              final name = data['groupName'] as String? ?? 'Group Chat';
              return Text(name, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16));
            }
            
            // For DM, fetch other user's name
            final participants = List<String>.from(data['participantIds'] as List? ?? []);
            final otherId = participants.firstWhere((id) => id != _uid, orElse: () => '');
            if (otherId.isEmpty) {
              return const Text('Chat', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16));
            }
            
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection(FirestorePaths.users).doc(otherId).get(),
              builder: (_, userSnap) {
                if (!userSnap.hasData) {
                  return const Text('Chat', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16));
                }
                final userData = userSnap.data!.data() as Map<String, dynamic>?;
                final displayName = userData?['displayName'] as String?;
                final firstName = userData?['firstName'] as String? ?? '';
                final lastName = userData?['lastName'] as String? ?? '';
                final name = displayName ?? '$firstName $lastName'.trim();
                return Text(name.isEmpty ? 'Chat' : name, 
                  style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16));
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.groupDetail,
              arguments: widget.chatId,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirestorePaths.chats)
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('sentAt', descending: false)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: feastGreen),
                  );
                }

                if (snap.hasError) {
                  debugPrint('Messages error: ${snap.error}');
                  return const Center(
                    child: Text('Error loading messages.'),
                  );
                }

                final messages = snap.data?.docs ?? [];
                
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: TextStyle(fontFamily: 'Outfit', color: feastGray),
                    ),
                  );
                }

                // Auto-scroll to bottom on new messages
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i].data() as Map<String, dynamic>;
                    final isMine = msg['senderId'] == _uid;
                    return _buildMessageBubble(msg, isMine);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: feastLightGreen.withAlpha(120))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: feastGray, size: 22),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => FilePickerModal(
                mode: FilePickerMode.allFiles,
                onConfirm: (files) async {
                  for (final file in files) {
                    final url = await StorageService.instance
                        .uploadChatAttachment(file, widget.chatId);
                    await FirestoreService.instance.sendMessage(
                      chatId: widget.chatId,
                      text: '',
                      attachmentUrl: url,
                    );
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Write a message...',
                hintStyle: TextStyle(color: feastGray.withAlpha(150)),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: feastGreen),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMine) {
    final text = msg['text'] as String? ?? '';
    final attachmentUrl = msg['attachmentUrl'] as String? ?? '';
    final timestamp = (msg['sentAt'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('h:mm a').format(timestamp) : '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine ? feastGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (attachmentUrl.isNotEmpty)
              Image.network(
                attachmentUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
              ),
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: isMine ? Colors.white : feastBlack,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                color: isMine
                    ? Colors.white.withAlpha(180)
                    : feastGray.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
