// lib/features/aid_requests/screens/selected_aid_request_screen.dart
//
// Detail view for a single aid request, loaded live from Firestore.
// Route argument: String docId
//
// REACT.JS INTEGRATION NOTE:
// =========================
// getDoc(doc(db, 'aid_requests', docId))
// Sub-collection donations: collection('aid_requests/{id}/donations')
// Bookmark: setDoc(doc(db,'users',uid,'bookmarks',docId), {...})

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class SelectedAidRequestScreen extends StatefulWidget {
  const SelectedAidRequestScreen({super.key});

  @override
  State<SelectedAidRequestScreen> createState() =>
      _SelectedAidRequestScreenState();
}

class _SelectedAidRequestScreenState
    extends State<SelectedAidRequestScreen> {
  String? _docId;
  Map<String, dynamic>? _data;
  bool _isBookmarked = false;
  bool _isLoading = true;
  int _carouselPage = 0;
  final PageController _pageController = PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && _docId == null) {
      _docId = arg;
      _loadRequest();
      _checkBookmark();
    }
  }

  Future<void> _loadRequest() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirestorePaths.aidRequests)
        .doc(_docId)
        .get();
    if (!mounted) return;
    setState(() {
      _data = snap.data();
      _isLoading = false;
    });
  }

  Future<void> _checkBookmark() async {
    final isBookmarked =
        await FirestoreService.instance.isBookmarked(_docId!);
    if (mounted) setState(() => _isBookmarked = isBookmarked);
  }

  Future<void> _toggleBookmark() async {
    if (_docId == null || _data == null) return;
    if (_isBookmarked) {
      await FirestoreService.instance.removeBookmark(_docId!);
      FeastToast.showSuccess(context, 'Removed from Bookmarks.');
    } else {
      await FirestoreService.instance.addBookmark(
        itemId: _docId!,
        itemType: 'request',
        title: _data!['title'] as String? ?? '',
      );
      FeastToast.showSuccess(context, 'Saved to Bookmarks.');
    }
    setState(() => _isBookmarked = !_isBookmarked);
  }

  Future<void> _handleShare() async {
    final link = 'https://feast.app/requests/$_docId';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    FeastToast.showSuccess(context, 'Link copied to clipboard.');
  }

  void _showReport() {
    if (_data == null) return;
    showDialog(
      context: context,
      builder: (_) => ReportModal(
        targetTitle: _data!['title'] as String? ?? '',
        targetType: 'request',
        onSubmit: (title, desc) async {
          await FirestoreService.instance.submitReport(
            targetId: _docId!,
            targetType: 'aid_request',
            title: title,
            description: desc,
          );
          if (!mounted) return;
          FeastToast.showSuccess(context, 'Report submitted. Thank you.');
        },
      ),
    );
  }

  void _showGiveItems() {
    if (_data == null) return;
    showDialog(
      context: context,
      builder: (_) => DonateModal(
        title: 'Donate Items',
        aidRequestName: _data!['title'] as String? ?? '',
        boldNote: 'Note: Items must be physically delivered to the Barangay Hall.',
        onYes: () => showDialog(
          context: context,
          builder: (_) => ItemDonationModal(
            acceptedItems: (_data!['acceptedItems'] as List?)?.cast<String>() ?? [],
            onConfirm: (items) async {
              await FirestoreService.instance.donateItems(
                requestId: _docId!,
                items: items,
              );
              if (!mounted) return;
              FeastToast.showSuccess(context, 'Item donation submitted. Thank you!');
            },
          ),
        ),
      ),
    );
  }

  void _showDonateFunds() {
    if (_data == null) return;
    showDialog(
      context: context,
      builder: (_) => DonateModal(
        title: 'Donate Funds',
        aidRequestName: _data!['title'] as String? ?? '',
        onYes: () => showDialog(
          context: context,
          builder: (_) => DonateFundsAmountDialog(
            requestTitle: _data!['title'] as String? ?? '',
            onConfirm: (amount) async {
              await FirestoreService.instance.donateFunds(
                requestId: _docId!,
                amount: amount,
              );
              if (!mounted) return;
              FeastToast.showSuccess(
                context,
                '₱${amount.toStringAsFixed(2)} donation pledged. Thank you!',
              );
            },
          ),
        ),
      ),
    );
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
        body: Center(child: CircularProgressIndicator(color: feastGreen)),
      );
    }
    if (_data == null) {
      return const Scaffold(
        body: ErrorStateWidget(message: 'Request not found.'),
      );
    }

    final images = (_data!['imageUrls'] as List?)?.cast<String>() ?? [];
    final title = _data!['title'] as String? ?? '';
    final category = _data!['category'] as String? ?? '';
    final location = _data!['location'] as String? ?? '';
    final description = _data!['description'] as String? ?? '';
    final aidType = _data!['aidType'] as String? ?? '';
    final goalAmount = (_data!['fundraiserGoal'] as num?)?.toDouble() ?? 0;
    final fundsDonated = (_data!['fundsDonated'] as num?)?.toDouble() ?? 0;
    final donorCount = (_data!['donorCount'] as int?) ?? 0;
    final itemsDonated = (_data!['itemsDonated'] as int?) ?? 0;
    final goalPercent = goalAmount > 0
        ? ((fundsDonated / goalAmount) * 100).clamp(0, 100).toInt()
        : 0;

    final expiresAt =
        (_data!['expiresAt'] as Timestamp?)?.toDate();
    final timeRemaining = expiresAt != null
        ? _formatTimeRemaining(expiresAt)
        : 'N/A';

    final isFundraiser =
        aidType.contains('Fundraiser') || aidType.contains('Supply');
    final isInKind =
        aidType.contains('In-Kind') || aidType.contains('Supply');

    return Scaffold(
      appBar: FeastAppBar(title: title),
      drawer: const FeastDrawer(username: ''),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image Carousel
                _buildImageCarousel(images),

                // Detail Card
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                                color: feastBlack)),
                        const SizedBox(height: 12),
                        _metaRow(Icons.category_outlined,
                            'Category: ', category),
                        _metaRow(Icons.location_on_outlined,
                            'Location: ', location),
                        _metaRow(Icons.access_time,
                            'Time Remaining: ', timeRemaining),
                        _metaRow(Icons.volunteer_activism,
                            'Aid Type: ', aidType),
                        const SizedBox(height: 12),
                        const Text('Description',
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: feastBlack)),
                        const SizedBox(height: 4),
                        Text(description,
                            style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                color: feastGray,
                                height: 1.5)),

                        // Stats row
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem(Icons.people_outline,
                                '$donorCount', 'Donors'),
                            if (isFundraiser)
                              _statItem(
                                  Icons.attach_money,
                                  '₱${fundsDonated.toStringAsFixed(0)}',
                                  'Raised'),
                            if (isInKind)
                              _statItem(Icons.inventory_2_outlined,
                                  '$itemsDonated', 'Items'),
                          ],
                        ),

                        // Fundraiser progress bar
                        if (isFundraiser && goalAmount > 0) ...[
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('₱${fundsDonated.toStringAsFixed(0)} raised',
                                  style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 11,
                                      color: feastGreen,
                                      fontWeight: FontWeight.w600)),
                              Text('Goal: ₱${goalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 11,
                                      color: feastGray)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: goalPercent / 100,
                              minHeight: 8,
                              backgroundColor: feastLightGreen.withAlpha(80),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  feastGreen),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('$goalPercent% funded',
                              style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 10,
                                  color: feastGray)),
                        ],

                        // Donate buttons
                        const SizedBox(height: 20),
                        if (isFundraiser)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showDonateFunds,
                              icon: const Icon(Icons.attach_money,
                                  size: 18),
                              label: const Text('Donate Funds',
                                  style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: feastGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                        if (isFundraiser && isInKind)
                          const SizedBox(height: 8),
                        if (isInKind)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showGiveItems,
                              icon: const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 18),
                              label: const Text('Donate Items',
                                  style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: feastBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Bookmark toggle
                GestureDetector(
                  onTap: _toggleBookmark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: _isBookmarked ? feastOrange : feastGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isBookmarked
                            ? 'Saved to Bookmarks'
                            : 'Save to Bookmarks',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          color: _isBookmarked ? feastOrange : feastGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 1),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: images.isEmpty
              ? Container(
                  color: feastLightGreen.withAlpha(80),
                  child: const Icon(Icons.volunteer_activism,
                      size: 80, color: feastGreen),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) =>
                      setState(() => _carouselPage = i),
                  itemBuilder: (_, i) => Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                                color: feastGreen)),
                  ),
                ),
        ),
        // Action buttons overlay
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleBtn(Icons.arrow_back,
                  () => Navigator.pop(context)),
              Row(
                children: [
                  _circleBtn(Icons.warning_amber_rounded, _showReport,
                      color: Colors.red),
                  const SizedBox(width: 8),
                  _circleBtn(Icons.share, _handleShare,
                      color: feastGreen),
                  const SizedBox(width: 8),
                  _circleBtn(
                    _isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    _toggleBookmark,
                    color: feastGreen,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Left / Right arrows
        if (images.length > 1 && _carouselPage > 0)
          Positioned(
            left: 8,
            child: _arrowBtn(Icons.chevron_left, () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }),
          ),
        if (images.length > 1 && _carouselPage < images.length - 1)
          Positioned(
            right: 8,
            child: _arrowBtn(Icons.chevron_right, () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }),
          ),
        // Dot indicators
        if (images.length > 1)
          Positioned(
            bottom: 8,
            child: Row(
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _carouselPage == i ? 16 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _carouselPage == i
                        ? Colors.white
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: feastGreen),
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
                      style: TextStyle(
                          color: feastGray.withAlpha(220))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: feastLightGreen.withAlpha(80),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: feastGreen),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: feastBlack)),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                color: feastGray),
            textAlign: TextAlign.center),
      ],
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
        child: Icon(icon, color: feastGreen, size: 22),
      ),
    );
  }

  String _formatTimeRemaining(DateTime expires) {
    final diff = expires.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays} Days Left';
    if (diff.inHours > 0) return '${diff.inHours} Hours Left';
    return '${diff.inMinutes} Minutes Left';
  }
}
