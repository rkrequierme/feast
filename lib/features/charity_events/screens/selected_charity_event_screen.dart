// lib/features/charity_events/screens/selected_charity_event_screen.dart
//
// Detail view for a single charity event, loaded live from Firestore.
// Route argument: String docId
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Collection: charity_events
// Fields: title, description, category, location, startTime, endTime,
//         status, imageUrls, participantCount
// React query:
//   const docRef = doc(db, 'charity_events', docId);
//   const docSnap = await getDoc(docRef);
// Join request: setDoc(doc(db, 'charity_events', docId, 'volunteers', uid), {
//   userId: uid, status: 'pending', joinedAt: serverTimestamp()
// });

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:feast/core/core.dart';
import 'package:feast/core/services/firestore_service.dart';
import 'package:feast/core/utils/date_parser.dart';

class SelectedCharityEventScreen extends StatefulWidget {
  const SelectedCharityEventScreen({super.key});

  @override
  State<SelectedCharityEventScreen> createState() =>
      _SelectedCharityEventScreenState();
}

class _SelectedCharityEventScreenState
    extends State<SelectedCharityEventScreen> {
  String? _docId;
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _hasJoined = false;
  bool _isBookmarked = false;
  int _carouselPage = 0;
  final PageController _pageController = PageController();
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await FirestoreService.instance.getCurrentUserName();
    if (mounted) setState(() => _username = name);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && _docId == null) {
      _docId = arg;
      _loadEvent();
      _checkJoined();
      _checkBookmark();
    }
  }

  Future<void> _loadEvent() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirestorePaths.charityEvents)
        .doc(_docId)
        .get();
    if (!mounted) return;
    setState(() {
      _data = snap.data();
      _isLoading = false;
    });
  }

  Future<void> _checkJoined() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirestorePaths.charityEventVolunteers(_docId!))
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (mounted) setState(() => _hasJoined = snap.exists);
  }

  Future<void> _checkBookmark() async {
    final b = await FirestoreService.instance.isBookmarked(_docId!);
    if (mounted) setState(() => _isBookmarked = b);
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await FirestoreService.instance.removeBookmark(_docId!);
      FeastToast.showSuccess(context, 'Removed from Bookmarks.');
    } else {
      await FirestoreService.instance.addBookmark(
        itemId: _docId!,
        itemType: 'event',
        title: _data?['title'] ?? '',
      );
      FeastToast.showSuccess(context, 'Saved to Bookmarks.');
    }
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
  }

  Future<void> _handleShare() async {
    final link = 'https://feast.app/events/$_docId';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    FeastToast.showSuccess(context, 'Link copied to clipboard.');
  }

  void _showReport() {
    if (_data == null) return;
    showDialog(
      context: context,
      builder: (_) => ReportModal(
        targetTitle: _data?['title'] as String? ?? '',
        targetType: 'event',
        onSubmit: (title, desc) async {
          await FirestoreService.instance.submitReport(
            targetId: _docId!,
            targetType: 'charity_event',
            title: title,
            description: desc,
          );
          if (!mounted) return;
          FeastToast.showSuccess(context, 'Report submitted. Thank you.');
        },
      ),
    );
  }

  void _showJoinModal() {
    showDialog(
      context: context,
      builder: (_) => JoinEventDialog(
        eventTitle: _data?['title'] as String? ?? 'this event',
        onConfirm: () async {
          await FirestoreService.instance.joinCharityEvent(_docId!);
          if (!mounted) return;
          setState(() => _hasJoined = true);
          FeastToast.showSuccess(
            context,
            'Join request submitted! Waiting for admin confirmation.',
          );
        },
      ),
    );
  }

  Future<void> _leaveEvent() async {
    try {
      await FirestoreService.instance.leaveCharityEvent(_docId!);
      if (!mounted) return;
      setState(() => _hasJoined = false);
      FeastToast.showSuccess(context, 'You have left the event.');
    } catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, e.toString());
    }
  }

  bool get _isWithin24h {
    final start = DateParser.parse(_data?['startTime']);
    if (start == null) return false;
    return DateTime.now()
        .isAfter(start.subtract(const Duration(hours: 24)));
  }

  double get _elapsedPercent {
    final start = DateParser.parse(_data?['startTime']);
    final end = DateParser.parse(_data?['endTime']);
    if (start == null || end == null) return 0;
    final total = end.difference(start).inMinutes;
    if (total <= 0) return 0;
    final elapsed = DateTime.now().difference(start).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: feastBlue)),
      );
    }
    if (_data == null) {
      return const Scaffold(
          body: ErrorStateWidget(message: 'Event not found.'));
    }

    final images = (_data!['imageUrls'] as List?)?.cast<String>() ?? [];
    final title = _data!['title'] as String? ?? '';
    final category = _data!['category'] as String? ?? '';
    final location = _data!['location'] as String? ?? '';
    final description = _data!['description'] as String? ?? '';
    final participantCount = (_data!['participantCount'] as int?) ?? 0;

    final startTime = DateParser.parse(_data!['startTime']);
    final endTime = DateParser.parse(_data!['endTime']);
    final duration = startTime != null && endTime != null
        ? '${DateFormat('h:mm a').format(startTime)} – ${DateFormat('h:mm a (MMM d, y)').format(endTime)}'
        : 'TBD';

    final started = startTime != null && DateTime.now().isAfter(startTime);

    return Scaffold(
      appBar: FeastAppBar(title: title,),
      drawer: const FeastDrawer(username: ''),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCarousel(images),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: feastBlack)),
                        const SizedBox(height: 12),
                        _metaRow(Icons.category_outlined,
                            'Category: ', category),
                        _metaRow(Icons.location_on_outlined,
                            'Location: ', location),
                        _metaRow(
                            Icons.schedule, 'Duration: ', duration),
                        const SizedBox(height: 12),
                        const Divider(color: feastLighterBlue),
                        const SizedBox(height: 8),
                        Text(description,
                            style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Outfit',
                                color: feastGray,
                                height: 1.5)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      if (started)
                        Expanded(
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: _elapsedPercent,
                                color: feastBlue,
                                backgroundColor:
                                    feastLighterBlue.withAlpha(80),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_elapsedPercent * 100).toInt()}% Elapsed',
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    color: feastGray),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          const Icon(Icons.people_outline,
                              color: feastBlue, size: 28),
                          Text('$participantCount',
                              style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  color: feastBlack)),
                          const Text('Participants',
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 10,
                                  color: feastGray)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _hasJoined
                      ? ElevatedButton(
                          onPressed:
                              _isWithin24h ? null : _leaveEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(25)),
                            disabledBackgroundColor:
                                Colors.red.withAlpha(80),
                          ),
                          child: Text(
                            _isWithin24h
                                ? 'Cannot Leave (< 24h to start)'
                                : 'Leave Event',
                            style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _showJoinModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: feastBlue,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(25)),
                          ),
                          child: const Text('JOIN US',
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 2),
    );
  }

  Widget _buildCarousel(List<String> images) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: images.isEmpty
              ? Container(
                  color: feastLighterBlue.withAlpha(80),
                  child: const Icon(Icons.event,
                      size: 80, color: feastBlue))
              : PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) =>
                      setState(() => _carouselPage = i),
                  itemBuilder: (_, i) => Image.network(images[i],
                      fit: BoxFit.cover),
                ),
        ),
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleBtn(
                  Icons.arrow_back, () => Navigator.pop(context)),
              Row(children: [
                _circleBtn(Icons.warning_amber_rounded, _showReport,
                    color: Colors.red),
                const SizedBox(width: 8),
                _circleBtn(Icons.share, _handleShare,
                    color: feastBlue),
                const SizedBox(width: 8),
                _circleBtn(
                  _isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  _toggleBookmark,
                  color: feastBlue,
                ),
              ]),
            ],
          ),
        ),
        if (images.length > 1 && _carouselPage > 0)
          Positioned(
            left: 8,
            child: _arrowBtn(Icons.chevron_left, () {
              _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            }),
          ),
        if (images.length > 1 && _carouselPage < images.length - 1)
          Positioned(
            right: 8,
            child: _arrowBtn(Icons.chevron_right, () {
              _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            }),
          ),
      ],
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: feastBlue),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Outfit',
                    color: feastBlack),
                children: [
                  TextSpan(
                      text: label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: value,
                      style:
                          TextStyle(color: feastGray.withAlpha(220))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color ?? feastBlack),
      ),
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(180),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: feastBlue, size: 22),
      ),
    );
  }
}
