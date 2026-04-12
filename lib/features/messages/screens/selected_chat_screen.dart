import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SelectedChatScreen extends StatefulWidget {
  const SelectedChatScreen({super.key});

  @override
  State<SelectedChatScreen> createState() => _SelectedChatScreenState();
}

class _SelectedChatScreenState extends State<SelectedChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ─── Placeholder chat data ───
  final Map<String, dynamic> _chatInfo = {
    'name': 'T.S. Cruz Food Bank',
    'onlineCount': 7,
    'totalCount': 12,
    'isGroup': true,
  };

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Jose De La Cruz',
      'role': 'Leader',
      'text':
          'Hello guys, we have discussed about the TS Cruz Food Bank plan and our decision is to go to start today. We will have a very big gathering once this event starts! These are some images about our agenda.',
      'time': '12:30 PM',
      'isMe': false,
      'hasImages': true,
    },
    {
      'sender': 'You',
      'role': null,
      'text':
          "That's very nice deed! You guys made a very good decision. Can't wait to go help out!",
      'time': '1:00 PM',
      'isMe': true,
      'hasImages': false,
    },
  ];

  // Typing indicators
  final List<String> _typingUsers = ['+2 others'];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeastBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ─── Custom App Bar ───
              _buildChatAppBar(),

              // ─── Messages List ───
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(_messages[index]),
                ),
              ),

              // ─── Typing Indicator ───
              if (_typingUsers.isNotEmpty) _buildTypingIndicator(),

              // ─── Message Input ───
              _buildMessageInput(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FeastBottomNav(currentIndex: 3),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── CUSTOM APP BAR ───
  // ═══════════════════════════════════════════════════
  Widget _buildChatAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: feastLightGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: feastBlack),
            onPressed: () => Navigator.pop(context),
          ),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(
              _chatInfo['isGroup'] == true ? Icons.group : Icons.person,
              size: 22,
              color: feastGreen,
            ),
          ),
          const SizedBox(width: 10),

          // Name + Online status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chatInfo['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    color: feastBlack,
                  ),
                ),
                if (_chatInfo['isGroup'] == true)
                  Text(
                    '${_chatInfo['onlineCount']} / ${_chatInfo['totalCount']} Online',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                      color: feastGray.withAlpha(180),
                    ),
                  ),
              ],
            ),
          ),

          // More options
          IconButton(
            icon: const Icon(Icons.more_vert, color: feastBlack),
            onPressed: () {
              // Show group info / navigate to group detail
              Navigator.pushNamed(context, AppRoutes.groupDetail);
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── MESSAGE BUBBLE ───
  // ═══════════════════════════════════════════════════
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isMe = message['isMe'] as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender name & role (for group chats)
          if (!isMe && _chatInfo['isGroup'] == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message['sender'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      color: feastBlack,
                    ),
                  ),
                  if (message['role'] != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      message['role'] as String,
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

          // Message bubble
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Sender avatar (left side for others)
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: feastLightGreen.withAlpha(128),
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: feastGreen,
                    ),
                  ),
                ),

              // Bubble content
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.all(14),
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
                        color: Colors.black.withAlpha(10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['text'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Outfit',
                          color: isMe ? Colors.white : feastBlack,
                          height: 1.4,
                        ),
                      ),

                      // Image grid (placeholder)
                      if (message['hasImages'] == true) ...[
                        const SizedBox(height: 10),
                        _buildImageGrid(),
                      ],

                      const SizedBox(height: 6),
                      // Timestamp
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          message['time'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Outfit',
                            color: isMe
                                ? Colors.white.withAlpha(200)
                                : feastGray.withAlpha(150),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sender avatar (right side for me)
              if (isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: feastLightGreen.withAlpha(128),
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: feastGreen,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── IMAGE GRID (placeholder) ───
  // ═══════════════════════════════════════════════════
  Widget _buildImageGrid() {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          // Large image
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    feastLightGreen.withAlpha(100),
                    feastLighterBlue.withAlpha(100),
                  ],
                ),
              ),
              child: Icon(
                Icons.landscape,
                size: 36,
                color: feastGreen.withAlpha(120),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Small images grid
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          feastLighterBlue.withAlpha(100),
                          feastLightGreen.withAlpha(100),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.temple_buddhist,
                        size: 24,
                        color: feastGreen.withAlpha(120),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          feastLightGreen.withAlpha(100),
                          feastLighterBlue.withAlpha(100),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.park,
                        size: 24,
                        color: feastGreen.withAlpha(120),
                      ),
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

  // ═══════════════════════════════════════════════════
  // ─── TYPING INDICATOR ───
  // ═══════════════════════════════════════════════════
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Stacked avatars
          SizedBox(
            width: 50,
            height: 24,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: feastLightGreen,
                    child: const Icon(Icons.person, size: 14, color: feastGreen),
                  ),
                ),
                Positioned(
                  left: 14,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: feastLighterBlue,
                    child: const Icon(Icons.person, size: 14, color: feastBlue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '+2 others are typing',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w500,
              color: feastGray.withAlpha(150),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── MESSAGE INPUT ───
  // ═══════════════════════════════════════════════════
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  // Attachment icon
                  GestureDetector(
                    onTap: () {
                      // File attachment
                    },
                    child: Icon(
                      Icons.attach_file,
                      size: 22,
                      color: feastGray.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: () {
              // Send message
              if (_messageController.text.trim().isNotEmpty) {
                // Send action
                _messageController.clear();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: feastGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
