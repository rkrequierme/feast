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
  bool _isSending = false;
  bool _isDownloading = false;
  
  // Cache for sender names to avoid repeated Firestore calls
  final Map<String, String> _senderNameCache = {};
  final Map<String, String> _senderAvatarCache = {};

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }
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

      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = await getExternalStorageDirectory();
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }
      
      final savePath = '${downloadDir!.path}/$fileName';
      
      final dio = Dio();
      await dio.download(url, savePath);
      
      if (!mounted) return;
      Navigator.pop(context);
      
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
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: feastError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<Map<String, dynamic>> _getUserInfo(String uid) async {
    if (uid == _uid) {
      return {
        'name': 'You',
        'avatarUrl': '',
      };
    }
    
    if (_senderNameCache.containsKey(uid)) {
      return {
        'name': _senderNameCache[uid],
        'avatarUrl': _senderAvatarCache[uid] ?? '',
      };
    }
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final displayName = data['displayName'] as String?;
        String name;
        if (displayName != null && displayName.isNotEmpty) {
          name = displayName;
        } else {
          final firstName = data['firstName'] as String? ?? '';
          final lastName = data['lastName'] as String? ?? '';
          name = '$firstName $lastName'.trim();
          if (name.isEmpty) name = 'User';
        }
        final avatarUrl = data['profilePictureUrl'] as String? ?? '';
        
        _senderNameCache[uid] = name;
        _senderAvatarCache[uid] = avatarUrl;
        
        return {'name': name, 'avatarUrl': avatarUrl};
      }
      return {'name': 'User', 'avatarUrl': ''};
    } catch (e) {
      return {'name': 'User', 'avatarUrl': ''};
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

  Future<void> _deleteMessage(String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Message',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
          style: TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: feastError),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.chats)
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
      
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection(FirestorePaths.chats)
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('sentAt', descending: true)
          .limit(1)
          .get();
      
      if (messagesSnapshot.docs.isNotEmpty) {
        final lastMessage = messagesSnapshot.docs.first.data();
        await FirebaseFirestore.instance
            .collection(FirestorePaths.chats)
            .doc(widget.chatId)
            .update({
          'lastMessage': lastMessage['text'] as String? ?? '[Attachment]',
          'lastMessageAt': lastMessage['sentAt'],
        });
      } else {
        await FirebaseFirestore.instance
            .collection(FirestorePaths.chats)
            .doc(widget.chatId)
            .update({
          'lastMessage': 'No messages yet',
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
      }
      
      if (mounted) {
        FeastToast.showSuccess(context, 'Message deleted');
      }
    } catch (e) {
      if (mounted) {
        FeastToast.showError(context, 'Failed to delete message');
      }
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
                      overflow: TextOverflow.ellipsis,
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
                'This file will be shared with everyone in this conversation.',
                style: TextStyle(fontSize: 12, color: feastGray),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: feastGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Send'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      await _sendMessage(attachmentFile: file);
    }
  }

  void _showGroupInfo() {
    Navigator.pushNamed(
      context,
      AppRoutes.groupDetail,
      arguments: widget.chatId,
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
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FirestorePaths.chats)
              .doc(widget.chatId)
              .snapshots(),
          builder: (context, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Group Chat',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              );
            }
            
            if (chatSnapshot.hasData && chatSnapshot.data!.exists) {
              final chatData = chatSnapshot.data!.data() as Map<String, dynamic>;
              final groupName = chatData['groupName'] as String? ?? 'Group Chat';
              final participantIds = chatData['participantIds'] as List? ?? [];
              final memberCount = participantIds.length;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$memberCount member${memberCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }
            return const Text(
              'Group Chat',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            );
          },
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
                    final doc = messages[index];
                    final msg = doc.data() as Map<String, dynamic>;
                    final isMine = msg['senderId'] == _uid;
                    final senderId = msg['senderId'] as String;
                    final messageId = doc.id;
                    
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getUserInfo(senderId),
                      builder: (context, userInfoSnapshot) {
                        if (!userInfoSnapshot.hasData) {
                          return _buildMessageBubble(msg, isMine, 'Loading...', '', messageId);
                        }
                        final userInfo = userInfoSnapshot.data!;
                        return _buildMessageBubble(
                          msg, 
                          isMine, 
                          userInfo['name'] as String, 
                          userInfo['avatarUrl'] as String,
                          messageId,
                        );
                      },
                    );
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

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMine, String senderName, String avatarUrl, String messageId) {
    final text = msg['text'] as String? ?? '';
    final attachmentUrl = msg['attachmentUrl'] as String? ?? '';
    final attachmentName = msg['attachmentName'] as String? ?? '';
    final hasAttachment = attachmentUrl.isNotEmpty;
    final timestamp = (msg['sentAt'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('h:mm a').format(timestamp) : '';
    final isImage = _isImageFile(attachmentName);
    final fileName = attachmentName.isNotEmpty ? attachmentName : _getFileName(attachmentUrl);

    return GestureDetector(
      onLongPress: () {
        if (isMine) {
          _deleteMessage(messageId);
        }
      },
      child: Align(
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
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: feastLightGreen,
                        backgroundImage: avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: avatarUrl.isEmpty && senderName.isNotEmpty
                            ? Text(
                                senderName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: feastGreen,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        senderName,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: feastGreen,
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
                                  ),
                                ),
                              ),
                            );
                          } else {
                            _downloadFile(attachmentUrl, fileName);
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
