import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  // ── Modal logic ─────────────────────────────────────────────────────────────

  void _showSubmitQuestionModal() {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Modal Header ───────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Question Title',
                          hintStyle: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Colors.black45,
                          ),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, size: 20, color: Colors.black54),
                    ),
                  ],
                ),

                const Text(
                  'Note: Submit Your Questions Here',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Description Field ──────────────────────────────
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Insert Question Description Here...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Colors.black38,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: feastGreen, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Action Buttons ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Submit
                    ElevatedButton(
                      onPressed: () {
                        // TODO: wire up submission logic
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Help & FAQ'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: const FeastBottomNav(currentIndex: -1),
      floatingActionButton: FeastFloatingButton(
        icon: Icons.chat_bubble_outline,
        tooltip: 'Submit a Question',
        onPressed: _showSubmitQuestionModal,
      ),
      body: FeastBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero Card ─────────────────────────────────────────────
              FeastWhiteSection(
                child: const Text(
                  'Whatever your role in the Almanza Dos community, we\'re '
                  'here to support you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FeastWhiteSection(
                child: const Text(
                  'Whether you are managing operations, donating to a cause, '
                  'volunteering your time, or seeking support as a beneficiary, '
                  'we want your experience to be seamless. Find quick answers '
                  'to your questions below, or reach out to us if you need '
                  'further assistance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Section Header ────────────────────────────────────────
              const FeastYellowSection(title: 'FAQ List'),

              const SizedBox(height: 12),

              // ── FAQ Expandable Items ──────────────────────────────────
              FeastExpandableItem(
                title: 'What is F.E.A.S.T.?',
                initiallyExpanded: true,
                content: const Text(
                  'F.E.A.S.T. is more than just a management tool; it\'s a '
                  'platform built on the belief that we should all be better '
                  'and more supported than we were yesterday. By integrating '
                  'donors, volunteers, and beneficiaries into one seamless '
                  'system, F.E.A.S.T. empowers charities to maximize their '
                  'impact and ensures that help reaches the right people at '
                  'the right time.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const FeastExpandableItem(
                title: 'What are aid requests or charity events?',
                content: Text(
                  'Aid requests are community-submitted needs such as food, '
                  'medicine, or services. Charity events are organized '
                  'activities where volunteers and donors can contribute '
                  'directly to the Almanza Dos community.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const FeastExpandableItem(
                title: 'How do I report users for misbehavior?',
                content: Text(
                  'You can report users by navigating to their profile and '
                  'tapping the report button. Alternatively, use the Submit '
                  'a Question button on this screen to contact the moderation '
                  'team directly.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 80), // Space for FAB clearance
            ],
          ),
        ),
      ),
    );
  }
}