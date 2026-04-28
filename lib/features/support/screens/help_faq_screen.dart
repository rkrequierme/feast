// lib/features/support/screens/help_faq_screen.dart
//
// Help & FAQ screen with expandable Q&A sections.
// Users can submit questions to admins via the FAB.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Collection: static_content
// Document: help_faq
// Fields: faqs (Array of {question, answer})
// Collection for user questions: user_questions
// Fields: title, description, status, submittedAt
// Admin dashboard: query where status == 'pending'

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast/core/core.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  String _username = 'User';

  static const _defaultFaqs = [
    {
      'question': 'What is F.E.A.S.T.?',
      'answer':
          'F.E.A.S.T. stands for Food, Emergency Aid, Support & Transparency. It is a platform built to connect donors, volunteers, and beneficiaries in Barangay Almanza Dos.',
    },
    {
      'question': 'What are aid requests or charity events?',
      'answer':
          'Aid requests are community-submitted needs such as food, medicine, or services. Charity events are organised activities where volunteers and donors contribute directly to the community.',
    },
    {
      'question': 'How do I report users for misbehaviour?',
      'answer':
          "Navigate to a user's profile and tap the Report button, or use the Submit a Question button on this screen to contact the moderation team.",
    },
    {
      'question': 'How long does admin approval take?',
      'answer':
          'Registrations and posts are typically reviewed within 24 hours. You will receive a notification once a decision is made.',
    },
    {
      'question': 'Can I edit my aid request after posting?',
      'answer':
          'No. Edits are disabled once a post is live. Please review all details carefully before submitting.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await FirestoreService.instance.getCurrentUserName();
    if (mounted) setState(() => _username = name);
  }

  void _showSubmitQuestion() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Submit a Question',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Note: Submit Your Questions Here',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: feastGray,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Question Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Insert Question Description Here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: feastError,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) {
                        FeastToast.showError(context, 'Please enter a question title.');
                        return;
                      }
                      await FirebaseFirestore.instance
                          .collection('user_questions')
                          .add({
                        'title': titleCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                        'status': 'pending',
                        'submittedAt': FieldValue.serverTimestamp(),
                      });
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      FeastToast.showSuccess(context, 'Question submitted. Thank you!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: feastBlue,
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Help & FAQ', username: _username),
      drawer: FeastDrawer(username: _username),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      floatingActionButton: FeastFloatingButton(
        icon: Icons.chat_bubble_outline,
        tooltip: 'Submit a Question',
        onPressed: _showSubmitQuestion,
      ),
      body: FeastBackground(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('static_content')
              .doc('help_faq')
              .snapshots(),
          builder: (context, snap) {
            List<Map<String, String>> faqs = List.from(_defaultFaqs);
            if (snap.hasData && snap.data!.exists) {
              final raw = snap.data!.data() as Map<String, dynamic>?;
              final adminFaqs = (raw?['faqs'] as List?)?.cast<Map<String, dynamic>>();
              if (adminFaqs != null && adminFaqs.isNotEmpty) {
                faqs = adminFaqs
                    .map((f) => {
                          'question': f['question'] as String? ?? '',
                          'answer': f['answer'] as String? ?? '',
                        })
                    .toList();
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeastWhiteSection(
                    child: const Text(
                      "Whatever your role in the Almanza Dos community, we're here to support you.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: feastBlack,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeastWhiteSection(
                    child: const Text(
                      'Whether you are managing operations, donating to a cause, volunteering your time, or seeking support as a beneficiary, we want your experience to be seamless.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: feastGray,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FeastYellowSection(title: 'FAQ List'),
                  const SizedBox(height: 12),
                  ...faqs.asMap().entries.map((entry) {
                    final faq = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FeastExpandableItem(
                        title: faq['question'] ?? '',
                        initiallyExpanded: entry.key == 0,
                        content: Text(
                          faq['answer'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: feastGray,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
