// selected_chat_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';
import 'selected_group_screen.dart';

class SelectedChatScreen extends StatefulWidget {
  final String chatId;
  const SelectedChatScreen({super.key, required this.chatId});

  @override
  State<SelectedChatScreen> createState() => _SelectedChatScreenState();
}

class _SelectedChatScreenState extends State<SelectedChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Simulates other users typing
  bool _othersTyping = false;
  String _typingLabel = '';
  Timer? _typingTimer;
  Timer? _simulatedReplyTimer;

  ChatItem get _chat => ChatStore.findById(widget.chatId)!;
  bool get _isGroup => _chat.type != ChatType.personal;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    _simulatedReplyTimer?.cancel();
    super.dispose();
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

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderUid: 'me',
      senderName: 'Juan De La Cruz',
      text: text,
      time: _currentTime(),
      isMe: true,
    );

    setState(() {
      ChatStore.addMessage(widget.chatId, msg);
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate typing + reply in group chats
    if (_isGroup) {
      _simulatedReplyTimer?.cancel();
      _simulatedReplyTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _othersTyping = true;
          _typingLabel = '+2 others are typing';
        });
        _simulatedReplyTimer = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          final reply = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderUid: 'u_jose',
            senderName: _chat.members.firstWhere(
              (m) => !m.isCurrentUser,
              orElse: () => _chat.members.first,
            ).displayName,
            senderRole: null,
            text: 'Thanks for the update! Let\'s coordinate further on this.',
            time: _currentTime(),
            isMe: false,
          );
          setState(() {
            _othersTyping = false;
            ChatStore.addMessage(widget.chatId, reply);
          });
          _scrollToBottom();
        });
      });
    }
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _showAttachModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AttachFilesModal(
        chatId: widget.chatId,
        onAttached: (media) {
          setState(() {
            _chat.sharedMedia.addAll(media);
          });
        },
      ),
    );
  }

  void _showPinModal(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PinMessageModal(
        message: message,
        chatId: widget.chatId,
        onPinned: () => setState(() {}),
      ),
    );
  }

  void _openChatDetail() {
    if (_isGroup) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectedGroupScreen(chatId: widget.chatId),
        ),
      ).then((_) => setState(() {}));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DmDetailScreen(chatId: widget.chatId),
        ),
      ).then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(chat),
            Expanded(child: _buildMessagesList(chat)),
            if (_othersTyping) _buildTypingIndicator(),
            _buildInputBar(),
          ],
        ),
      ),
      bottomNavigationBar: FeastBottomNav(currentIndex: 3),
    );
  }

  // ─── APP BAR ──────────────────────────────────────
  Widget _buildAppBar(ChatItem chat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: feastLightGreen,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: feastBlack),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Text(chat.groupEmoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _openChatDetail,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                      color: feastBlack,
                    ),
                  ),
                  Text(
                    _isGroup
                        ? '${chat.onlineCount} / ${chat.totalCount} Online'
                        : chat.isOnline
                            ? 'Online'
                            : 'Offline',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Outfit',
                      color: feastGray.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: feastBlack),
            onPressed: _openChatDetail,
          ),
        ],
      ),
    );
  }

  // ─── MESSAGES LIST ────────────────────────────────
  Widget _buildMessagesList(ChatItem chat) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: chat.messages.length,
      itemBuilder: (context, index) {
        final msg = chat.messages[index];
        return GestureDetector(
          onLongPress: () => _showPinModal(msg),
          child: _buildMessageBubble(msg, chat),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, ChatItem chat) {
    final isMe = msg.isMe;
    String? roleLabel;
    if (msg.senderRole == MemberRole.leader) roleLabel = 'Leader';
    if (msg.senderRole == MemberRole.coLeader) roleLabel = 'Co-Leader';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender name (group only, others only)
          if (!isMe && _isGroup)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 36),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.senderName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      color: feastBlack,
                    ),
                  ),
                  if (roleLabel != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      roleLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        color: feastGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left avatar (others)
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: feastLightGreen.withAlpha(150),
                  child: Text(chat.groupEmoji, style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 6),
              ],

              // Bubble
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? feastGreen : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isMe ? 20 : 12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Outfit',
                          color: isMe ? Colors.white : feastBlack,
                          height: 1.4,
                        ),
                      ),
                      if (msg.hasImages) ...[
                        const SizedBox(height: 8),
                        _buildImageGrid(msg.imageEmojis),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Spacer(),
                          Text(
                            msg.time,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Outfit',
                              color: isMe
                                  ? Colors.white.withAlpha(200)
                                  : feastGray.withAlpha(150),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.done_all, size: 13, color: Colors.white.withAlpha(200)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right avatar (me)
              if (isMe) ...[
                const SizedBox(width: 6),
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: feastLightGreen,
                  child: Icon(Icons.person, size: 16, color: feastGreen),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> emojis) {
    if (emojis.isEmpty) {
      emojis = ['🏝️', '🏫', '🌿'];
    }
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: feastLightGreen.withAlpha(120),
              ),
              child: Center(
                child: Text(emojis.isNotEmpty ? emojis[0] : '🖼️',
                    style: const TextStyle(fontSize: 36)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: feastLighterBlue.withAlpha(120),
                    ),
                    child: Center(
                      child: Text(
                          emojis.length > 1 ? emojis[1] : '🏞️',
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: feastLightGreen.withAlpha(100),
                    ),
                    child: Center(
                      child: Text(
                          emojis.length > 2 ? emojis[2] : '🌿',
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TYPING INDICATOR ─────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 22,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: feastLightGreen,
                    child: const Icon(Icons.person, size: 13, color: feastGreen),
                  ),
                ),
                Positioned(
                  left: 13,
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: feastLighterBlue,
                    child: Icon(Icons.person, size: 13, color: feastBlue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _typingLabel,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Outfit',
              color: feastGray.withAlpha(170),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ─── INPUT BAR ────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Outfit',
                        color: feastBlack,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          color: feastGray.withAlpha(130),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  // Attach button
                  GestureDetector(
                    onTap: _showAttachModal,
                    child: Icon(
                      Icons.attach_file,
                      size: 22,
                      color: feastGray.withAlpha(160),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: feastGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}