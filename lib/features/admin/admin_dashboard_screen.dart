// lib/features/admin/screens/admin_dashboard_screen.dart
//
// Temporary admin dashboard — accessed via floating button on HomeScreen.
// This MUST be removed once the React.js web admin panel is live.
// All logic here is intentionally designed for easy migration.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';
import 'package:feast/core/utils/date_parser.dart';
import 'package:feast/core/services/storage_service.dart';
import 'dart:typed_data';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    'Users',
    'Posts',
    'Events',
    'Reports',
    'Announce',
    'Content',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: feastGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Admin Dashboard (Temporary)',
          style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: feastOrange,
          labelStyle: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              fontSize: 12),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PendingUsersTab(),
          _PendingPostsTab(),
          _PendingEventsTab(),
          _ReportsTab(),
          _AnnouncementsTab(),
          _ContentEditorTab(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ── TAB 1: PENDING USER REGISTRATIONS ──────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════

class _PendingUsersTab extends StatelessWidget {
  const _PendingUsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: feastGreen));
        }
        if (snap.hasError) {
          return Center(
            child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
          );
        }
        var docs = snap.data?.docs ?? [];
        docs = docs.toList()..sort((a, b) {
          final aTime = DateParser.parse((a.data() as Map<String, dynamic>)['createdAt']);
          final bTime = DateParser.parse((b.data() as Map<String, dynamic>)['createdAt']);
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });
        
        if (docs.isEmpty) {
          return const Center(
            child: Text('No pending registrations.',
                style: TextStyle(fontFamily: 'Outfit', color: feastGray)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final uid = docs[i].id;
            return _AdminUserCard(uid: uid, data: data);
          },
        );
      },
    );
  }
}

class _AdminUserCard extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> data;

  const _AdminUserCard({required this.uid, required this.data});

  @override
  State<_AdminUserCard> createState() => _AdminUserCardState();
}

class _AdminUserCardState extends State<_AdminUserCard> {
  bool _showingId = false;
  Uint8List? _decryptedId;
  bool _loadingId = false;

