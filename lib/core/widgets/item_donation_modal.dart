import 'package:flutter/material.dart';

/// ItemDonationModal
/// Lets a donor configure item names and quantities before confirming a donation.
/// Supports adding multiple item entries dynamically.
///
/// Parameters:
///   [title]       — Dialog title. Defaults to "Item Donation".
///   [subtitle]    — Subtitle text. Defaults to "Configure how many items you will provide."
///   [onConfirm]   — Callback with the list of [DonationItem] when Confirm is tapped.
///   [onCancel]    — Callback when Cancel is tapped (defaults to pop).
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => ItemDonationModal(
///     onConfirm: (items) {
///       // send items to Firebase
///     },
///   ),
/// );
/// ```
class DonationItem {
  String name;
  int quantity;
  DonationItem({this.name = '', this.quantity = 1});
}

class ItemDonationModal extends StatefulWidget {
  final String title;
  final String subtitle;
  final void Function(List<DonationItem> items)? onConfirm;
  final VoidCallback? onCancel;

  const ItemDonationModal({
    super.key,
    this.title = 'Item Donation',
    this.subtitle = 'Configure how many items you will provide.',
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<ItemDonationModal> createState() => _ItemDonationModalState();
}

class _ItemDonationModalState extends State<ItemDonationModal> {
  final List<DonationItem> _items = [DonationItem()];
  final List<TextEditingController> _controllers = [TextEditingController()];

  void _addItem() {
    setState(() {
      _items.add(DonationItem());
      _controllers.add(TextEditingController());
    });
  }

  void _increment(int index) =>
      setState(() => _items[index].quantity++);

  void _decrement(int index) {
    if (_items[index].quantity > 1) {
      setState(() => _items[index].quantity--);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + close
            Row(
              children: [
                Expanded(
                  child: Text(widget.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed:
                      widget.onCancel ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(widget.subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 16),

            const Text('Item Names & Amount',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // Item list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(_items.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          // Item name field
                          TextField(
                            controller: _controllers[i],
                            onChanged: (v) => _items[i].name = v,
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.card_giftcard, size: 20),
                              hintText: 'Item Name',
                              hintStyle:
                                  const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Quantity stepper
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _stepperButton(
                                icon: Icons.remove,
                                onTap: () => _decrement(i),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  '${_items[i].quantity}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              _stepperButton(
                                icon: Icons.add,
                                onTap: () => _increment(i),
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

            // Add Another
            GestureDetector(
              onTap: _addItem,
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.green, size: 18),
                  SizedBox(width: 4),
                  Text('Add Another',
                      style: TextStyle(color: Colors.green, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Confirm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => widget.onConfirm?.call(_items),
                child: const Text('Confirm', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed:
                    widget.onCancel ?? () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}