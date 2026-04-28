import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/firestore_paths.dart';

// ─────────────────────────────────────────────────────────────────────────────
// invite_collaborators_modal.dart
//
// FIX (Image 6): SelectedGroupScreen called:
//   InviteCollaboratorsModal(chatId: widget.chatId)
// But widget had no `chatId` parameter → undefined_named_parameter.
//
// SOLUTION: Added `chatId` parameter. When provided, the modal searches
// Firestore users by name and adds selected users to the chat's
// participantIds array directly. `onConfirm(names)` is still supported
// for callers that manage Firebase outside the modal.
// ─────────────────────────────────────────────────────────────────────────────

class InviteCollaboratorsModal extends StatefulWidget {
  /// The Firestore chat document ID. When provided, selected users are
  /// added to the chat automatically on Confirm.
  final String? chatId;

  final String title;
  final String subtitle;

  /// Legacy callback — called with the list of entered names.
  /// If [chatId] is provided, users are added to Firestore and this is
  /// also called afterward.
  final void Function(List<String> names)? onConfirm;
  final VoidCallback? onCancel;

  const InviteCollaboratorsModal({
    super.key,
    this.chatId,
    this.title = 'Invite Collaborators',
    this.subtitle =
        'We encourage you to invite new collaborators to help you out with all charity-related activities.',
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<InviteCollaboratorsModal> createState() =>
      _InviteCollaboratorsModalState();
}

class _InviteCollaboratorsModalState extends State<InviteCollaboratorsModal> {
  // Each row: a TextField controller + optional matched user document
  final List<_InviteRow> _rows = [_InviteRow(), _InviteRow()];

  bool _isSaving = false;

  final _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    for (final r in _rows) r.dispose();
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_InviteRow()));

  // ── Search Firestore for a user by fullName ───────────────────────────────

  Future<void> _searchUser(int index, String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _rows[index].suggestions = []);
      return;
    }
    try {
      final snap = await _db
          .collection(FirestorePaths.users)
          .where('status', isEqualTo: 'active')
          .orderBy('fullName')
          .startAt([q]).endAt(['$q\uf8ff'])
          .limit(5)
          .get();

      if (!mounted) return;
      setState(() {
        _rows[index].suggestions =
            snap.docs.map((d) => {'uid': d.id, ...d.data()}).toList();
      });
    } catch (_) {}
  }

  void _selectSuggestion(int rowIdx, Map<String, dynamic> user) {
    setState(() {
      _rows[rowIdx].selectedUser = user;
      _rows[rowIdx].ctrl.text = user['fullName'] as String? ??
          '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
      _rows[rowIdx].suggestions = [];
    });
  }

  // ── Confirm ───────────────────────────────────────────────────────────────

  Future<void> _confirm() async {
    final names = _rows
        .map((r) => r.ctrl.text.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    final selectedUsers =
        _rows.where((r) => r.selectedUser != null).map((r) => r.selectedUser!).toList();

    if (names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one name.'),
          backgroundColor: feastError,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // If chatId provided, add matched users to chat participantIds
      if (widget.chatId != null && selectedUsers.isNotEmpty) {
        final uids = selectedUsers.map((u) => u['uid'] as String).toList();
        await _db.collection(FirestorePaths.chats).doc(widget.chatId).update({
          'participantIds': FieldValue.arrayUnion(uids),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onConfirm?.call(names);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add collaborators. Please try again.'),
          backgroundColor: feastError,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.person_add_alt_1, size: 22, color: feastGreen),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed:
                      widget.onCancel ?? () => Navigator.of(context).pop(),
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

            const Text(
              'Collaborator Names',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: feastBlack,
              ),
            ),
            const SizedBox(height: 8),

            // ── Search rows ──────────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(_rows.length, (i) {
                    final row = _rows[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: row.ctrl,
                            style: const TextStyle(
                                fontFamily: 'Outfit', fontSize: 13),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search,
                                  size: 20, color: Colors.grey),
                              hintText: 'Collaborator Name',
                              hintStyle: const TextStyle(
                                  fontFamily: 'Outfit', color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: feastGreen, width: 2),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (v) => _searchUser(i, v),
                          ),
                          // Suggestions dropdown
                          if (row.suggestions.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 4),
                                ],
                              ),
                              child: Column(
                                children: row.suggestions.map((u) {
                                  final name = u['fullName'] as String? ??
                                      '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'
                                          .trim();
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.person,
                                        size: 20, color: feastGreen),
                                    title: Text(name,
                                        style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 13)),
                                    onTap: () => _selectSuggestion(i, u),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── Add Another ──────────────────────────────────────────────
            GestureDetector(
              onTap: _addRow,
              child: const Row(
                children: [
                  Icon(Icons.add, size: 18, color: feastGreen),
                  SizedBox(width: 4),
                  Text(
                    'Add Another',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        color: feastGreen,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Confirm ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),

            // ── Cancel ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    widget.onCancel ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal row model ────────────────────────────────────────────────────────

class _InviteRow {
  final ctrl = TextEditingController();
  List<Map<String, dynamic>> suggestions = [];
  Map<String, dynamic>? selectedUser;

  void dispose() => ctrl.dispose();
}
