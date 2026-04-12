import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// DonateFundsAmountDialog
// ---------------------------------------------------------------------------
// Step 2 – shown after DonateFundsDialog is confirmed.
// The donor enters a peso amount and confirms.
//
// Usage:
//   showDialog(
//     context: context,
//     builder: (_) => DonateFundsAmountDialog(
//       requestTitle: 'Surgery Meds & Treatment',
//       onConfirm: (amount) { /* process payment */ },
//     ),
//   );
// ---------------------------------------------------------------------------

class DonateFundsAmountDialog extends StatefulWidget {
  final String requestTitle;

  /// Called with the entered amount (in pesos) when user confirms.
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

class _DonateFundsAmountDialogState
    extends State<DonateFundsAmountDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  // Quick-select presets (in PHP)
  static const _presets = [50, 100, 250, 500];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectPreset(int amount) {
    _controller.text = amount.toString();
    setState(() => _errorText = null);
  }

  void _confirm() {
    final raw = _controller.text.trim();
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) {
      setState(() => _errorText = 'Please enter a valid amount.');
      return;
    }
    Navigator.pop(context);
    widget.onConfirm?.call(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  child: const Icon(Icons.close,
                      size: 20, color: Colors.black45),
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

            const SizedBox(height: 16),

            // ── Preset chips ─────────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) {
                return GestureDetector(
                  onTap: () => _selectPreset(p),
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

            // ── Amount field ─────────────────────────────────────────────────
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (_) => setState(() => _errorText = null),
              decoration: InputDecoration(
                prefixText: '₱ ',
                prefixStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: feastGreen,
                ),
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.grey.shade400,
                ),
                errorText: _errorText,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: feastGreen, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Confirm / Cancel ─────────────────────────────────────────────
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
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
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
                  elevation: 0,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}