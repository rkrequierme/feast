import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

// ---------------------------------------------------------------------------
// ItemDonationDialog
// ---------------------------------------------------------------------------
// Step 2 – shown after DonateItemsDialog is confirmed.
// Allows the donor to configure item names and quantities.
//
// Usage:
//   showDialog(
//     context: context,
//     builder: (_) => ItemDonationDialog(
//       onConfirm: (items) { /* submit to Firestore */ },
//     ),
//   );
// ---------------------------------------------------------------------------

class _ItemEntry {
  final TextEditingController nameController;
  int quantity;

  _ItemEntry({String name = '', this.quantity = 1})
      : nameController = TextEditingController(text: name);

  void dispose() => nameController.dispose();
}

class ItemDonationDialog extends StatefulWidget {
  /// Called with a list of {name, quantity} maps when the user confirms.
  final void Function(List<Map<String, dynamic>> items)? onConfirm;

  const ItemDonationDialog({super.key, this.onConfirm});

  @override
  State<ItemDonationDialog> createState() => _ItemDonationDialogState();
}

class _ItemDonationDialogState extends State<ItemDonationDialog> {
  final List<_ItemEntry> _items = [_ItemEntry()];

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() => _items.add(_ItemEntry()));
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  void _confirm() {
    final result = _items
        .map((e) => {
              'name': e.nameController.text.trim(),
              'quantity': e.quantity,
            })
        .where((e) => (e['name'] as String).isNotEmpty)
        .toList();
    Navigator.pop(context);
    widget.onConfirm?.call(result);
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
                  child: const Icon(Icons.close,
                      size: 20, color: Colors.black45),
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
            ...List.generate(_items.length, (i) {
              final entry = _items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    // Name field
                    TextField(
                      controller: entry.nameController,
                      style: const TextStyle(
                          fontFamily: 'Outfit', fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.inventory_2_outlined,
                            size: 20, color: Colors.black54),
                        hintText: 'Item Name',
                        hintStyle: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: Colors.black38,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: feastGreen, width: 2),
                        ),
                        suffixIcon: _items.length > 1
                            ? GestureDetector(
                                onTap: () => _removeItem(i),
                                child: const Icon(Icons.remove_circle_outline,
                                    size: 18, color: Colors.red),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Quantity stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepperButton(
                          icon: Icons.remove,
                          onTap: entry.quantity > 1
                              ? () => setState(() => entry.quantity--)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${entry.quantity}',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildStepperButton(
                          icon: Icons.add,
                          onTap: () =>
                              setState(() => entry.quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            // ── Add another ─────────────────────────────────────────────────
            GestureDetector(
              onTap: _addItem,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: feastGreen, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Add Another',
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

            // ── Confirm / Cancel ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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

  Widget _buildStepperButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: onTap == null
              ? Colors.grey.shade100
              : Colors.white,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? Colors.grey.shade400
              : Colors.black87,
        ),
      ),
    );
  }
}