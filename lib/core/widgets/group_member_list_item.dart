import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// GroupMemberListItem
// ---------------------------------------------------------------------------
// A reusable tile for displaying one participant in a group/event chat.
//
// FIREBASE INTEGRATION:
//   Subcollection : `chats/{chatId}/members`
//   Document fields expected:
//     - uid         : String  (Firebase Auth UID)
//     - displayName : String
//     - avatarUrl   : String? (Storage URL)
//     - role        : String  ('leader' | 'co_leader' | 'member')
//     - isOnline    : bool    (from Realtime Database presence)
//     - isCurrentUser : bool  (compare with FirebaseAuth.instance.currentUser.uid)
//
//   To wire up:
//     1. Create a `GroupMember` model from DocumentSnapshot.
//     2. StreamBuilder on `chats/{chatId}/members`.
//     3. Online status: listen to RTDB path `status/{uid}/online`.
// ---------------------------------------------------------------------------

enum MemberRole { leader, coLeader, member }

class GroupMemberListItem extends StatelessWidget {
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final MemberRole role;
  final bool isOnline;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const GroupMemberListItem({
    super.key,
    this.uid = 'placeholder_uid',
    this.displayName = 'Member Name',
    this.avatarUrl,
    this.role = MemberRole.member,
    this.isOnline = false,
    this.isCurrentUser = false,
    this.onTap,
  });

  String? get _roleLabel {
    if (role == MemberRole.leader) return 'Leader';
    if (role == MemberRole.coLeader) return 'Co-Leader';
    return null;
  }

  Color get _roleBadgeColor {
    if (role == MemberRole.leader) return Colors.green;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // ── Avatar + online dot ────────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  // TODO: replace with CachedNetworkImage
                  child: avatarUrl == null
                      ? const Icon(Icons.person, size: 24)
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // ── Name + "You" tag ───────────────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  Text(displayName,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    const Text('You',
                        style: TextStyle(
                            fontSize: 12, color: Colors.black45)),
                  ],
                ],
              ),
            ),

            // ── Role badge ─────────────────────────────────────────────────
            if (_roleLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _roleBadgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _roleLabel!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GroupMembersListView
// ---------------------------------------------------------------------------
// Shows the full participant list with a header count and action icons.
//
// FIREBASE INTEGRATION:
//   - Stream `chats/{chatId}/members` ordered by role priority.
//   - Remove member: only Leaders/Co-Leaders see the remove sheet.
//     Call `chats/{chatId}/members/{uid}`.delete() then optionally
//     write to `users/{uid}/notifications` about removal.
//   - Add member: open a user-search dialog, then add to subcollection.
// ---------------------------------------------------------------------------

class GroupMembersListView extends StatelessWidget {
  final List<GroupMemberListItem> members;
  final bool isAdminView; // show remove/add controls when true
  final VoidCallback? onRemoveMembersTap;
  final VoidCallback? onAddMemberTap;
  final VoidCallback? onSearchTap;

  const GroupMembersListView({
    super.key,
    required this.members,
    this.isAdminView = false,
    this.onRemoveMembersTap,
    this.onAddMemberTap,
    this.onSearchTap,
  });

  factory GroupMembersListView.placeholder() {
    return GroupMembersListView(
      isAdminView: false,
      members: const [
        GroupMemberListItem(
            uid: '1',
            displayName: 'Adina Santos',
            role: MemberRole.member,
            isCurrentUser: true,
            isOnline: true),
        GroupMemberListItem(
            uid: '2',
            displayName: 'Jose De La Cruz',
            role: MemberRole.leader,
            isOnline: true),
        GroupMemberListItem(
            uid: '3',
            displayName: 'Marvin Reyes',
            role: MemberRole.coLeader,
            isOnline: true),
        GroupMemberListItem(
            uid: '4', displayName: 'Gregory Bautistsa', isOnline: false),
        GroupMemberListItem(
            uid: '5', displayName: 'Samuel Del Rosario', isOnline: true),
        GroupMemberListItem(
            uid: '6', displayName: 'Bambang Gonzales', isOnline: false),
        GroupMemberListItem(
            uid: '7', displayName: 'Sururi Aquino', isOnline: true),
        GroupMemberListItem(
            uid: '8', displayName: 'Michael Ramos', isOnline: false),
        GroupMemberListItem(
            uid: '9', displayName: 'Jackobs Garcia', isOnline: false),
        GroupMemberListItem(
            uid: '10', displayName: 'Anastasia Lopez', isOnline: true),
        GroupMemberListItem(
            uid: '11', displayName: 'Fuelta Fernandez', isOnline: false),
        GroupMemberListItem(
            uid: '12', displayName: 'Kimini Mendoza', isOnline: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header bar ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.people, size: 20),
              const SizedBox(width: 8),
              Text('${members.length} Participants',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              if (isAdminView) ...[
                // Remove member icon (admin only)
                IconButton(
                  onPressed: onRemoveMembersTap,
                  icon: const Icon(Icons.person_remove_outlined),
                  tooltip: 'Remove Member',
                ),
                // Add member icon (admin only)
                IconButton(
                  onPressed: onAddMemberTap,
                  icon: const Icon(Icons.person_add_outlined),
                  tooltip: 'Add Member',
                ),
              ],
              IconButton(
                onPressed: onSearchTap,
                icon: const Icon(Icons.search),
                tooltip: 'Search Members',
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ── Member list ───────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            itemCount: members.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 60),
            itemBuilder: (_, i) => members[i],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// RemoveMemberSheet  (Admin only modal)
// ---------------------------------------------------------------------------
// A bottom-sheet / modal list for removing group members.
//
// FIREBASE INTEGRATION:
//   Show a confirmation dialog, then on confirm:
//     FirebaseFirestore.instance
//       .doc('chats/$chatId/members/$uid').delete();
//   Optionally write a notification to the removed user's inbox.
// ---------------------------------------------------------------------------

class RemoveMemberSheet extends StatelessWidget {
  final List<GroupMemberListItem> removableMembers;
  final void Function(String uid, String name)? onRemove;

  const RemoveMemberSheet({
    super.key,
    required this.removableMembers,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_remove_outlined),
              const SizedBox(width: 8),
              const Text('Remove Group Members',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ],
          ),
          const Text(
            'Remove uncooperative, unfit, and unavailable collaborators from the group.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          ...removableMembers.map(
            (m) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 18,
                backgroundImage: m.avatarUrl != null
                    ? NetworkImage(m.avatarUrl!)
                    : null,
                child: m.avatarUrl == null
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              title: Text(m.displayName,
                  style: const TextStyle(fontSize: 13)),
              trailing: GestureDetector(
                onTap: () => onRemove?.call(m.uid, m.displayName),
                child: const Text('Remove',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}