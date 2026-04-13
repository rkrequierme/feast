// ─────────────────────────────────────────────────────────────────────────────
// attach_files_modal.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:feast/core/core.dart' hide MemberRole;
import 'package:feast/core/widgets/chat_data.dart';

class AttachFilesModal extends StatefulWidget {
  final String chatId;
  final void Function(List<SharedMedia>) onAttached;

  const AttachFilesModal({super.key, required this.chatId, required this.onAttached});

  @override
  State<AttachFilesModal> createState() => _AttachFilesModalState();
}

class _AttachFilesModalState extends State<AttachFilesModal> {
  // Simulated "already uploading" files for demo purposes
  final List<_UploadingFile> _files = [
    _UploadingFile('Food Bank Progress Report.pdf', '200 KB', 1.0, SharedMediaType.document),
    _UploadingFile('Event Recording (Day #1).mp4', '16 MB', 0.4, SharedMediaType.video),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Upload & Attach Files',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: feastBlack)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Text('Upload and attach files to this chat.',
              style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: feastGray)),
          const SizedBox(height: 14),

          // Upload dropzone (simulated)
          GestureDetector(
            onTap: () {
              // Real impl: FilePicker.platform.pickFiles(allowMultiple: true)
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: feastGreen.withAlpha(120), width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: feastLightGreen.withAlpha(60),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 32, color: feastGreen),
                  const SizedBox(height: 6),
                  const Text('Click to upload and attach files',
                      style: TextStyle(fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastGreen)),
                  Text('SVG, PNG, JPG, GIF, PDF, MP4 (max. 50MB)',
                      style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: feastGray.withAlpha(160))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Uploading file rows
          ..._files.map((f) => _buildFileRow(f)),
          const SizedBox(height: 12),

          // Confirm
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: feastBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                final ready = _files
                    .where((f) => f.progress >= 1.0)
                    .map((f) => SharedMedia(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          type: f.type,
                          name: f.name,
                          size: f.size,
                          thumbnailEmoji: f.type == SharedMediaType.video ? '🎬' : '📄',
                        ))
                    .toList();
                widget.onAttached(ready);
                Navigator.pop(context);
              },
              child: const Text('Confirm',
                  style: TextStyle(fontSize: 14, fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE24B4A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(fontSize: 14, fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(_UploadingFile f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: feastLightGreen.withAlpha(60),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: feastGray.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(f.type == SharedMediaType.video ? Icons.video_file_outlined : Icons.insert_drive_file_outlined,
              size: 22, color: feastGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.name, style: const TextStyle(fontSize: 12, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastBlack)),
                Text(f.size, style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: feastGray.withAlpha(160))),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: f.progress,
                    minHeight: 4,
                    backgroundColor: feastGray.withAlpha(40),
                    color: f.progress >= 1.0 ? feastGreen : feastBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${(f.progress * 100).round()}%',
              style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: feastGray.withAlpha(160))),
          const SizedBox(width: 6),
          Icon(
            f.progress >= 1.0 ? Icons.check_circle : Icons.delete_outline,
            size: 18,
            color: f.progress >= 1.0 ? feastGreen : const Color(0xFFE24B4A),
          ),
        ],
      ),
    );
  }
}

class _UploadingFile {
  final String name;
  final String size;
  final double progress;
  final SharedMediaType type;
  _UploadingFile(this.name, this.size, this.progress, this.type);
}

// ─────────────────────────────────────────────────────────────────────────────
// pin_message_modal.dart
// ─────────────────────────────────────────────────────────────────────────────

class PinMessageModal extends StatelessWidget {
  final ChatMessage message;
  final String chatId;
  final VoidCallback onPinned;

