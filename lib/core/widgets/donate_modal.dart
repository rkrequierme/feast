import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// donate_modal.dart
//
// Unified donation intent modal. Covers:
//   • "Donate Funds"  (step-1 intent + T&C → then show DonateFundsAmountDialog)
//   • "Donate Items"  (step-1 intent + T&C + delivery note → then show ItemDonationModal)
//
// Replaces and removes:
//   • donate_funds_dialog.dart  (duplicate of this)
//   • donate_items_dialog.dart  (duplicate of this)
//   • The old donate_modal.dart is now THIS file.
// ─────────────────────────────────────────────────────────────────────────────

class DonateModal extends StatefulWidget {
  /// 'Donate Funds' or 'Donate Items'
  final String title;
  final String aidRequestName;

  /// Bold note shown below body. Use for the physical-delivery reminder.
  final String? boldNote;

  final VoidCallback? onNo;

  /// Called only after T&C is accepted. Opens the next step in the flow.
  final VoidCallback? onYes;

  const DonateModal({
    super.key,
    this.title = 'Donate Funds',
    required this.aidRequestName,
    this.boldNote,
    this.onNo,
    this.onYes,
  });

  @override
  State<DonateModal> createState() => _DonateModalState();
}

class _DonateModalState extends State<DonateModal> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: feastBlack,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Body ─────────────────────────────────────────────────────────
            Text(
              'We wish to verify whether or not you are willing to donate to '
              '"${widget.aidRequestName}". Do you wish to proceed?',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            if (widget.boldNote != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.boldNote!,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: feastBlack,
                ),
              ),
            ],
            const SizedBox(height: 14),

            // ── T&C checkbox ─────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _termsAccepted,
                    activeColor: feastGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    onChanged: (v) =>
                        setState(() => _termsAccepted = v ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _termsAccepted = !_termsAccepted),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: "I've read the "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.legal),
                              child: const Text(
                                'terms and conditions',
                                style: TextStyle(
                                  color: feastBlue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Buttons ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _btn(
                  label: 'No',
                  color: Colors.red,
                  onTap: widget.onNo ?? () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                _btn(
                  label: 'Yes',
                  color: _termsAccepted ? feastBlue : feastBlue.withAlpha(100),
                  onTap: _termsAccepted
                      ? () {
                          Navigator.pop(context);
                          widget.onYes?.call();
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DonateFundsAmountDialog
// Step-2 for monetary donations. Shown after DonateModal for funds.
// ─────────────────────────────────────────────────────────────────────────────

class DonateFundsAmountDialog extends StatefulWidget {
  final String requestTitle;
  final void Function(double amount)? onConfirm;

  const DonateFundsAmountDialog({
    super.key,
    required this.requestTitle,
    this.onConfirm,
  });

  @override
  State<DonateFundsAmountDialog> createState() =>
      _DonateFundsAmountDialogState();
}

class _DonateFundsAmountDialogState extends State<DonateFundsAmountDialog> {
  final _ctrl = TextEditingController();
  String? _error;
  static const _presets = [50, 100, 250, 500, 1000];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final parsed = double.tryParse(_ctrl.text.trim());
    if (parsed == null || parsed <= 0) {
      setState(() => _error = 'Please enter a valid amount greater than ₱0.');
      return;
    }
    Navigator.pop(context);
    widget.onConfirm?.call(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'Donate How Much?',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: feastBlack,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the amount (₱) you wish to donate to "${widget.requestTitle}".',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),

            // Quick-select presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) {
                return GestureDetector(
                  onTap: () {
                    _ctrl.text = p.toString();
                    setState(() => _error = null);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: feastLightGreen.withAlpha(100),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: feastGreen.withAlpha(80)),
                    ),
                    child: Text(
                      '₱$p',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: feastGreen,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Amount field
            TextField(
              controller: _ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                prefixText: '₱ ',
                prefixStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: feastGreen,
                ),
                hintText: '0.00',
                errorText: _error,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: feastGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Cancel
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
