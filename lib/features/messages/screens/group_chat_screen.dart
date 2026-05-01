// lib/features/messages/screens/group_chat_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadChatData();
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }
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
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String _getFileIcon(String fileName) {
    final ext = fileName.toLowerCase();
    if (ext.endsWith('.pdf')) return '📄';
    if (ext.endsWith('.doc') || ext.endsWith('.docx')) return '📝';
    if (ext.endsWith('.xls') || ext.endsWith('.xlsx')) return '📊';
    if (ext.endsWith('.ppt') || ext.endsWith('.pptx')) return '📽️';
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.gif') || ext.endsWith('.webp')) return '🖼️';
    if (ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi')) return '🎬';
    if (ext.endsWith('.mp3') || ext.endsWith('.wav') || ext.endsWith('.aac')) return '🎵';
    if (ext.endsWith('.zip') || ext.endsWith('.rar') || ext.endsWith('.7z')) return '📦';
    return '📎';
  }

  bool _isImageFile(String fileName) {
    final ext = fileName.toLowerCase();
    return ext.endsWith('.jpg') ||
           ext.endsWith('.jpeg') ||
           ext.endsWith('.png') ||
           ext.endsWith('.gif') ||
           ext.endsWith('.webp');
  }

  String _getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      return segments.isNotEmpty ? segments.last : 'File';
    } catch (_) {
      return 'File';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _downloadFile(String url, String fileName) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: feastGreen),
              const SizedBox(height: 16),
              Text('Downloading $fileName...', textAlign: TextAlign.center),
            ],
          ),
        ),
      );

      // Get downloads directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = await getExternalStorageDirectory();
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }
      
      final savePath = '${downloadDir!.path}/$fileName';
      
      // Download file
      final dio = Dio();
      await dio.download(url, savePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          // Update progress if needed
        }
      });
      
      // Close progress dialog
      Navigator.pop(context);
      
      // Show success dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: feastSuccess, size: 28),
              SizedBox(width: 8),
              Text('Download Complete'),
            ],
          ),
          content: Text('$fileName has been saved to your device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
                OpenFile.open(savePath);
              },
              style: ElevatedButton.styleFrom(backgroundColor: feastGreen),
              child: const Text('Open'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // Already opened
      }
    } catch (e) {
      Navigator.pop(context); // Close progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: feastError,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _sendMessage({String? text, File? attachmentFile}) async {
    if (_isSending) return;
    
    setState(() => _isSending = true);
    
    try {
      if (attachmentFile != null) {
        final fileName = attachmentFile.path.split('/').last;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ref = FirebaseStorage.instance.ref('chat_attachments/${widget.chatId}/$timestamp-$fileName');
        await ref.putFile(attachmentFile);
        final downloadUrl = await ref.getDownloadURL();
        
        await FirebaseFirestore.instance
            .collection(FirestorePaths.chats)
            .doc(widget.chatId)
            .collection('messages')
            .add({
          'senderId': _uid,
          'text': text ?? '',
          'attachmentUrl': downloadUrl,
          'attachmentName': fileName,
          'sentAt': FieldValue.serverTimestamp(),
          'readBy': [_uid],
        });
        
        final previewText = _isImageFile(fileName) ? '📷 Photo' : '📎 $fileName';
        await FirebaseFirestore.instance
            .collection(FirestorePaths.chats)
            .doc(widget.chatId)
            .update({
          'lastMessage': previewText,
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
      } else if (text != null && text.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(FirestorePaths.chats)
            .doc(widget.chatId)
            .collection('messages')
            .add({
          'senderId': _uid,
          'text': text,
          'attachmentUrl': '',
          'attachmentName': '',
          'sentAt': FieldValue.serverTimestamp(),
          'readBy': [_uid],
        });
        
        await FirebaseFirestore.instance
            .collection(FirestorePaths.chats)
            .doc(widget.chatId)
            .update({
          'lastMessage': text,
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
      }
      
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        FeastToast.showError(context, 'Failed to send: $e');
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      final fileName = result.files.first.name;
      final fileSize = result.files.first.size;
      
      // Only show confirmation for:
      // 1. Non-image files
      // 2. Images larger than 5MB
      final shouldConfirm = !_isImageFile(fileName) || fileSize > 5 * 1024 * 1024;
      
      if (shouldConfirm) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Text(_getFileIcon(fileName), style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                const Text(
                  'Send File?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: feastLightGreen.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(fileSize),
                        style: const TextStyle(color: feastGray, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This file will be shared with everyone in this group.',
                  style: TextStyle(fontSize: 12, color: feastGray),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 14)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Send', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
      
      await _sendMessage(attachmentFile: file);
    }
  }

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => Container(
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
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: _memberNames.entries.map((entry) {
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
                ),
              ),
            ],
          ),
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
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: feastGreen));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data?.docs ?? [];
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
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
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

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMine, String senderName, String? senderAvatar) {
    final text = msg['text'] as String? ?? '';
    final attachmentUrl = msg['attachmentUrl'] as String? ?? '';
    final attachmentName = msg['attachmentName'] as String? ?? '';
    final hasAttachment = attachmentUrl.isNotEmpty;
    final timestamp = (msg['sentAt'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('h:mm a').format(timestamp) : '';
    final isImage = _isImageFile(attachmentName);
    final fileName = attachmentName.isNotEmpty ? attachmentName : _getFileName(attachmentUrl);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMine ? feastGreen : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMine ? 12 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (hasAttachment)
                    GestureDetector(
                      onTap: () {
                        if (isImage) {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.black87,
                              child: InteractiveViewer(
                                child: Image.network(
                                  attachmentUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(color: Colors.white),
                                    );
                                  },
                                  errorBuilder: (context, error, stack) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, size: 50, color: Colors.white54),
                                          SizedBox(height: 8),
                                          Text('Failed to load image', style: TextStyle(color: Colors.white54)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Beautiful download confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              title: Row(
                                children: [
                                  Text(_getFileIcon(fileName), style: const TextStyle(fontSize: 32)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Download File',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: feastLightGreen.withAlpha(30),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tap Download to save this file to your device.',
                                          style: TextStyle(fontSize: 12, color: feastGray),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontSize: 14)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _downloadFile(attachmentUrl, fileName);
                                  },
                                  icon: const Icon(Icons.download, size: 18),
                                  label: const Text('Download'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: feastGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: isImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                attachmentUrl,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 150,
                                    width: 150,
                                    color: feastLightGreen.withAlpha(50),
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stack) {
                                  return Container(
                                    height: 150,
                                    width: 150,
                                    color: feastLightGreen.withAlpha(50),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, size: 40, color: feastGray),
                                        SizedBox(height: 4),
                                        Text('Failed to load', style: TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: feastLightGreen.withAlpha(80),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getFileIcon(fileName),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileName.length > 30 ? '${fileName.substring(0, 30)}...' : fileName,
                                        style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Tap to download',
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 10,
                                          color: feastGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  if (text.isNotEmpty) ...[
                    if (hasAttachment) const SizedBox(height: 8),
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        color: isMine ? Colors.white : feastBlack,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      color: isMine ? Colors.white70 : feastGray,
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: feastLightGreen.withAlpha(120))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: feastGreen, size: 24),
              onPressed: _isSending ? null : _pickAndSendFile,
              tooltip: 'Attach file (PDF, Image, Document, etc.)',
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: feastLightGreen.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                  maxLines: null,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      _sendMessage(text: text);
                    }
                  },
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _messageController,
              builder: (context, value, child) {
                final canSend = value.text.trim().isNotEmpty;
                return IconButton(
                  icon: Icon(
                    Icons.send,
                    color: canSend ? feastGreen : feastGray.withAlpha(100),
                    size: 22,
                  ),
                  onPressed: canSend && !_isSending
                      ? () => _sendMessage(text: _messageController.text.trim())
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
