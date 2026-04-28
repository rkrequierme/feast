import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/firestore_paths.dart';
import 'group_member_list_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// remove_members_modal.dart
//
// FIX (Image 7): SelectedGroupScreen called:
//   RemoveMembersModal(
//     chatId: widget.chatId,
//     participantIds: participants,  // List<String> of UIDs
//   )
// But the old widget expected `members: List<GroupMember>` with no chatId.
//
// SOLUTION: Widget now accepts `chatId` + `participantIds` (List<String>).
// It loads each user's profile from Firestore and performs the actual
// removal from the chat's participantIds array.
//
// The old `members: List<GroupMember>` constructor is kept as a named
// alternative for callers that already have the model list.
// ─────────────────────────────────────────────────────────────────────────────

class RemoveMembersModal extends StatefulWidget {
  // ── New params (fixes Image 7) ────────────────────────────────────────────
  final String? chatId;
  final List<String>? participantIds;

  // ── Legacy params (kept for compatibility) ────────────────────────────────
  final String title;
  final String subtitle;
  final List<GroupMember>? members;
  final void Function(GroupMember member)? onRemoveTap;

  const RemoveMembersModal({
    super.key,
    // New
    this.chatId,
    this.participantIds,
    // Legacy
    this.title = 'Remove Group Members',
    this.subtitle =
        'Remove uncooperative, unfit, and unavailable collaborators from the group.',
    this.members,
    this.onRemoveTap,
  });

  @override
  State<RemoveMembersModal> createState() => _RemoveMembersModalState();
}

class _RemoveMembersModalState extends State<RemoveMembersModal> {
  final _db = FirebaseFirestore.instance;
  final _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Loaded from Firestore when participantIds is provided
  List<Map<String, dynamic>> _loadedMembers = [];
  bool _isLoading = false;

  // UIDs currently being removed (show spinner per row)
  final Set<String> _removing = {};

  @override
  void initState() {
    super.initState();
    if (widget.participantIds != null) _loadMembers();
  }

  // ── Load user profiles from Firestore ─────────────────────────────────────

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final uids = widget.participantIds!
          .where((uid) => uid != _myUid) // can't remove yourself
          .toList();

      final futures = uids.map(
        (uid) => _db.collection(FirestorePaths.users).doc(uid).get(),
      );
      final snaps = await Future.wait(futures);

      if (!mounted) return;
      setState(() {
        _loadedMembers = snaps
            .where((s) => s.exists)
            .map((s) => {'uid': s.id, ...s.data()!})
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Remove a user from the chat ───────────────────────────────────────────

  Future<void> _removeMember(String uid, String name) async {
    if (widget.chatId == null) return;

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmRemoveDialog(
        memberName: name,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
    if (confirmed != true) return;

    setState(() => _removing.add(uid));

    try {
      await _db.collection(FirestorePaths.chats).doc(widget.chatId).update({
        'participantIds': FieldValue.arrayRemove([uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _removing.remove(uid);
        _loadedMembers.removeWhere((m) => m['uid'] == uid);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name has been removed from the group.'),
          backgroundColor: feastSuccess,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _removing.remove(uid));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove member. Please try again.'),
          backgroundColor: feastError,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Determine which list to show
    final useFirestore =
        widget.participantIds != null && widget.chatId != null;

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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_remove_alt_1,
                      size: 22, color: feastError),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: feastBlack,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              style: const TextStyle(
                  fontFamily: 'Outfit', fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 14),

            // ── Member list ──────────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: feastGreen))
                  : useFirestore
                      ? _buildFirestoreList()
                      : _buildLegacyList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirestoreList() {
    if (_loadedMembers.isEmpty) {
      return const Center(
        child: Text(
          'No members to remove.',
          style: TextStyle(fontFamily: 'Outfit', color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _loadedMembers.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.shade200, height: 1),
      itemBuilder: (ctx, i) {
        final m = _loadedMembers[i];
        final uid = m['uid'] as String;
        final name = m['fullName'] as String? ??
            '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim();
        final avatarUrl = m['profileImageUrl'] as String?;
        final isRemoving = _removing.contains(uid);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: feastLightGreen.withAlpha(120),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: feastGreen, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontFamily: 'Outfit', fontSize: 14, color: feastBlack),
                ),
              ),
              isRemoving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: feastError),
                    )
                  : GestureDetector(
                      onTap: () => _removeMember(uid, name),
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegacyList() {
    final members = widget.members ?? [];
    if (members.isEmpty) {
      return const Center(
        child: Text('No members to display.',
            style: TextStyle(fontFamily: 'Outfit', color: Colors.grey)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: members.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.shade200, height: 1),
      itemBuilder: (_, i) {
        final m = members[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: feastLightGreen.withAlpha(120),
                backgroundImage: m.avatarUrl != null
                    ? NetworkImage(m.avatarUrl!)
                    : null,
                child: m.avatarUrl == null
                    ? Text(
                        m.name.isNotEmpty ? m.name[0] : '?',
                        style: const TextStyle(color: feastGreen),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  m.name,
                  style: const TextStyle(
                      fontFamily: 'Outfit', fontSize: 14, color: feastBlack),
                ),
              ),
              GestureDetector(
                onTap: () => widget.onRemoveTap?.call(m),
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── GroupMember model (kept for legacy callers) ───────────────────────────────

class GroupMember {
  final String id;
  final String name;
  final String? avatarUrl;
  const GroupMember({required this.id, required this.name, this.avatarUrl});
}

// ── Confirm remove dialog ─────────────────────────────────────────────────────

class _ConfirmRemoveDialog extends StatelessWidget {
  final String memberName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmRemoveDialog({
    required this.memberName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: feastBlack),
                children: [
                  const TextSpan(text: 'Remove '),
                  TextSpan(
                    text: memberName,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Are you sure you want to remove this group member?',
              style: TextStyle(
                  fontFamily: 'Outfit', fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: feastBlack,
                  ),
                  child: const Text('No',
                      style: TextStyle(fontFamily: 'Outfit')),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Yes',
                      style: TextStyle(fontFamily: 'Outfit')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
