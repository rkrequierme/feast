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
  final IconData? icon; // Optional icon

  const FeastExpandableItem({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.icon,
  });

  @override
  State<FeastExpandableItem> createState() => _FeastExpandableItemState();
}

class _FeastExpandableItemState extends State<FeastExpandableItem>
    with AutomaticKeepAliveClientMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    // Required for AutomaticKeepAliveClientMixin
    super.build(context);
    
    return FeastWhiteSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ───────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: feastLightGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, color: feastGreen, size: 28),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 28,
                    color: feastGray,
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable Content ───────────────────────────────────
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            widget.content,
          ],
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keeps the widget state alive
}
