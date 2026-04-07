import 'package:flutter/material.dart';

/// ChatParticipant
/// Represents a person to be added to the chat.
class ChatParticipant {
  final String name;
  final String? avatarUrl;
  ChatParticipant({required this.name, this.avatarUrl});
}

/// CreateChatModal
/// Lets a user name a new chat and manage its participants.
/// Covers both:
///   - Group chat (multiple participants + custom chat name)
///   - Direct / single chat (single participant, name auto-filled)
///
/// The [chatName] field is editable. When only one participant exists,
/// the field is pre-filled with that participant's name (matching image 15).
///
/// Parameters:
///   [initialChatName]    — Pre-filled chat name. Defaults to "".
///   [initialParticipants]— Starting list of [ChatParticipant].
///   [onAddPerson]        — Callback when "+ Add Person" is tapped.
///   [onCreate]           — Callback with (chatName, participants) when Create is tapped.
///
/// Usage:
/// ```dart
/// // Group chat
/// showDialog(
///   context: context,
///   builder: (_) => CreateChatModal(
///     initialChatName: 'Community Friends',
///     initialParticipants: [
///       ChatParticipant(name: 'Darlene Castillo', avatarUrl: '...'),
///       ChatParticipant(name: 'Billie Francisco',  avatarUrl: '...'),
///       ChatParticipant(name: 'Ahmed Rivera',       avatarUrl: '...'),
///     ],
///     onAddPerson: () { /* open people picker */ },
///     onCreate: (name, participants) { /* create chat in Firebase */ },
///   ),
/// );
///
/// // Direct chat (auto-fills name from participant)
/// showDialog(
///   context: context,
///   builder: (_) => CreateChatModal(
///     initialParticipants: [
///       ChatParticipant(name: 'Darlene Castillo', avatarUrl: '...'),
///     ],
///     onAddPerson: () { /* open people picker */ },
///     onCreate: (name, participants) { /* create DM in Firebase */ },
///   ),
/// );
/// ```
class CreateChatModal extends StatefulWidget {
  final String initialChatName;
  final List<ChatParticipant> initialParticipants;
  final VoidCallback? onAddPerson;
  final void Function(String chatName, List<ChatParticipant> participants)?
      onCreate;

  const CreateChatModal({
    super.key,
    this.initialChatName = '',
    this.initialParticipants = const [],
    this.onAddPerson,
    this.onCreate,
  });

  @override
  State<CreateChatModal> createState() => _CreateChatModalState();
}

class _CreateChatModalState extends State<CreateChatModal> {
  late final TextEditingController _nameCtrl;
  late final List<ChatParticipant> _participants;

  @override
  void initState() {
    super.initState();
    _participants = List.from(widget.initialParticipants);

    // Auto-fill name from single participant (DM behaviour)
    final autoName = widget.initialChatName.isEmpty &&
            widget.initialParticipants.length == 1
        ? widget.initialParticipants.first.name
        : widget.initialChatName;
    _nameCtrl = TextEditingController(text: autoName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            const Text('Create New Chat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            // Chat name + Create button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade700, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.green.shade700, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onPressed: () =>
                      widget.onCreate?.call(_nameCtrl.text, _participants),
                  child: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Participants header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Included People (${_participants.length})',
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54),
                ),
                GestureDetector(
                  onTap: widget.onAddPerson,
                  child: const Text(
                    '+ Add Person',
                    style:
                        TextStyle(fontSize: 13, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Participant list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _participants.length,
                itemBuilder: (_, i) {
                  final p = _participants[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: p.avatarUrl != null
                              ? NetworkImage(p.avatarUrl!)
                              : null,
                          child: p.avatarUrl == null
                              ? Text(p.name[0],
                                  style: const TextStyle(fontSize: 18))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(p.name,
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}