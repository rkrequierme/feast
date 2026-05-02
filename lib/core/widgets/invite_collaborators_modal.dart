import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/firestore_paths.dart';
import '../core.dart';

// ─────────────────────────────────────────────────────────────────────────────
// invite_collaborators_modal.dart
//
// Improved version that works like the Create Chat modal.
// Shows a searchable list of all active users that can be selected and added.
// ─────────────────────────────────────────────────────────────────────────────

class InviteCollaboratorsModal extends StatefulWidget {
  /// The Firestore chat document ID. When provided, selected users are
  /// added to the chat automatically on Confirm.
  final String? chatId;

  final String title;
  final String subtitle;

  /// List of existing member UIDs to exclude from the selection list
  final List<String> existingMemberIds;

  /// Legacy callback — called with the list of entered names.
  /// If [chatId] is provided, users are added to Firestore and this is
  /// also called afterward.
  final void Function(List<String> names)? onConfirm;
  final VoidCallback? onCancel;

  const InviteCollaboratorsModal({
    super.key,
    this.chatId,
    this.title = 'Invite Members',
    this.subtitle = 'Search and add new members to your group chat.',
    this.existingMemberIds = const [],
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<InviteCollaboratorsModal> createState() =>
      _InviteCollaboratorsModalState();
}

class _InviteCollaboratorsModalState extends State<InviteCollaboratorsModal> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _selectedUsers = [];
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  bool _isSaving = false;
  final _scrollController = ScrollController();
  String _searchQuery = '';

  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
      _filterUsers();
    });
  }

  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((user) {
        final firstName = (user['firstName'] as String? ?? '').toLowerCase();
        final lastName = (user['lastName'] as String? ?? '').toLowerCase();
        final fullName = '$firstName $lastName'.trim();
        final email = (user['email'] as String? ?? '').toLowerCase();
        final displayName = (user['displayName'] as String? ?? '').toLowerCase();
        
        return firstName.contains(_searchQuery) ||
               lastName.contains(_searchQuery) ||
               fullName.contains(_searchQuery) ||
               email.contains(_searchQuery) ||
               displayName.contains(_searchQuery);
      }).toList();
    }
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
          .where((d) => !widget.existingMemberIds.contains(d.id))
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

  String _getAvatarUrl(Map<String, dynamic> user) {
    return user['profilePictureUrl'] as String? ?? '';
  }

  bool _isSelected(String uid) {
    return _selectedUsers.any((u) => u['uid'] == uid);
  }

  void _toggleSelect(Map<String, dynamic> user) {
    final uid = user['uid'] as String;
    setState(() {
      if (_isSelected(uid)) {
        _selectedUsers.removeWhere((u) => u['uid'] == uid);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _confirm() async {
    if (_selectedUsers.isEmpty) {
      FeastToast.showError(context, 'Please select at least one member to add.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.chatId != null && _selectedUsers.isNotEmpty) {
        final uids = _selectedUsers.map((u) => u['uid'] as String).toList();
        
        // Add users to chat participantIds
        await _db.collection(FirestorePaths.chats).doc(widget.chatId).update({
          'participantIds': FieldValue.arrayUnion(uids),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Add chat reference to each new participant's userChats sub-collection
        for (final uid in uids) {
          await _db
              .collection(FirestorePaths.users)
              .doc(uid)
              .collection('chats')
              .doc(widget.chatId)
              .set({
                'chatId': widget.chatId,
                'unreadCount': 0,
                'lastActivity': FieldValue.serverTimestamp(),
              });
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onConfirm?.call(_selectedUsers.map((u) => u['uid'] as String).toList());
      
      FeastToast.showSuccess(
        context, 
        '${_selectedUsers.length} member${_selectedUsers.length == 1 ? '' : 's'} added successfully!'
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      FeastToast.showError(context, 'Failed to add members. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _selectedUsers.isNotEmpty && !_isSaving;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [feastGreen, feastDarkGreen],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_add_alt_1, size: 22, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onCancel ?? () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected members summary
                    if (_selectedUsers.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: feastLightGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_add, size: 18, color: feastGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_selectedUsers.length} member${_selectedUsers.length == 1 ? '' : 's'} selected',
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: feastGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Selected members chips
                    if (_selectedUsers.isNotEmpty) ...[
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedUsers.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final user = _selectedUsers[i];
                            final name = _getDisplayName(user);
                            return Chip(
                              label: Text(
                                name,
                                style: const TextStyle(fontFamily: 'Outfit', fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              onDeleted: () => _toggleSelect(user),
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

                    // Search label
                    Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: feastGray),
                        const SizedBox(width: 8),
                        const Text(
                          'Search Users',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: feastBlack,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredUsers.length} users available',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: feastGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Search field
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: feastGray,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 20, color: feastGray),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: feastGray),
                                onPressed: () {
                                  _searchController.clear();
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
                    ),
                    const SizedBox(height: 16),

                    // User list
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
                                        _searchQuery.isNotEmpty
                                            ? 'No users found matching "$_searchQuery"'
                                            : 'No users available to add',
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
                                  controller: _scrollController,
                                  itemCount: _filteredUsers.length,
                                  itemBuilder: (_, i) {
                                    final user = _filteredUsers[i];
                                    final uid = user['uid'] as String;
                                    final name = _getDisplayName(user);
                                    final email = user['email'] as String? ?? '';
                                    final avatarUrl = _getAvatarUrl(user);
                                    final isSelected = _isSelected(uid);

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
                                          backgroundImage: avatarUrl.isNotEmpty
                                              ? NetworkImage(avatarUrl)
                                              : null,
                                          child: avatarUrl.isEmpty && name.isNotEmpty
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
                                        onTap: () => _toggleSelect(user),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer Buttons ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: feastError,
                        side: const BorderSide(color: feastError),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canConfirm ? _confirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canConfirm ? feastGreen : feastGreen.withOpacity(0.5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Add Members',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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