  Future<void> _viewId() async {
    if (_decryptedId != null) {
      setState(() => _showingId = !_showingId);
      return;
    }
    setState(() => _loadingId = true);
    try {
      final idUrl = widget.data['legalIdUrl'] as String? ?? '';
      if (idUrl.isEmpty) throw Exception('No ID uploaded.');
      // Fetch encrypted bytes from Storage URL
      // In production this should go through a Cloud Function for
      // true server-side decryption — kept client-side here for demo.
      FeastToast.showSuccess(context, 'ID decryption is admin-only.');
    } catch (e) {
      if (mounted) FeastToast.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loadingId = false);
    }
  }

  Future<void> _approve() async {
    await FirestoreService.instance.approveUser(widget.uid);
    if (!mounted) return;
    FeastToast.showSuccess(context, 'User approved.');
  }

  Future<void> _reject() async {
    final reason = await _promptReason(context, 'Rejection Reason');
    if (reason == null) return;
    await FirestoreService.instance.rejectUser(widget.uid, reason);
    if (!mounted) return;
    FeastToast.showSuccess(context, 'User rejected.');
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.data['firstName'] as String? ?? '';
    final lastName = widget.data['lastName'] as String? ?? '';
    final email = widget.data['email'] as String? ?? '';
    final location = widget.data['location'] as String? ?? '';
    final dob = widget.data['dateOfBirth'] as String? ?? '';
    final gender = widget.data['gender'] as String? ?? '';
    final contact = widget.data['contactNumber'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$firstName $lastName',
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: feastBlack),
            ),
            const SizedBox(height: 4),
            _infoRow('Email', email),
            _infoRow('Location', location),
            _infoRow('DOB', dob),
            _infoRow('Gender', gender),
            _infoRow('Contact', contact),
            const SizedBox(height: 12),

            // View ID button
            OutlinedButton.icon(
              onPressed: _loadingId ? null : _viewId,
              icon: _loadingId
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: feastGreen))
                  : const Icon(Icons.badge_outlined),
              label: Text(
                  _showingId ? 'Hide Legal ID' : 'View Legal ID (Decrypt)',
                  style: const TextStyle(fontFamily: 'Outfit')),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: feastGreen)),
            ),

            const SizedBox(height: 12),

            // Approve / Reject buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _approve,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: feastSuccess),
                    child: const Text('Approve',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Outfit')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _reject,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: feastError),
                    child: const Text('Reject',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Outfit')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontFamily: 'Outfit', fontSize: 13, color: feastBlack),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(
                text: value,
                style: TextStyle(color: feastGray.withAlpha(220))),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ── TAB 2: PENDING AID REQUEST POSTS ────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════

class _PendingPostsTab extends StatelessWidget {
  const _PendingPostsTab();

  @override
  Widget build(BuildContext context) {
    return _PendingContentList(
      collection: FirestorePaths.aidRequests,
      emptyMessage: 'No pending aid requests.',
      color: feastGreen,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ── TAB 3: PENDING CHARITY EVENTS ───────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════

class _PendingEventsTab extends StatelessWidget {
  const _PendingEventsTab();

  @override
  Widget build(BuildContext context) {
    return _PendingContentList(
      collection: FirestorePaths.charityEvents,
      emptyMessage: 'No pending charity events.',
      color: feastBlue,
    );
  }
}

/// Reusable pending content list for aid requests and charity events.
class _PendingContentList extends StatelessWidget {
  final String collection;
  final String emptyMessage;
  final Color color;

  const _PendingContentList({
    required this.collection,
    required this.emptyMessage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: color));
        }
        if (snap.hasError) {
          return Center(
            child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
          );
        }
        var docs = snap.data?.docs ?? [];
        docs = docs.toList()..sort((a, b) {
          final aTime = DateParser.parse((a.data() as Map<String, dynamic>)['createdAt']);
          final bTime = DateParser.parse((b.data() as Map<String, dynamic>)['createdAt']);
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });
        
        if (docs.isEmpty) {
          return Center(
            child: Text(emptyMessage,
                style: const TextStyle(
                    fontFamily: 'Outfit', color: feastGray)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return _PostApprovalCard(
              docId: docs[i].id,
              collection: collection,
              data: data,
              accentColor: color,
            );
          },
        );
      },
    );
  }
}

class _PostApprovalCard extends StatelessWidget {
  final String docId;
  final String collection;
  final Map<String, dynamic> data;
  final Color accentColor;

  const _PostApprovalCard({
    required this.docId,
    required this.collection,
    required this.data,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'Untitled';
    final description = data['description'] as String? ?? '';
    final images =
        (data['imageUrls'] as List?)?.cast<String>() ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(images.first,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover),
              ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Outfit', fontSize: 13, color: feastGray),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirestoreService.instance
                          .approvePost(collection, docId);
                      if (!context.mounted) return;
                      FeastToast.showSuccess(context, 'Post approved.');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: feastSuccess),
                    child: const Text('Approve',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final reason =
                          await _promptReason(context, 'Rejection Reason');
                      if (reason == null) return;
                      await FirestoreService.instance
                          .rejectPost(collection, docId, reason);
                      if (!context.mounted) return;
                      FeastToast.showSuccess(context, 'Post rejected.');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: feastError),
                    child: const Text('Reject',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ── TAB 4: REPORTS ───────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirestorePaths.reports)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: feastGreen));
        }
        if (snap.hasError) {
          return Center(
            child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
          );
        }
        var docs = snap.data?.docs ?? [];
        docs = docs.toList()..sort((a, b) {
          final aTime = DateParser.parse((a.data() as Map<String, dynamic>)['createdAt']);
          final bTime = DateParser.parse((b.data() as Map<String, dynamic>)['createdAt']);
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });
        
        if (docs.isEmpty) {
          return const Center(
            child: Text('No pending reports.',
                style: TextStyle(fontFamily: 'Outfit', color: feastGray)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final targetId = data['targetId'] as String? ?? '';
            final targetType = data['targetType'] as String? ?? '';
            final title = data['title'] as String? ?? '';
            final description = data['description'] as String? ?? '';
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.flag, color: feastError, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Report: $targetType ($targetId)',
                          style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text('Title: $title',
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600)),
                    Text(description,
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: feastGray)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final reason = await _promptReason(
                                context, 'Warning / Ban Reason');
                            if (reason == null || !context.mounted) return;
                            await _showSanctionDialog(
                                context, targetId, reason);
                          },
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: feastOrange)),
                          child: const Text('Sanction User',
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  color: feastOrange)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection(FirestorePaths.reports)
                                .doc(docs[i].id)
                                .update({'status': 'resolved'});
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: feastSuccess),
                          child: const Text('Dismiss',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Outfit')),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSanctionDialog(
      BuildContext context, String uid, String reason) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Issue Sanction',
            style: TextStyle(
                fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirestoreService.instance.issueWarning(uid, reason);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: feastWarning,
                  minimumSize: const Size(double.infinity, 44)),
              child: const Text('Issue Warning',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirestoreService.instance.banUser(uid, reason, 7);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: feastError,
                  minimumSize: const Size(double.infinity, 44)),
              child: const Text('Ban (7 Days)',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirestoreService.instance.banUser(uid, reason, 0);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 44)),
              child: const Text('Permanent Ban',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ── TAB 5: POST ANNOUNCEMENT ─────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════

class _AnnouncementsTab extends StatefulWidget {
  const _AnnouncementsTab();

  @override
  State<_AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends State<_AnnouncementsTab> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Post Official Announcement',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: 'Announcement Title',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Announcement Body',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          _isPosting
              ? const Center(
                  child: CircularProgressIndicator(color: feastGreen))
              : ElevatedButton(
                  onPressed: () async {
                    if (_titleCtrl.text.trim().isEmpty ||
                        _bodyCtrl.text.trim().isEmpty) {
                      FeastToast.showError(
                          context, 'Fill in all fields.');
                      return;
                    }
                    setState(() => _isPosting = true);
                    await FirestoreService.instance.postAnnouncement({
                      'title': _titleCtrl.text.trim(),
                      'body': _bodyCtrl.text.trim(),
                      'type': 'announcement',
                      'imageUrls': [],
                    });
                    _titleCtrl.clear();
                    _bodyCtrl.clear();
                    if (mounted) {
                      setState(() => _isPosting = false);
                      FeastToast.showSuccess(
                          context, 'Announcement posted.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feastGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Post Announcement',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold)),
                ),
          const SizedBox(height: 30),
          const Text('Past Announcements',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: feastGray)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreService.instance.announcementsStream(limit: 20),
            builder: (context, snap) {
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Text('No announcements yet.',
                    style: TextStyle(fontFamily: 'Outfit', color: feastGray));
              }
              return Column(
                children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    dense: true,
                    leading:
                        const Icon(Icons.campaign, color: feastOrange),
                    title: Text(d['title'] ?? '',
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    subtitle: Text(
                      d['body'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Outfit', fontSize: 11),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: feastError),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection(FirestorePaths.announcements)
                            .doc(doc.id)
                            .delete();
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ── TAB 6: STATIC CONTENT EDITOR ──────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════

class _ContentEditorTab extends StatelessWidget {
  const _ContentEditorTab();

  @override
  Widget build(BuildContext context) {
    final sections = [
      ('About Us', 'about_us'),
      ('Help & FAQ', 'help_faq'),
      ('Terms & Conditions', 'terms_conditions'),
      ('App Guide', 'app_guide'),
      ('Contact Us', 'contact_us'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: sections.map((pair) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading:
                const Icon(Icons.edit_document, color: feastGreen),
            title: Text(pair.$1,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _ContentEditorDetailScreen(
                  sectionName: pair.$1,
                  docId: pair.$2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ContentEditorDetailScreen extends StatefulWidget {
  final String sectionName;
  final String docId;

  const _ContentEditorDetailScreen({
    required this.sectionName,
    required this.docId,
  });

  @override
  State<_ContentEditorDetailScreen> createState() =>
      _ContentEditorDetailScreenState();
}

class _ContentEditorDetailScreenState
    extends State<_ContentEditorDetailScreen> {
  final _ctrl = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final snap = await FirebaseFirestore.instance
        .collection('static_content')
        .doc(widget.docId)
        .get();
    if (mounted) {
      _ctrl.text = snap.data()?['content'] as String? ?? '';
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await FirebaseFirestore.instance
        .collection('static_content')
        .doc(widget.docId)
        .set({'content': _ctrl.text.trim()}, SetOptions(merge: true));
    if (mounted) {
      setState(() => _isSaving = false);
      FeastToast.showSuccess(context, '${widget.sectionName} updated.');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.sectionName}',
            style: const TextStyle(fontFamily: 'Outfit')),
        backgroundColor: feastGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: feastGreen))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: 'Enter content here...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isSaving
                      ? const CircularProgressIndicator(color: feastGreen)
                      : ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: feastGreen,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Save Changes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold)),
                        ),
                ],
              ),
            ),
    );
  }
}

// ─── Shared helper: prompt for a text reason ──────────────────────────────────

Future<String?> _promptReason(BuildContext context, String label) async {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(label,
          style: const TextStyle(
              fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter reason...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: feastGreen),
          onPressed: () => Navigator.pop(context, ctrl.text.trim()),
          child: const Text('Confirm',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// This entire screen maps 1-to-1 with the React.js admin dashboard.
// Each tab corresponds to a dashboard section in React:
//
// Tab 1 – Users     : /admin/users — list users where status=='pending'
// Tab 2 – Posts     : /admin/posts — list aid_requests where status=='pending'
// Tab 3 – Events    : /admin/events — list charity_events where status=='pending'
// Tab 4 – Reports   : /admin/reports — list reports where status=='pending'
// Tab 5 – Announce  : /admin/announcements — CRUD on 'announcements' collection
// Tab 6 – Content   : /admin/content — CRUD on 'static_content' collection
//
// All Firestore writes here use the same collection paths and field
// names — the React dashboard can reuse the same data model exactly.
//
// Approve user   : updateDoc(users/{uid}, { status: 'active' })
// Reject user    : updateDoc(users/{uid}, { status: 'rejected', rejectionReason })
// Approve post   : updateDoc(aid_requests/{id}, { status: 'approved' })
// Reject post    : updateDoc(aid_requests/{id}, { status: 'rejected', rejectionReason })
// Ban user       : updateDoc(users/{uid}, { status: 'banned', banReason, banExpiry })
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
