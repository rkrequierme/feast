import 'package:flutter/material.dart';

class DatePickerModal {
  static Future<void> show({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    DateTime focusedDay = DateTime.now();
    DateTime? selectedStart;
    DateTime? selectedEnd;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final daysInMonth = DateUtils.getDaysInMonth(focusedDay.year, focusedDay.month);
          final firstDayOffset = DateTime(focusedDay.year, focusedDay.month, 1).weekday % 7;

          String fmt(DateTime d) => "${_monthAbbr(d.month)} ${d.day}, ${d.year}";

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Month nav
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setModalState(() {
                          focusedDay = DateTime(focusedDay.year, focusedDay.month - 1);
                        }),
                      ),
                      Text(
                        "${_monthName(focusedDay.month)} ${focusedDay.year}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: "Outfit",
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setModalState(() {
                          focusedDay = DateTime(focusedDay.year, focusedDay.month + 1);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Range display
                  Row(
                    children: [
                      Expanded(child: _rangeBox(selectedStart != null ? fmt(selectedStart!) : "Start date", selectedStart != null)),
                      const SizedBox(width: 8),
                      Expanded(child: _rangeBox(selectedEnd != null ? fmt(selectedEnd!) : "End date", selectedEnd != null)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Day headers
                  Row(
                    children: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(d,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Outfit",
                                      color: Colors.grey,
                                    )),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  // Calendar grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: firstDayOffset + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < firstDayOffset) return const SizedBox();
                      final day = index - firstDayOffset + 1;
                      final date = DateTime(focusedDay.year, focusedDay.month, day);
                      final isStart = selectedStart != null && DateUtils.isSameDay(date, selectedStart);
                      final isEnd = selectedEnd != null && DateUtils.isSameDay(date, selectedEnd);
                      final inRange = selectedStart != null &&
                          selectedEnd != null &&
                          date.isAfter(selectedStart!) &&
                          date.isBefore(selectedEnd!);
                      final isSelected = isStart || isEnd;

                      return GestureDetector(
                        onTap: () => setModalState(() {
                          if (selectedStart == null || (selectedStart != null && selectedEnd != null)) {
                            selectedStart = date;
                            selectedEnd = null;
                          } else {
                            if (date.isBefore(selectedStart!)) {
                              selectedEnd = selectedStart;
                              selectedStart = date;
                            } else {
                              selectedEnd = date;
                            }
                          }
                        }),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue
                                : inRange
                                    ? Colors.blue.withAlpha(30)
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "$day",
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: "Outfit",
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Cancel", style: TextStyle(fontFamily: "Outfit")),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedStart != null) {
                              controller.text = selectedEnd != null
                                  ? "${fmt(selectedStart!)} – ${fmt(selectedEnd!)}"
                                  : fmt(selectedStart!);
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Apply",
                              style: TextStyle(fontFamily: "Outfit", color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _rangeBox(String text, bool hasValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontFamily: "Outfit",
          color: hasValue ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  static String _monthName(int m) => const [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][m];

  static String _monthAbbr(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];
}
