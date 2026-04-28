// lib/features/messages/screens/group_chat_screen.dart
//
// Group chat screen for real-time messaging with 2+ people.
// Supports text messages and file attachments (images, videos, documents).

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:feast/core/core.dart';

class GroupChatScreen extends StatefulWidget {
  final String chatId;
  const GroupChatScreen({super.key, required this.chatId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  Map<String, dynamic>? _chatData;
  Map<String, String> _memberNames = {};
  Map<String, String> _memberAvatars = {};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  Future<void> _loadChatData() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirestorePaths.chats)
        .doc(widget.chatId)
        .get();
    
    if (!mounted) return;
    
    setState(() => _chatData = snap.data());
    await _loadMemberNames();
  }

  Future<void> _loadMemberNames() async {
    if (_chatData == null) return;
    final participants = List<String>.from(_chatData?['participantIds'] as List? ?? []);
    
    for (final uid in participants) {
      final userDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final displayName = data['displayName'] as String?;
        final firstName = data['firstName'] as String? ?? '';
        final lastName = data['lastName'] as String? ?? '';
        final name = displayName ?? '$firstName $lastName'.trim();
        _memberNames[uid] = name.isEmpty ? 'User' : name;
        _memberAvatars[uid] = data['profilePictureUrl'] as String? ?? '';
      }
    }
    if (mounted) setState(() {});
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
        final url = await StorageService.instance
            .uploadChatAttachment(attachmentFile, widget.chatId);
        await FirestoreService.instance.sendMessage(
          chatId: widget.chatId,
          text: '',
          attachmentUrl: url,
        );
      } else if (text != null && text.isNotEmpty) {
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

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: feastLightGreen,
                  child: const Icon(Icons.group, size: 30, color: feastGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _chatData?['groupName'] as String? ?? 'Group Chat',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${_memberNames.length} members',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: feastGray,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.groupDetail,
                      arguments: widget.chatId,
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Members',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ..._memberNames.entries.take(5).map((entry) {
              final isMe = entry.key == _uid;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: feastLightGreen,
                  backgroundImage: _memberAvatars[entry.key]?.isNotEmpty == true
                      ? NetworkImage(_memberAvatars[entry.key]!)
                      : null,
                  child: _memberAvatars[entry.key]?.isEmpty != false
                      ? Text(
                          entry.value.isNotEmpty ? entry.value[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 12, color: feastGreen),
                        )
                      : null,
                ),
                title: Text(
                  entry.value,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isMe
                    ? const Chip(
                        label: Text('You', style: TextStyle(fontSize: 10)),
                        backgroundColor: feastLightGreen,
                      )
                    : null,
              );
            }).toList(),
            if (_memberNames.length > 5)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.groupDetail,
                    arguments: widget.chatId,
                  );
                },
                child: Text('+ ${_memberNames.length - 5} more'),
              ),
            const SizedBox(height: 20),
          ],
        ),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _chatData?['groupName'] as String? ?? 'Group Chat',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${_memberNames.length} members',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showGroupInfo,
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
                  return const Center(
                    child: Text('Error loading messages.'),
                  );
                }

                final messages = snap.data?.docs ?? [];
                
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
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
                    final senderName = _memberNames[msg['senderId']] ?? 'Someone';
                    final senderAvatar = _memberAvatars[msg['senderId']];
                    return _buildMessageBubble(msg, isMine, senderName, senderAvatar);
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

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMine, String senderName, String? senderAvatar) {
    final text = msg['text'] as String? ?? '';
    final attachmentUrl = msg['attachmentUrl'] as String? ?? '';
    final isAttachment = attachmentUrl.isNotEmpty;
    final timestamp = (msg['sentAt'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('h:mm a').format(timestamp) : '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: feastLightGreen,
                      backgroundImage: senderAvatar != null && senderAvatar.isNotEmpty
                          ? NetworkImage(senderAvatar)
                          : null,
                      child: (senderAvatar == null || senderAvatar.isEmpty) && senderName.isNotEmpty
                          ? Text(senderName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 8, color: feastGreen))
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      senderName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: feastGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                    Expanded(
                                      child: Text(
                                        _getFileName(attachmentUrl),
                                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
      // For non-image files, show download option
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Download File'),
          content: Text('Do you want to download ${_getFileName(url)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // You can implement download functionality here
                FeastToast.showInfo(context, 'Download feature coming soon.');
              },
              child: const Text('Download'),
            ),
          ],
        ),
      );
    }
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