  const PinMessageModal({
    super.key,
    required this.message,
    required this.chatId,
    required this.onPinned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pin This Message?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: feastBlack)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: feastLightGreen.withAlpha(80),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message.text,
              style: const TextStyle(fontSize: 13, fontFamily: 'Outfit', color: feastBlack, height: 1.4),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feastGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ChatStore.pinMessage(chatId, message);
                    onPinned();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message pinned.', style: TextStyle(fontFamily: 'Outfit')), duration: Duration(seconds: 2)),
                    );
                  },
                  child: const Text('Pin', style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// pinned_messages_modal.dart
// ─────────────────────────────────────────────────────────────────────────────

class PinnedMessagesModal extends StatefulWidget {
  final ChatItem chat;
  final VoidCallback onChanged;

  const PinnedMessagesModal({super.key, required this.chat, required this.onChanged});

  @override
  State<PinnedMessagesModal> createState() => _PinnedMessagesModalState();
}

class _PinnedMessagesModalState extends State<PinnedMessagesModal> {
  @override
  Widget build(BuildContext context) {
    final pins = widget.chat.pinnedMessages;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin, size: 18, color: feastGreen),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Pinned Messages',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: feastBlack)),
              ),
              IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 10),
          Flexible(
            child: pins.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No pinned messages.', style: TextStyle(fontFamily: 'Outfit', color: feastGray)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: pins.length,
                    itemBuilder: (context, i) {
                      final p = pins[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: feastLightGreen.withAlpha(60),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(p.fromName,
                                    style: const TextStyle(fontSize: 12, fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: feastGreen)),
                                const Spacer(),
                                Text(p.time,
                                    style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: feastGray.withAlpha(160))),
                                if (widget.chat.isAdmin || widget.chat.type == ChatType.personal) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      ChatStore.unpinMessage(widget.chat.id, p.id);
                                      setState(() {});
                                      widget.onChanged();
                                    },
                                    child: const Icon(Icons.push_pin, size: 14, color: Colors.red),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(p.text,
                                style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: feastGray.withAlpha(210), height: 1.4)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// add_member_modal.dart
// ─────────────────────────────────────────────────────────────────────────────

class AddMemberModal extends StatefulWidget {
  final String chatId;
  final VoidCallback onAdded;

  const AddMemberModal({super.key, required this.chatId, required this.onAdded});

  @override
  State<AddMemberModal> createState() => _AddMemberModalState();
}

class _AddMemberModalState extends State<AddMemberModal> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(child: Text('Invite Collaborators',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: feastBlack))),
              IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
            ]),
            const Text('Invite new collaborators to help with charity-related activities.',
                style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: feastGray)),
            const SizedBox(height: 14),
            const Text('Collaborator Names',
                style: TextStyle(fontSize: 12, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastBlack)),
            const SizedBox(height: 8),
            ..._controllers.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: c,
                decoration: InputDecoration(
                  hintText: 'Collaborator Name',
                  hintStyle: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: feastGray.withAlpha(150)),
                  prefixIcon: Icon(Icons.search, size: 18, color: feastGray.withAlpha(150)),
                  filled: true,
                  fillColor: feastLightGreen.withAlpha(60),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
              ),
            )),
            GestureDetector(
              onTap: () => setState(() => _controllers.add(TextEditingController())),
              child: const Row(children: [
                Icon(Icons.add, size: 16, color: feastGreen),
                SizedBox(width: 4),
                Text('Add Another', style: TextStyle(fontSize: 13, fontFamily: 'Outfit', color: feastGreen, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  for (final c in _controllers) {
                    final name = c.text.trim();
                    if (name.isNotEmpty) {
                      ChatStore.addMember(widget.chatId, ChatMember(
                        uid: 'u_${DateTime.now().millisecondsSinceEpoch}',
                        displayName: name,
                      ));
                    }
                  }
                  widget.onAdded();
                  Navigator.pop(context);
                },
                child: const Text('Confirm',
                    style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE24B4A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// remove_member_modal.dart
// ─────────────────────────────────────────────────────────────────────────────

class RemoveMemberModal extends StatefulWidget {
  final ChatItem chat;
  final VoidCallback onChanged;

  const RemoveMemberModal({super.key, required this.chat, required this.onChanged});

  @override
  State<RemoveMemberModal> createState() => _RemoveMemberModalState();
}

class _RemoveMemberModalState extends State<RemoveMemberModal> {
  void _confirmRemove(BuildContext context, ChatMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.bold, color: feastBlack),
            children: [
              const TextSpan(text: 'Remove '),
              TextSpan(text: member.displayName, style: const TextStyle(color: Color(0xFFE24B4A))),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        content: const Text('Are you sure you want to remove this group member?',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 13)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: feastBlack),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(fontFamily: 'Outfit')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE24B4A)),
            onPressed: () {
              ChatStore.removeMember(widget.chat.id, member.uid);
              setState(() {});
              widget.onChanged();
              Navigator.pop(ctx);
            },
            child: const Text('Yes', style: TextStyle(fontFamily: 'Outfit', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final removable = widget.chat.members
        .where((m) => !m.isCurrentUser && m.role != MemberRole.leader)
        .toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.person_remove_outlined, size: 18, color: feastBlack),
            const SizedBox(width: 8),
            const Expanded(child: Text('Remove Group Members',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: feastBlack))),
            IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
          ]),
          const Text('Remove uncooperative, unfit, or unavailable collaborators.',
              style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: feastGray)),
          const SizedBox(height: 12),
          Flexible(
            child: removable.isEmpty
                ? const Center(child: Text('No removable members.', style: TextStyle(fontFamily: 'Outfit', color: feastGray)))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: removable.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: feastGray.withAlpha(30)),
                    itemBuilder: (ctx, i) {
                      final m = removable[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: feastLightGreen.withAlpha(150),
                              child: const Icon(Icons.person, size: 20, color: feastGreen),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(m.displayName,
                                style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w500))),
                            GestureDetector(
                              onTap: () => _confirmRemove(context, m),
                              child: const Text('Remove',
                                  style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE24B4A))),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: feastGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Done', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// new_chat_modal.dart
