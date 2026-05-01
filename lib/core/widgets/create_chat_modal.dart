import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/firestore_paths.dart';

class CreateChatModal extends StatefulWidget {
  final void Function(String chatId, bool isGroup)? onCreated;

  const CreateChatModal({
    super.key,
    this.onCreated,
  });

  @override
  State<CreateChatModal> createState() => _CreateChatModalState();
}

class _CreateChatModalState extends State<CreateChatModal> {
  final _groupNameCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final List<Map<String, dynamic>> _selected = [];

  bool _isLoading = true;
  bool _isCreating = false;

  final _db = FirebaseFirestore.instance;
  final _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  @override
  void dispose() {
    _groupNameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);
    try {
      final snap = await _db
          .collection(FirestorePaths.users)
          .where('status', isEqualTo: 'active')
          .get();

      if (!mounted) return;
      
      _allUsers = snap.docs
          .where((d) => d.id != _myUid)
          .map((d) => {'uid': d.id, ...d.data()})
          .toList();
      
      _filteredUsers = List.from(_allUsers);
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getDisplayName(Map<String, dynamic> user) {
    final displayName = user['displayName'] as String?;
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final firstName = user['firstName'] as String? ?? '';
    final lastName = user['lastName'] as String? ?? '';
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    final email = user['email'] as String? ?? '';
    return email.isNotEmpty ? email.split('@').first : 'Unknown User';
  }

  void _filterUsers(String query) {
    final q = query.trim().toLowerCase();
    
    if (q.isEmpty) {
      setState(() {
        _filteredUsers = List.from(_allUsers);
      });
      return;
    }

    final filtered = _allUsers.where((user) {
      final firstName = (user['firstName'] as String? ?? '').toLowerCase();
      final lastName = (user['lastName'] as String? ?? '').toLowerCase();
      final fullName = '$firstName $lastName'.trim();
      final email = (user['email'] as String? ?? '').toLowerCase();
      final displayName = (user['displayName'] as String? ?? '').toLowerCase();
      
      return firstName.contains(q) ||
             lastName.contains(q) ||
             fullName.contains(q) ||
             email.contains(q) ||
             displayName.contains(q);
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  void _toggleSelect(Map<String, dynamic> user) {
    final uid = user['uid'] as String;
    setState(() {
      if (_selected.any((u) => u['uid'] == uid)) {
        _selected.removeWhere((u) => u['uid'] == uid);
      } else {
        _selected.add(user);
      }
    });
  }

  bool get _isGroup => _selected.length > 1;
  
  String get _selectedNames {
    if (_selected.isEmpty) return '';
    if (_selected.length == 1) return _getDisplayName(_selected.first);
    return '${_selected.length} people selected';
  }

  Future<void> _create() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one person to chat with.'),
          backgroundColor: feastError,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    final participantIds = _selected.map((u) => u['uid'] as String).toList();
    final isGroup = _selected.length > 1;
    
    // For DM: use the other person's name as the chat name
    // For Group: use custom name or default "Group Chat"
    String chatName;
    if (!isGroup) {
      chatName = _getDisplayName(_selected.first);
    } else {
      chatName = _groupNameCtrl.text.trim().isEmpty
          ? 'Group Chat'
          : _groupNameCtrl.text.trim();
    }

    try {
      final allParticipants = [_myUid, ...participantIds];

      // Check if a DM already exists between these two users
      if (!isGroup && participantIds.length == 1) {
        final existingChat = await _checkExistingDM(participantIds.first);
        if (existingChat != null) {
          if (!mounted) return;
          Navigator.of(context).pop();
          widget.onCreated?.call(existingChat, false);
          return;
        }
      }

      // Create the chat document
      final chatRef = _db.collection(FirestorePaths.chats).doc();
      final chatId = chatRef.id;

      await chatRef.set({
        'id': chatId,
        'participantIds': allParticipants,
        'isGroup': isGroup,
        'isEventChat': false,
        'groupName': chatName,
        'groupImageUrl': '',
        'description': '',
        'creatorId': _myUid,
        'adminIds': [_myUid],
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add chat reference to each participant's userChats sub-collection
      for (final uid in allParticipants) {
        await _db
            .collection(FirestorePaths.users)
            .doc(uid)
            .collection('chats')
            .doc(chatId)
            .set({
              'chatId': chatId,
              'unreadCount': 0,
              'lastActivity': FieldValue.serverTimestamp(),
            });
      }

      debugPrint('✅ Chat created successfully: $chatId');

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onCreated?.call(chatId, isGroup);
    } catch (e) {
      debugPrint('❌ Create chat error: $e');
      if (!mounted) return;
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create chat: $e'),
          backgroundColor: feastError,
        ),
      );
    }
  }

  Future<String?> _checkExistingDM(String otherUid) async {
    try {
      final snapshot = await _db
          .collection(FirestorePaths.chats)
          .where('participantIds', arrayContains: _myUid)
          .where('isGroup', isEqualTo: false)
          .get();
      
      for (final doc in snapshot.docs) {
        final participants = List<String>.from(doc['participantIds'] as List? ?? []);
        if (participants.contains(otherUid)) {
          return doc.id;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Check existing DM error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = _isGroup;
    final canCreate = _selected.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ──────────────────────────────────────────────────────────────
            // HEADER
            // ──────────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Chat',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: feastBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selected.isEmpty
                              ? 'Select people to start chatting'
                              : _selectedNames,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: feastGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22, color: feastGray),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ──────────────────────────────────────────────────────────────
            // BODY
            // ──────────────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Optional Group Name Field (only shown for groups)
                    if (isGroup) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: feastLightGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: feastLightGreen, width: 1),
                        ),
                        child: TextField(
                          controller: _groupNameCtrl,
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Group Name (Optional)',
                            hintStyle: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              color: feastGray,
                            ),
                            prefixIcon: const Icon(Icons.group, size: 20, color: feastGreen),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Selected Members Chip Row (compact, horizontal scroll)
                    if (_selected.isNotEmpty) ...[
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selected.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final u = _selected[i];
                            final name = _getDisplayName(u);
                            return Chip(
                              label: Text(
                                name,
                                style: const TextStyle(fontFamily: 'Outfit', fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              onDeleted: () => _toggleSelect(u),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              backgroundColor: feastLightGreen.withAlpha(80),
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Search Label
                    Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: feastGray),
                        const SizedBox(width: 8),
                        Text(
                          isGroup ? 'Add More Members' : 'Select a Person',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: feastBlack,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_selected.length} selected',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: feastGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Search Field
                    TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: feastGray,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 20, color: feastGray),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: feastGray),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _filterUsers('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: _filterUsers,
                    ),
                    const SizedBox(height: 16),

                    // User List - FULL HEIGHT, NO SHRINKING
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: feastGreen),
                            )
                          : _filteredUsers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.people_outline, size: 48, color: feastGray.withAlpha(100)),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No users found',
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 14,
                                          color: feastGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _filteredUsers.length,
                                  itemBuilder: (_, i) {
                                    final u = _filteredUsers[i];
                                    final uid = u['uid'] as String;
                                    final name = _getDisplayName(u);
                                    final email = u['email'] as String? ?? '';
                                    final avatarUrl = u['profilePictureUrl'] as String?;
                                    final isSelected = _selected.any((s) => s['uid'] == uid);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? feastLightGreen.withAlpha(40) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        leading: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: feastLightGreen,
                                          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                              ? NetworkImage(avatarUrl)
                                              : null,
                                          child: (avatarUrl == null || avatarUrl.isEmpty) && name.isNotEmpty
                                              ? Text(
                                                  name[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    color: feastGreen,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        title: Text(
                                          name,
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: feastBlack,
                                          ),
                                        ),
                                        subtitle: email.isNotEmpty
                                            ? Text(
                                                email,
                                                style: const TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 11,
                                                  color: feastGray,
                                                ),
                                              )
                                            : null,
                                        trailing: isSelected
                                            ? Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: feastGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              )
                                            : Icon(
                                                Icons.add_circle_outline,
                                                color: feastGray.withAlpha(150),
                                                size: 26,
                                              ),
                                        onTap: () => _toggleSelect(u),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),

            // ──────────────────────────────────────────────────────────────
            // FOOTER BUTTONS
            // ──────────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: feastGray,
                        side: BorderSide(color: feastGray.withAlpha(80)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isCreating || !canCreate ? null : _create,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: feastGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isGroup ? 'Create Group' : 'Start Chat',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
}
