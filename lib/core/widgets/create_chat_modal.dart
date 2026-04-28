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
  final _nameCtrl = TextEditingController();
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
    _nameCtrl.dispose();
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
      if (_selected.length == 1) {
        _nameCtrl.text = _getDisplayName(_selected.first);
      } else if (_selected.isEmpty) {
        _nameCtrl.clear();
      }
    });
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
    final name = _nameCtrl.text.trim().isEmpty
        ? (isGroup ? 'Group Chat' : _getDisplayName(_selected.first))
        : _nameCtrl.text.trim();

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
        'groupName': name,
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
    final isGroup = _selected.length > 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              const Text(
                'Select People',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: feastBlack,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  hintStyle:
                      const TextStyle(fontFamily: 'Outfit', color: Colors.grey),
                  prefixIcon:
                      const Icon(Icons.search, size: 20, color: Colors.grey),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _filterUsers('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: feastLightGreen.withAlpha(60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: _filterUsers,
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: feastGreen),
                  ),
                )
              else if (_filteredUsers.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 48, color: feastGray),
                        SizedBox(height: 8),
                        Text(
                          'No users found.',
                          style: TextStyle(fontFamily: 'Outfit', color: feastGray),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredUsers.length,
                    itemBuilder: (_, i) {
                      final u = _filteredUsers[i];
                      final uid = u['uid'] as String;
                      final name = _getDisplayName(u);
                      final email = u['email'] as String? ?? '';
                      final avatarUrl = u['profilePictureUrl'] as String?;
                      final isSelected = _selected.any((s) => s['uid'] == uid);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
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
                                      fontSize: 16),
                                )
                              : null,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        subtitle: email.isNotEmpty
                            ? Text(
                                email,
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    color: feastGray),
                              )
                            : null,
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: feastGreen, size: 24)
                            : const Icon(Icons.add_circle_outline, color: feastGray, size: 24),
                        onTap: () => _toggleSelect(u),
                      );
                    },
                  ),
                ),

              if (_selected.isNotEmpty)
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 8),
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
                        ),
                        onDeleted: () => _toggleSelect(u),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: feastLightGreen.withAlpha(80),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
