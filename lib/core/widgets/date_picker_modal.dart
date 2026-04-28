import 'package:flutter/material.dart';
import '../core.dart';

// Controls what the calendar overlay is currently showing.
enum _PickerOverlay { none, month, year }

class DatePickerModal {
  static Future<void> show({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    // Seed focusedDay from whatever is already in the controller (if valid),
    // otherwise default to today.
    DateTime focusedDay = _parseControllerDate(controller.text) ?? DateTime.now();
    DateTime? selected = _parseControllerDate(controller.text);

    // Persisted state variables for the modal session
    int yearPageOffset = 0;
    _PickerOverlay overlay = _PickerOverlay.none;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // ── Derived values ───────────────────────────────────────────────
          final int year = focusedDay.year;
          final int month = focusedDay.month;
          final int daysInMonth = DateUtils.getDaysInMonth(year, month);

          // Sunday-first grid: DateTime.weekday is 1=Mon … 7=Sun.
          // Map to 0=Sun … 6=Sat offset.
          final int rawWeekday = DateTime(year, month, 1).weekday;
          final int firstDayOffset = rawWeekday == 7 ? 0 : rawWeekday;

          // Total cells = leading blanks + days in month.
          final int totalCells = firstDayOffset + daysInMonth;

          final String selectedLabel =
              selected != null ? _fmt(selected!) : 'No date selected';

          // ── Year-grid page ───────────────────────────────────────────────
          final int yearPageBase = year + yearPageOffset;
          final int yearPageStart = yearPageBase - 6;
          final int yearPageEnd = yearPageBase + 5;

          // ── Overlay Panels (Defined as nested functions for clarity) ─────

          Widget monthOverlay() => _OverlayPanel(
                title: 'Select month',
                onClose: () => setModalState(() => overlay = _PickerOverlay.none),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: 12,
                  itemBuilder: (_, i) => _PickerChip(
                    label: _monthAbbr(i + 1),
                    isActive: i + 1 == month,
                    onTap: () {
                      setModalState(() {
                        focusedDay = DateTime(year, i + 1, 1);
                        overlay = _PickerOverlay.none;
                      });
                    },
                  ),
                ),
              );

          Widget yearOverlay() => _OverlayPanel(
                title: '$yearPageStart – $yearPageEnd',
                showYearNav: true,
                onPrevYear: () => setModalState(() => yearPageOffset -= 12),
                onNextYear: () => setModalState(() => yearPageOffset += 12),
                onClose: () => setModalState(() {
                  overlay = _PickerOverlay.none;
                  yearPageOffset = 0;
                }),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: 12,
                  itemBuilder: (_, i) {
                    final int y = yearPageStart + i;
                    return _PickerChip(
                      label: '$y',
                      isActive: y == year,
                      onTap: () {
                        setModalState(() {
                          focusedDay = DateTime(y, month, 1);
                          yearPageOffset = 0;
                          overlay = _PickerOverlay.none;
                        });
                      },
                    );
                  },
                ),
              );

          Widget calendar() => Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month / year nav row
                    Row(
                      children: [
                        _NavButton(
                          icon: Icons.chevron_left,
                          onTap: () => setModalState(() =>
                              focusedDay = DateTime(year, month - 1, 1)),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _NavPill(
                                label: _monthName(month),
                                onTap: () => setModalState(
                                    () => overlay = _PickerOverlay.month),
                              ),
                              const SizedBox(width: 6),
                              _NavPill(
                                label: '$year',
                                onTap: () => setModalState(
                                    () => overlay = _PickerOverlay.year),
                              ),
                            ],
                          ),
                        ),
                        _NavButton(
                          icon: Icons.chevron_right,
                          onTap: () => setModalState(() =>
                              focusedDay = DateTime(year, month + 1, 1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Selected date display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedLabel,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: selected != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selected != null ? feastBlack : feastGray,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Day-of-week headers (Sunday-first)
                    Row(
                      children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                          .map((d) => Expanded(
                                child: Center(
                                  child: Text(
                                    d,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: feastGray,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 4),

                    // Calendar day grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount: totalCells,
                      itemBuilder: (_, index) {
                        if (index < firstDayOffset) return const SizedBox();
                        final int day = index - firstDayOffset + 1;
                        final DateTime date = DateTime(year, month, day);
                        final bool isToday =
                            DateUtils.isSameDay(date, DateTime.now());
                        final bool isSelected = selected != null &&
                            DateUtils.isSameDay(date, selected);

                        return GestureDetector(
                          onTap: () => setModalState(() => selected = date),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected ? feastBlue : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isToday && !isSelected
                                  ? Border.all(color: feastBlue, width: 1.5)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? feastBlue
                                          : feastBlack,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cancel / Apply buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              side: BorderSide(color: feastGray.withAlpha(80)),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    fontFamily: 'Outfit', color: feastGray)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (selected != null) {
                                controller.text = _fmt(selected!);
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: feastBlue,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Apply',
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

          // ── Final Build ──────────────────────────────────────────────────
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            child: switch (overlay) {
              _PickerOverlay.month => monthOverlay(),
              _PickerOverlay.year => yearOverlay(),
              _PickerOverlay.none => calendar(),
            },
          );
        },
      ),
    );
  }

  // ── Formatting helpers ─────────────────────────────────────────────────────

  static String _fmt(DateTime d) =>
      '${_monthAbbr(d.month)} ${d.day}, ${d.year}';

  static DateTime? _parseControllerDate(String text) {
    try {
      final parts = text.split(' ');
      if (parts.length < 3) return null;
      final int month = _monthAbbrIndex(parts[0]);
      final int day = int.parse(parts[1].replaceAll(',', ''));
      final int year = int.parse(parts[2]);
      if (month == 0) return null;
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  static String _monthName(int m) => const [
        '',
        'January', 'February', 'March', 'April',
        'May', 'June', 'July', 'August',
        'September', 'October', 'November', 'December',
      ][m];

  static String _monthAbbr(int m) => const [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m];

  static int _monthAbbrIndex(String abbr) => const [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ].indexOf(abbr);
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22, color: feastGray),
        ),
      );
}

class _NavPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: feastBlack,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 18, color: feastGray),
            ],
          ),
        ),
      );
}

class _PickerChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _PickerChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: isActive ? feastBlue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? Colors.white : feastBlack,
            ),
          ),
        ),
      );
}

class _OverlayPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onClose;
  final bool showYearNav;
  final VoidCallback? onPrevYear;
  final VoidCallback? onNextYear;

  const _OverlayPanel({
    required this.title,
    required this.child,
    required this.onClose,
    this.showYearNav = false,
    this.onPrevYear,
    this.onNextYear,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (showYearNav)
                  _NavButton(icon: Icons.chevron_left, onTap: onPrevYear!),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: feastBlack,
                    ),
                  ),
                ),
                if (showYearNav)
                  _NavButton(icon: Icons.chevron_right, onTap: onNextYear!),
                _NavButton(icon: Icons.close, onTap: onClose),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}
