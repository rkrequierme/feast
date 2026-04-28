// lib/features/messages/screens/selected_group_screen.dart
//
// Group chat detail screen with member management.
// Shows group info, media tabs, and member list.
// Admins (creator + adminIds) can edit group, add/remove members.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Collection: chats
// Fields: groupName, description, groupImageUrl,
//         participantIds[], creatorId, adminIds[]
// React role determination:
//   const isLeader = data.creatorId === uid;
//   const isCoLeader = data.adminIds.includes(uid) && !isLeader;
//   const role = isLeader ? 'leader' : isCoLeader ? 'co_leader' : 'member';
// Security: Admins have NO read access to messages subcollection.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:feast/core/core.dart';

class SelectedGroupScreen extends StatefulWidget {
  final String chatId;
  const SelectedGroupScreen({super.key, required this.chatId});

  @override
  State<SelectedGroupScreen> createState() => _SelectedGroupScreenState();
}

class _SelectedGroupScreenState extends State<SelectedGroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _chatData;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _tabController = TabController(length: 4, vsync: this);
    _loadChat();
  }

  Future<void> _loadUsername() async {
    final name = await FirestoreService.instance.getCurrentUserName();
    if (mounted) setState(() => _username = name);
  }

  Future<void> _loadChat() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirestorePaths.chats)
        .doc(widget.chatId)
        .get();
    if (mounted) setState(() => _chatData = snap.data());
  }

  bool get _isAdmin => (_chatData?['adminIds'] as List?)?.contains(_uid) ?? false;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chatData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: feastGreen)),
      );
    }

    final groupName = _chatData?['groupName'] as String? ?? 'Group';
    final description = _chatData?['description'] as String? ?? '';
    final participants = (_chatData?['participantIds'] as List?)?.cast<String>() ?? [];
    final groupImageUrl = _chatData?['groupImageUrl'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: feastGreen,
        foregroundColor: Colors.white,
        title: Text(
          groupName,
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => EditGroupModal(
                  chatId: widget.chatId,
                  currentName: groupName,
                  currentDescription: description,
                  onSaved: _loadChat,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Group Header
          Container(
            padding: const EdgeInsets.all(16),
            color: feastNavBarBackground,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: feastLightGreen,
                  backgroundImage: groupImageUrl.isNotEmpty ? NetworkImage(groupImageUrl) : null,
                  child: groupImageUrl.isEmpty
                      ? const Icon(Icons.group, size: 40, color: feastGreen)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  groupName,
                  style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: feastGray),
                    ),
                  ),
                const SizedBox(height: 8),
                // Notification toggle placeholder
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_outlined, color: feastGreen, size: 20),
                    const SizedBox(width: 8),
                    const Text('Notifications', style: TextStyle(fontFamily: 'Outfit', color: feastGray)),
                    Switch(
                      value: true,
                      activeColor: feastGreen,
                      onChanged: (_) => showDialog(
                        context: context,
                        builder: (_) => DisableNotificationDialog(onConfirm: () {}),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Media Tabs
          TabBar(
            controller: _tabController,
            labelColor: feastGreen,
            unselectedLabelColor: feastGray,
            indicatorColor: feastGreen,
            tabs: const [
              Tab(text: 'Pinned'),
              Tab(text: 'Images'),
              Tab(text: 'Videos'),
              Tab(text: 'Documents'),
            ],
          ),

          // Participant Count + Admin Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.people_outline, size: 18, color: feastGray),
                const SizedBox(width: 6),
                Text(
                  '${participants.length} Participants',
                  style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isAdmin) ...[
                  IconButton(
                    icon: const Icon(Icons.person_add_alt, color: feastGreen),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => InviteCollaboratorsModal(chatId: widget.chatId),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_remove, color: feastError),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => RemoveMembersModal(
                        chatId: widget.chatId,
                        participantIds: participants,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Member List
          Expanded(
            child: ListView.builder(
              itemCount: participants.length,
              itemBuilder: (context, i) {
                final memberUid = participants[i];
                final isLeader = _chatData?['creatorId'] == memberUid;
                final isCoLeader = (_chatData?['adminIds'] as List?)?.contains(memberUid) ?? false;

                final MemberRole memberRole = isLeader
                    ? MemberRole.leader
                    : (isCoLeader && !isLeader) ? MemberRole.coLeader : MemberRole.member;

                return GroupMemberListItem(
                  uid: memberUid,
                  role: memberRole,
                  isCurrentUser: memberUid == _uid,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
