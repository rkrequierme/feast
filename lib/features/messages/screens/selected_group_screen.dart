// lib/features/messages/screens/selected_group_screen.dart
//
// Group Info & Management Screen
// Displays group details, member list, and admin controls.
// Admins can edit group details, invite members, and remove members.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feast/core/core.dart';

class SelectedGroupScreen extends StatefulWidget {
  final String chatId;
  const SelectedGroupScreen({super.key, required this.chatId});

  @override
  State<SelectedGroupScreen> createState() => _SelectedGroupScreenState();
}

class _SelectedGroupScreenState extends State<SelectedGroupScreen> {
  Map<String, dynamic>? _chatData;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  Map<String, Map<String, dynamic>> _memberDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  Future<void> _loadChatData() async {
    setState(() => _isLoading = true);
    
    final chatSnap = await FirebaseFirestore.instance
        .collection(FirestorePaths.chats)
        .doc(widget.chatId)
        .get();
    
    if (!mounted) return;
    
    final chatData = chatSnap.data();
    setState(() => _chatData = chatData);
    
    if (chatData != null) {
      await _loadMemberDetails(chatData);
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadMemberDetails(Map<String, dynamic> chatData) async {
    final participants = List<String>.from(chatData['participantIds'] as List? ?? []);
    _memberDetails.clear();
    
    for (final uid in participants) {
      final userSnap = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      
      if (userSnap.exists) {
        _memberDetails[uid] = userSnap.data()!;
      }
    }
    if (mounted) setState(() {});
  }

  String _getDisplayName(Map<String, dynamic> userData) {
    final displayName = userData['displayName'] as String?;
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final firstName = userData['firstName'] as String? ?? '';
    final lastName = userData['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'User' : fullName;
  }

  String? _getAvatarUrl(Map<String, dynamic> userData) {
    return userData['profilePictureUrl'] as String?;
  }

  bool get _isAdmin {
    final adminIds = _chatData?['adminIds'] as List? ?? [];
    return adminIds.contains(_uid);
  }

  String? get _creatorId => _chatData?['creatorId'] as String?;
  
  bool _isLeader(String uid) => _creatorId == uid;
  
  bool _isCoLeader(String uid) {
    final adminIds = _chatData?['adminIds'] as List? ?? [];
    return adminIds.contains(uid) && !_isLeader(uid);
  }

  Future<void> _editGroupDetails() async {
    final groupName = _chatData?['groupName'] as String? ?? '';
    final description = _chatData?['description'] as String? ?? '';
    final imageUrl = _chatData?['groupImageUrl'] as String? ?? '';
    
    await showDialog(
      context: context,
      builder: (_) => EditGroupModal(
        chatId: widget.chatId,
        currentName: groupName,
        currentDescription: description,
        initialPhotoUrl: imageUrl,
        onSaved: _loadChatData,
      ),
    );
  }

  Future<void> _inviteMembers() async {
    await showDialog(
      context: context,
      builder: (_) => InviteCollaboratorsModal(
        chatId: widget.chatId,
        title: 'Invite Members',
        subtitle: 'Search and add new members to this group chat.',
        onConfirm: (names) {
          // Members are added by the modal via Firestore
          _loadChatData();
        },
      ),
    );
  }

  Future<void> _removeMember(String uid, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove $name?',
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to remove this member from the group?',
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
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.chats)
          .doc(widget.chatId)
          .update({
            'participantIds': FieldValue.arrayRemove([uid]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection('chats')
          .doc(widget.chatId)
          .delete();
      
      _memberDetails.remove(uid);
      setState(() {});
      
      if (mounted) {
        FeastToast.showSuccess(context, '$name removed from group.');
      }
    } catch (e) {
      if (mounted) {
        FeastToast.showError(context, 'Failed to remove member.');
      }
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Leave Group?',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to leave this group? You will no longer receive messages.',
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
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.chats)
          .doc(widget.chatId)
          .update({
            'participantIds': FieldValue.arrayRemove([_uid]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(_uid)
          .collection('chats')
          .doc(widget.chatId)
          .delete();
      
      if (mounted) {
        Navigator.pop(context); // Go back to messages screen
        FeastToast.showSuccess(context, 'You left the group.');
      }
    } catch (e) {
      if (mounted) {
        FeastToast.showError(context, 'Failed to leave group.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: feastGreen)),
      );
    }
    
    if (_chatData == null) {
      return const Scaffold(
        body: Center(child: Text('Group not found')),
      );
    }

    final groupName = _chatData?['groupName'] as String? ?? 'Group Chat';
    final description = _chatData?['description'] as String? ?? '';
    final groupImageUrl = _chatData?['groupImageUrl'] as String? ?? '';
    final memberCount = _memberDetails.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: feastGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Group Info',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editGroupDetails,
              tooltip: 'Edit Group',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'leave') {
                _leaveGroup();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: feastError, size: 20),
                    SizedBox(width: 8),
                    Text('Leave Group', style: TextStyle(color: feastError)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ──────────────────────────────────────────────────────────────
            // GROUP HEADER SECTION
            // ──────────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: feastNavBarBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: feastLightGreen,
                        backgroundImage: groupImageUrl.isNotEmpty
                            ? NetworkImage(groupImageUrl)
                            : null,
                        child: groupImageUrl.isEmpty
                            ? const Icon(Icons.group, size: 50, color: feastGreen)
                            : null,
                      ),
                      if (_isAdmin)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _editGroupDetails,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: feastGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        color: feastGray,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: feastLightGreen.withAlpha(80),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$memberCount ${memberCount == 1 ? 'Member' : 'Members'}',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: feastGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ──────────────────────────────────────────────────────────────
            // ADMIN ACTIONS SECTION (Only visible to admins)
            // ──────────────────────────────────────────────────────────────
            if (_isAdmin) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        icon: Icons.person_add,
                        label: 'Invite',
                        color: feastGreen,
                        onTap: _inviteMembers,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionCard(
                        icon: Icons.edit_note,
                        label: 'Edit Info',
                        color: feastBlue,
                        onTap: _editGroupDetails,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ──────────────────────────────────────────────────────────────
            // MEMBER LIST SECTION
            // ──────────────────────────────────────────────────────────────
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, size: 20, color: feastGray),
                  const SizedBox(width: 8),
                  Text(
                    'All Members',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (_isAdmin && _memberDetails.length > 1)
                    TextButton.icon(
                      onPressed: () => _showRemoveMembersSheet(),
                      icon: const Icon(Icons.person_remove, size: 18),
                      label: const Text('Remove'),
                      style: TextButton.styleFrom(foregroundColor: feastError),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Member List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _memberDetails.length,
              itemBuilder: (context, i) {
                final entry = _memberDetails.entries.elementAt(i);
                final uid = entry.key;
                final userData = entry.value;
                final name = _getDisplayName(userData);
                final avatarUrl = _getAvatarUrl(userData);
                final isMe = uid == _uid;
                final isLeader = _isLeader(uid);
                final isCoLeader = _isCoLeader(uid);
                final canRemove = _isAdmin && !isLeader && !isMe;
                
                return _memberTile(
                  name: name,
                  avatarUrl: avatarUrl,
                  role: isLeader ? 'Leader' : (isCoLeader ? 'Co-Leader' : null),
                  isMe: isMe,
                  onRemove: canRemove ? () => _removeMember(uid, name) : null,
                );
              },
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.groupChat,
            arguments: widget.chatId,
          );
        },
        backgroundColor: feastGreen,
        icon: const Icon(Icons.chat, color: Colors.white),
        label: const Text('Go to Chat'),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberTile({
    required String name,
    required String? avatarUrl,
    required String? role,
    required bool isMe,
    required VoidCallback? onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: feastLightGreen,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: (avatarUrl == null || avatarUrl.isEmpty) && name.isNotEmpty
                ? Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(color: feastGreen, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: feastLightGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                if (role != null)
                  Text(
                    role,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      color: feastOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: feastError.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_remove_outlined,
                  size: 18,
                  color: feastError,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRemoveMembersSheet() {
    final removableMembers = _memberDetails.entries
        .where((entry) => !_isLeader(entry.key) && entry.key != _uid)
        .map((entry) {
          final userData = entry.value;
          return {
            'uid': entry.key,
            'name': _getDisplayName(userData),
            'avatarUrl': _getAvatarUrl(userData),
          };
        })
        .toList();
    
    if (removableMembers.isEmpty) {
      FeastToast.showInfo(context, 'No members available to remove.');
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: feastGray.withAlpha(80),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.person_remove, color: feastError),
                      SizedBox(width: 8),
                      Text(
                        'Remove Members',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select members to remove from this group',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: feastGray,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: removableMembers.length,
                itemBuilder: (context, i) {
                  final member = removableMembers[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: feastLightGreen,
                      backgroundImage: member['avatarUrl'] != null &&
                              (member['avatarUrl'] as String).isNotEmpty
                          ? NetworkImage(member['avatarUrl'] as String)
                          : null,
                      child: (member['avatarUrl'] == null ||
                              (member['avatarUrl'] as String).isEmpty)
                          ? Text(
                              (member['name'] as String)[0].toUpperCase(),
                              style: const TextStyle(color: feastGreen),
                            )
                          : null,
                    ),
                    title: Text(
                      member['name'] as String,
                      style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeMember(
                          member['uid'] as String,
                          member['name'] as String,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: feastError,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Remove'),
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
