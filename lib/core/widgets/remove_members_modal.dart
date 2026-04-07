import 'package:flutter/material.dart';

/// GroupMember
/// Represents a group member shown in the remove list.
class GroupMember {
  final String id;
  final String name;
  final String? avatarUrl;
  GroupMember({required this.id, required this.name, this.avatarUrl});
}

/// RemoveMembersModal
/// Displays a scrollable list of group members, each with a red "Remove" button.
/// Tapping Remove shows the [ConfirmationModal] (or you can wire [onRemoveTap]
/// to show your own confirmation dialog before committing).
///
/// Parameters:
///   [title]       — Dialog title. Defaults to "Remove Group Members".
///   [subtitle]    — Subtitle text.
///   [members]     — List of [GroupMember] to display.
///   [onRemoveTap] — Callback with the [GroupMember] when Remove is tapped.
///                   Wire this to show a ConfirmationModal before deleting.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => RemoveMembersModal(
///     members: groupMembers, // from Firebase
///     onRemoveTap: (member) {
///       showDialog(
///         context: context,
///         builder: (_) => ConfirmationModal(
///           titlePrefix: 'Remove',
///           title: member.name,
///           body: 'Are you sure you want to remove this group member?',
///           onYes: () { /* remove from Firebase */ },
///         ),
///       );
///     },
///   ),
/// );
/// ```
class RemoveMembersModal extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<GroupMember> members;
  final void Function(GroupMember member)? onRemoveTap;

  const RemoveMembersModal({
    super.key,
    this.title = 'Remove Group Members',
    this.subtitle =
        'Remove uncooperative, unfit, and unavailable collaborators from the group.',
    this.members = const [],
    this.onRemoveTap,
  });

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
            // Icon + close
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_remove_alt_1, size: 22),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 14),

            // Members list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: members.isEmpty
                  ? const Center(
                      child: Text('No members to display.',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
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
                                backgroundImage: m.avatarUrl != null
                                    ? NetworkImage(m.avatarUrl!)
                                    : null,
                                child: m.avatarUrl == null
                                    ? Text(m.name[0],
                                        style:
                                            const TextStyle(fontSize: 18))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(m.name,
                                    style: const TextStyle(fontSize: 15)),
                              ),
                              GestureDetector(
                                onTap: () => onRemoveTap?.call(m),
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}