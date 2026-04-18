import 'package:flutter/material.dart';
import '../core.dart';

/// A dialog that allows users to donate physical items (non-monetary).
/// Shows a form for item name, quantity, and an optional note.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => GiveItemsDialog(
///     onSubmit: (itemName, quantity, note) { ... },
///   ),
/// );
/// ```
class GiveItemsDialog extends StatefulWidget {
  final void Function(String itemName, int quantity, String? note)? onSubmit;

  const GiveItemsDialog({super.key, this.onSubmit});

  @override
  State<GiveItemsDialog> createState() => _GiveItemsDialogState();
}

class _GiveItemsDialogState extends State<GiveItemsDialog> {
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final itemName = _itemNameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final note = _noteController.text.trim();

    if (itemName.isEmpty) return;

    widget.onSubmit?.call(itemName, quantity, note.isEmpty ? null : note);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: feastGreen.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    color: feastGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Give Items',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // ── Item Name ───────────────────────────────────────────────
            const Text(
              'Item Name',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                hintText: 'e.g. Canned goods, Rice, Clothes',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Quantity ────────────────────────────────────────────────
            const Text(
              'Quantity',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '1',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Note (Optional) ─────────────────────────────────────────
            const Text(
              'Note (Optional)',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Any special instructions...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Submit ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                child: const Text(
                  'Donate Items',
                  style: TextStyle(
                    fontFamily: 'Nunito',
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
