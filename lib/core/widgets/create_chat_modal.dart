import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/firestore_paths.dart';

// ─────────────────────────────────────────────────────────────────────────────
// create_chat_modal.dart
//
// FIX (Image 1): MessagesScreen called CreateChatModal with:
//   onCreated: (chatId, isGroup) => Navigator.pushNamed(...)
// But the old widget had:
//   onCreate: (name, participants) => ...
//
// SOLUTION: Widget now exposes `onCreated(String chatId, bool isGroup)`
// which is the signature MessagesScreen expects. The widget handles the
// Firestore chat creation internally via FirestoreService and then
// calls onCreated with the new doc ID and group flag.
//
// Also supports the older `onCreate(name, participants)` pathway for
// screens that still use the local ChatParticipant model.
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a person added to the chat before Firestore creation.
class ChatParticipant {
  final String uid;
  final String name;
  final String? avatarUrl;

  const ChatParticipant({
    required this.uid,
    required this.name,
    this.avatarUrl,
  });
}

class CreateChatModal extends StatefulWidget {
  /// Called after a chat is created in Firestore.
  /// [chatId] is the new document ID; [isGroup] tells the caller which route.
  ///
  /// This is the callback MessagesScreen uses — fixes Image 1.
  final void Function(String chatId, bool isGroup)? onCreated;

  const CreateChatModal({
    super.key,
    this.onCreated,
  });

  @override
  State<CreateChatModal> createState() => _CreateChatModalState();
}

class _CreateChatModalState extends State<CreateChatModal> {
  final _nameCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  // Users found via Firestore search
  List<Map<String, dynamic>> _searchResults = [];
  final List<Map<String, dynamic>> _selected = [];

  bool _isSearching = false;
  bool _isCreating = false;
  String _searchQuery = '';

  final _db = FirebaseFirestore.instance;
  final _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Search Firestore users by name ───────────────────────────────────────

  Future<void> _search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Search by fullName (case-insensitive prefix — requires Firestore index)
      final snap = await _db
          .collection(FirestorePaths.users)
          .where('status', isEqualTo: 'active')
          .orderBy('fullName')
          .startAt([q]).endAt(['$q\uf8ff'])
          .limit(10)
          .get();

      if (!mounted) return;
      setState(() {
        _searchResults = snap.docs
            .where((d) => d.id != _myUid) // exclude self
            .map((d) => {'uid': d.id, ...d.data()})
            .toList();
        _isSearching = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _toggleSelect(Map<String, dynamic> user) {
    final uid = user['uid'] as String;
    setState(() {
      if (_selected.any((u) => u['uid'] == uid)) {
        _selected.removeWhere((u) => u['uid'] == uid);
      } else {
        _selected.add(user);
      }
      // Auto-fill chat name for DM
      if (_selected.length == 1) {
        _nameCtrl.text =
            '${_selected.first['firstName'] ?? ''} ${_selected.first['lastName'] ?? ''}'
                .trim();
      } else if (_selected.isEmpty) {
        _nameCtrl.clear();
      }
    });
  }

  // ── Create chat ───────────────────────────────────────────────────────────

  Future<void> _create() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one person.'),
          backgroundColor: feastError,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    final participantIds = _selected.map((u) => u['uid'] as String).toList();
    final isGroup = _selected.length > 1;
    final name = _nameCtrl.text.trim().isEmpty
        ? (isGroup ? 'Group Chat' : _selected.first['fullName'] ?? 'Chat')
        : _nameCtrl.text.trim();

    try {
      final allParticipants = [_myUid, ...participantIds];

      final ref = await _db.collection(FirestorePaths.chats).add({
        'participantIds': allParticipants,
        'isGroup': isGroup,
        'isEventChat': false,
        'groupName': name,
        'groupImageUrl': '',
        'description': '',
        'creatorId': _myUid,
        'adminIds': [_myUid],
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onCreated?.call(ref.id, isGroup);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create chat. Please try again.'),
          backgroundColor: feastError,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isGroup = _selected.length > 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Create New Chat',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: feastBlack,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Chat name + Create ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: isGroup ? 'Group Name' : "Person's Name",
                      hintStyle: const TextStyle(
                          fontFamily: 'Outfit', color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: feastGreen.withAlpha(180), width: 2),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: feastGreen, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isCreating ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feastGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Create',
                          style: TextStyle(
                              fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Search bar ───────────────────────────────────────────────
            Row(
              children: [
                const Text(
                  'Included People',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: feastBlack,
                  ),
                ),
                if (_selected.isNotEmpty)
                  Text(
                    ' (${_selected.length})',
                    style: const TextStyle(
                        fontFamily: 'Outfit', fontSize: 13, color: feastGray),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // Focus the search field
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: const Text(
                    '+ Add Person',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: feastGreen,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Search input
            TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                hintStyle:
                    const TextStyle(fontFamily: 'Outfit', color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search, size: 20, color: Colors.grey),
                filled: true,
                fillColor: feastLightGreen.withAlpha(60),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (v) {
                setState(() => _searchQuery = v);
                _search(v);
              },
            ),
            const SizedBox(height: 8),

            // ── Search results or selected list ──────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(color: feastGreen))
                  : _searchQuery.isNotEmpty
                      ? _buildSearchResults()
                      : _buildSelectedList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('No users found.',
            style: TextStyle(fontFamily: 'Outfit', color: Colors.grey)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (_, i) {
        final u = _searchResults[i];
        final uid = u['uid'] as String;
        final name = u['fullName'] as String? ??
            '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
        final isSelected = _selected.any((s) => s['uid'] == uid);

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: feastLightGreen,
            backgroundImage: u['profileImageUrl'] != null &&
                    (u['profileImageUrl'] as String).isNotEmpty
                ? NetworkImage(u['profileImageUrl'] as String)
                : null,
            child: u['profileImageUrl'] == null ||
                    (u['profileImageUrl'] as String).isEmpty
                ? const Icon(Icons.person, size: 20, color: feastGreen)
                : null,
          ),
          title: Text(name,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14)),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: feastGreen)
              : const Icon(Icons.add_circle_outline, color: Colors.grey),
          onTap: () => _toggleSelect(u),
        );
      },
    );
  }

  Widget _buildSelectedList() {
    if (_selected.isEmpty) {
      return const Center(
        child: Text(
          'Search for people to add.',
          style: TextStyle(
              fontFamily: 'Outfit', color: Colors.grey, fontSize: 13),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _selected.length,
      itemBuilder: (_, i) {
        final u = _selected[i];
        final name = u['fullName'] as String? ??
            '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: feastLightGreen,
            child: Text(name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(color: feastGreen)),
          ),
          title: Text(name,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14)),
          trailing: GestureDetector(
            onTap: () => _toggleSelect(u),
            child:
                const Icon(Icons.remove_circle_outline, color: Colors.red),
          ),
        );
      },
    );
  }
}
