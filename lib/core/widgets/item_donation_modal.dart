import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// item_donation_modal.dart
//
// Step-2 for in-kind / supply donations. Shown after DonateModal for items.
//
// Replaces AND removes all of these duplicate widgets:
//   • item_donation_dialog.dart  (same stepper, different class name)
//   • item_donation_modal.dart   (old version — now THIS file)
//   • give_items_dialog.dart     (single-item old version)
//
// This single widget handles 1-to-N items with +/− quantity steppers.
// ─────────────────────────────────────────────────────────────────────────────

class _ItemEntry {
  final TextEditingController nameCtrl;
  int quantity;

  _ItemEntry({String name = '', this.quantity = 1})
      : nameCtrl = TextEditingController(text: name);

  void dispose() => nameCtrl.dispose();

  Map<String, dynamic> toMap() =>
      {'name': nameCtrl.text.trim(), 'qty': quantity};
}

class ItemDonationModal extends StatefulWidget {
  /// Optional list of accepted item names from the aid request to pre-fill.
  final List<String> acceptedItems;

  /// Called with [{name, qty}, ...] when the user confirms.
  final void Function(List<Map<String, dynamic>> items)? onConfirm;

  const ItemDonationModal({
    super.key,
    this.acceptedItems = const [],
    this.onConfirm,
  });

  @override
  State<ItemDonationModal> createState() => _ItemDonationModalState();
}

class _ItemDonationModalState extends State<ItemDonationModal> {
  late final List<_ItemEntry> _items;

  @override
  void initState() {
    super.initState();
    // Pre-fill with accepted items if provided, otherwise start with one blank row
    _items = widget.acceptedItems.isNotEmpty
        ? widget.acceptedItems.map((n) => _ItemEntry(name: n)).toList()
        : [_ItemEntry()];
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() => setState(() => _items.add(_ItemEntry()));

  void _removeItem(int i) {
    setState(() {
      _items[i].dispose();
      _items.removeAt(i);
    });
  }

  void _confirm() {
    final result = _items
        .map((e) => e.toMap())
        .where((m) => (m['name'] as String).isNotEmpty)
        .toList();

    if (result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one item name.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);
    widget.onConfirm?.call(result);
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
            // ── Header ──────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item Donation',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: feastBlack,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Configure how many items you will provide.',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Item Names & Amount',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: feastBlack,
              ),
            ),
            const SizedBox(height: 10),

            // ── Item rows ────────────────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(_items.length, (i) {
                    final entry = _items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        children: [
                          // Name field
                          TextField(
                            controller: entry.nameCtrl,
                            style: const TextStyle(
                                fontFamily: 'Outfit', fontSize: 13),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.inventory_2_outlined,
                                size: 20,
                                color: Colors.black54,
                              ),
                              hintText: 'Item Name',
                              hintStyle: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  color: Colors.black38),
                              suffixIcon: _items.length > 1
                                  ? GestureDetector(
                                      onTap: () => _removeItem(i),
                                      child: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: feastGreen, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Quantity stepper
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _stepBtn(
                                icon: Icons.remove,
                                enabled: entry.quantity > 1,
                                onTap: () =>
                                    setState(() => entry.quantity--),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                '${entry.quantity}',
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 20),
                              _stepBtn(
                                icon: Icons.add,
                                enabled: true,
                                onTap: () =>
                                    setState(() => entry.quantity++),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── Add Another ──────────────────────────────────────────────────
            GestureDetector(
              onTap: _addItem,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: feastGreen, size: 18),
                  SizedBox(width: 4),
                  Text(
                    '+ Add Another',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: feastGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Confirm ──────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: feastBlue,
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

            // ── Cancel ───────────────────────────────────────────────────────
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

  Widget _stepBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? Colors.grey.shade400 : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? Colors.white : Colors.grey.shade100,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.black87 : Colors.grey.shade400,
        ),
      ),
    );
  }
}
