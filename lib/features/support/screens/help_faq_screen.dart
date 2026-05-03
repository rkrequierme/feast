// lib/features/support/screens/help_faq_screen.dart
//
// Help & FAQ screen with expandable Q&A sections.
// Users can submit questions to admins via the FAB.

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
      'icon': Icons.info_outline,
    },
    {
      'question': 'What are aid requests or charity events?',
      'answer':
          'Aid requests are community-submitted needs such as food, medicine, or services. Charity events are organised activities where volunteers and donors contribute directly to the community.',
      'icon': Icons.volunteer_activism_outlined,
    },
    {
      'question': 'How do I report users for misbehaviour?',
      'answer':
          "Navigate to a user's profile and tap the Report button, or use the Ask a Question button on this screen to contact the moderation team.",
      'icon': Icons.flag_outlined,
    },
    {
      'question': 'How long does admin approval take?',
      'answer':
          'Registrations and posts are typically reviewed within 24 hours. You will receive a notification once a decision is made.',
      'icon': Icons.hourglass_empty_outlined,
    },
    {
      'question': 'Can I edit my aid request after posting?',
      'answer':
          'No. Edits are disabled once a post is live. Please review all details carefully before submitting.',
      'icon': Icons.edit_off_outlined,
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
      builder: (_) => QuestionModal(
        titleController: titleCtrl,
        descController: descCtrl,
        onSubmit: (title, description) async {
          if (description.isEmpty) {
            FeastToast.showError(context, 'Please enter your question.');
            return;
          }

          await FirebaseFirestore.instance
              .collection('user_questions')
              .add({
            'title': title.isNotEmpty ? title : 'User Question',
            'description': description,
            'status': 'pending',
            'submittedAt': FieldValue.serverTimestamp(),
          });
          
          if (!context.mounted) return;
          Navigator.pop(context);
          FeastToast.showSuccess(context, 'Question submitted successfully!');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Help & FAQ',),
      drawer: FeastDrawer(username: _username),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      floatingActionButton: FeastFloatingButton(
        icon: Icons.question_answer_outlined,
        tooltip: 'Ask a Question',
        backgroundColor: feastBlue,
        onPressed: _showSubmitQuestion,
      ),
      body: FeastBackground(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('static_content')
              .doc('help_faq')
              .snapshots(),
          builder: (context, snap) {
            List<Map<String, dynamic>> faqs = List.from(_defaultFaqs);
            if (snap.hasData && snap.data!.exists) {
              final raw = snap.data!.data() as Map<String, dynamic>?;
              final adminFaqs = (raw?['faqs'] as List?)?.cast<Map<String, dynamic>>();
              if (adminFaqs != null && adminFaqs.isNotEmpty) {
                faqs = adminFaqs
                    .map((f) => {
                          'question': f['question'] as String? ?? '',
                          'answer': f['answer'] as String? ?? '',
                          'icon': Icons.help_outline,
                        })
                    .toList();
              }
            }

            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FeastWhiteSection(
                          child: Column(
                            children: const [
                              Icon(Icons.help_outline, size: 48, color: feastBlue),
                              SizedBox(height: 12),
                              Text(
                                "We're Here to Help",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: feastBlack,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Whatever your role in the Almanza Dos community, we\'re here to support you with any questions or concerns.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  color: feastGray,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const FeastYellowSection(title: 'Frequently Asked Questions'),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final faq = faqs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: FeastExpandableItem(
                          title: faq['question'] ?? '',
                          icon: faq['icon'] as IconData?,
                          initiallyExpanded: index == 0,
                          content: Text(
                            faq['answer'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              color: feastGray,
                              height: 1.6,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: faqs.length,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
