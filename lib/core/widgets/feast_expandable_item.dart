import 'package:flutter/material.dart';
import '../core.dart';

/// A reusable expandable/collapsible list item used across App Guide,
/// Terms & Conditions, and Help & FAQ screens.
///
/// Shows a [title] with a +/− toggle icon. When expanded, displays
/// the [content] widget below the title row.
class FeastExpandableItem extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;

  const FeastExpandableItem({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<FeastExpandableItem> createState() => _FeastExpandableItemState();
}

class _FeastExpandableItemState extends State<FeastExpandableItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return FeastWhiteSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ───────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.remove : Icons.add,
                  size: 20,
                  color: Colors.black54,
                ),
              ],
            ),
          ),

          // ── Expandable Content ───────────────────────────────────
          if (_isExpanded) ...[
            const SizedBox(height: 10),
            widget.content,
          ],
        ],
      ),
    );
  }
}