// ─────────────────────────────────────────────────────────────────────────────

class NewChatModal extends StatefulWidget {
  final VoidCallback onCreated;
  const NewChatModal({super.key, required this.onCreated});

  @override
  State<NewChatModal> createState() => _NewChatModalState();
}

class _NewChatModalState extends State<NewChatModal> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _peopleControllers = [TextEditingController()];
  bool _isGroup = false;

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _peopleControllers) c.dispose();
    super.dispose();
  }

  void _createChat() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final members = <ChatMember>[
      ChatMember(uid: 'me', displayName: 'Juan De La Cruz', isCurrentUser: true, isOnline: true,
          role: _isGroup ? MemberRole.leader : MemberRole.member),
    ];
    for (final c in _peopleControllers) {
      final n = c.text.trim();
      if (n.isNotEmpty) {
        members.add(ChatMember(uid: 'u_${DateTime.now().millisecondsSinceEpoch}', displayName: n));
      }
    }

    final chat = ChatItem(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      type: _isGroup ? ChatType.myGroup : ChatType.personal,
      name: name,
      groupEmoji: _isGroup ? '👥' : '👤',
      lastMessage: 'Say hello!',
      lastMessageTime: 'Just now',
      isAdmin: true,
      description: _isGroup ? 'A new group chat.' : '',
      members: members,
      pinnedMessages: [],
      sharedMedia: [],
      messages: [],
    );

    ChatStore.addChat(chat);
    widget.onCreated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(child: Text('Create New Chat',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: feastBlack))),
              IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 12),

            // Name field + Create button in a row (like wireframe)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: _isGroup ? 'Group Name' : 'Person\'s Name',
                      hintStyle: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: feastGray.withAlpha(150)),
                      filled: true,
                      fillColor: feastLightGreen.withAlpha(60),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feastGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: _createChat,
                  child: const Text('Create',
                      style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Personal / Group toggle
            Row(
              children: [
                _TypeChip(label: 'Personal', selected: !_isGroup, onTap: () => setState(() => _isGroup = false)),
                const SizedBox(width: 8),
                _TypeChip(label: 'Group', selected: _isGroup, onTap: () => setState(() => _isGroup = true)),
                const Spacer(),
                // Note: event chats auto-created with charity events
                Tooltip(
                  message: 'Event chats are created automatically\nwhen you create a charity event.',
                  child: Text('Why no Events?',
                      style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: feastGreen.withAlpha(180))),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // People
            Row(
              children: [
                Text('Included People (${_peopleControllers.where((c) => c.text.isNotEmpty).length})',
                    style: const TextStyle(fontSize: 12, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastBlack)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _peopleControllers.add(TextEditingController())),
                  child: const Text('+ Add Person',
                      style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: feastGreen, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._peopleControllers.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const CircleAvatar(radius: 16, backgroundColor: feastLightGreen,
                      child: Icon(Icons.person, size: 16, color: feastGreen)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: c,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: feastGray.withAlpha(150)),
                        filled: true,
                        fillColor: feastLightGreen.withAlpha(60),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? feastGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? feastGreen : feastGray.withAlpha(80), width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : feastBlack,
              fontFamily: 'Outfit',
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            )),
      ),
    );
  }
}