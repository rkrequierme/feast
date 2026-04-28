// lib/features/messages/screens/selected_chat_screen.dart
//
// Direct Message (1-on-1) chat screen with file attachments support.

import 'dart:io';
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
  String _otherUserName = 'Chat';
  String _otherUserAvatar = '';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadOtherUserInfo();
  }

  Future<void> _loadOtherUserInfo() async {
    final chatDoc = await FirebaseFirestore.instance
        .collection(FirestorePaths.chats)
        .doc(widget.chatId)
        .get();
    
    if (!chatDoc.exists) return;
    
    final data = chatDoc.data()!;
    final participants = List<String>.from(data['participantIds'] as List? ?? []);
    final otherId = participants.firstWhere((id) => id != _uid, orElse: () => '');
    
    if (otherId.isEmpty) return;
    
    final userDoc = await FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(otherId)
        .get();
    
    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final displayName = userData['displayName'] as String?;
      final firstName = userData['firstName'] as String? ?? '';
      final lastName = userData['lastName'] as String? ?? '';
      setState(() {
        _otherUserName = displayName ?? '$firstName $lastName'.trim();
        if (_otherUserName.isEmpty) _otherUserName = 'User';
        _otherUserAvatar = userData['profilePictureUrl'] as String? ?? '';
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({String? text, File? attachmentFile, String? attachmentUrl}) async {
    if (_isSending) return;
    
    setState(() => _isSending = true);
    
    try {
      if (attachmentFile != null) {
        // Upload and send file attachment
        final url = await StorageService.instance
            .uploadChatAttachment(attachmentFile, widget.chatId);
        await FirestoreService.instance.sendMessage(
          chatId: widget.chatId,
          text: '',
          attachmentUrl: url,
        );
      } else if (text != null && text.isNotEmpty) {
        // Send text message
        await FirestoreService.instance.sendMessage(
          chatId: widget.chatId,
          text: text,
        );
      }
      
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        FeastToast.showError(context, 'Failed to send message.');
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAndSendFile() async {
    await showDialog(
      context: context,
      builder: (_) => FilePickerModal(
        mode: FilePickerMode.allFiles,
        onConfirm: (files) async {
          if (files.isNotEmpty) {
            await _sendMessage(attachmentFile: files.first);
          }
        },
      ),
    );
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              backgroundImage: _otherUserAvatar.isNotEmpty ? NetworkImage(_otherUserAvatar) : null,
              child: _otherUserAvatar.isEmpty
                  ? Text(_otherUserName.isNotEmpty ? _otherUserName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 12, color: feastGreen))
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              _otherUserName,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
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

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
            icon: const Icon(Icons.attach_file, color: feastGray, size: 24),
            onPressed: _isSending ? null : _pickAndSendFile,
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
              onSubmitted: (text) => _sendMessage(text: text),
            ),
          ),
          if (_isSending)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: feastGreen),
            )
          else
            IconButton(
              icon: const Icon(Icons.send, color: feastGreen),
              onPressed: () => _sendMessage(text: _messageController.text.trim()),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMine) {
    final text = msg['text'] as String? ?? '';
    final attachmentUrl = msg['attachmentUrl'] as String? ?? '';
    final isAttachment = attachmentUrl.isNotEmpty;
    final timestamp = (msg['sentAt'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('h:mm a').format(timestamp) : '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
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
            if (isAttachment)
              GestureDetector(
                onTap: () => _showAttachmentPreview(attachmentUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _isImageFile(attachmentUrl)
                      ? Image.network(
                          attachmentUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                        )
                      : Container(
                          height: 80,
                          width: double.infinity,
                          color: feastLightGreen.withAlpha(80),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getFileIcon(attachmentUrl),
                                size: 40,
                                color: feastGreen,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getFileName(attachmentUrl),
                                style: const TextStyle(fontFamily: 'Outfit', fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                ),
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

  void _showAttachmentPreview(String url) {
    if (_isImageFile(url)) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black87,
          child: InteractiveViewer(
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      );
    } else {
      // Open URL externally for non-image files
      _launchUrl(url);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    // Use url_launcher to open files
  }

  bool _isImageFile(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') ||
           lowerUrl.endsWith('.jpeg') ||
           lowerUrl.endsWith('.png') ||
           lowerUrl.endsWith('.gif') ||
           lowerUrl.endsWith('.webp');
  }

  IconData _getFileIcon(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lowerUrl.endsWith('.doc') || lowerUrl.endsWith('.docx')) return Icons.description;
    if (lowerUrl.endsWith('.xls') || lowerUrl.endsWith('.xlsx')) return Icons.table_chart;
    if (lowerUrl.endsWith('.mp4') || lowerUrl.endsWith('.mov')) return Icons.video_library;
    if (lowerUrl.endsWith('.mp3') || lowerUrl.endsWith('.wav')) return Icons.audiotrack;
    return Icons.insert_drive_file;
  }

  String _getFileName(String url) {
    final parts = url.split('/');
    final fileName = parts.last;
    if (fileName.contains('?')) {
      return fileName.split('?').first;
    }
    return fileName;
  }
}
