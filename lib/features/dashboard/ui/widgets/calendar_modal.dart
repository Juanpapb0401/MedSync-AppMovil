import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';

class CalendarModal extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarModal({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarModal> createState() => _CalendarModalState();
}

class _CalendarModalState extends State<CalendarModal> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool _isFutureDate(DateTime date) {
    final today = DateTime.now();
    return date.year > today.year ||
        (date.year == today.year && date.month > today.month) ||
        (date.year == today.year && date.month == today.month && date.day > today.day);
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final offset = firstDay.weekday - 1;
    final days = <DateTime>[];

    for (int i = 0; i < offset; i++) {
      days.add(firstDay.subtract(Duration(days: offset - i)));
    }

    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, day));
    }

    return days;
  }

  String _monthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final today = DateTime.now();

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                  onPressed: _previousMonth,
                ),
                Text(
                  '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.1,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isCurrentMonth = day.month == _currentMonth.month;
                final isSelected = day.year == widget.selectedDate.year &&
                    day.month == widget.selectedDate.month &&
                    day.day == widget.selectedDate.day;
                final isFuture = _isFutureDate(day);
                final isToday = day.year == today.year &&
                    day.month == today.month &&
                    day.day == today.day;

                return GestureDetector(
                  onTap: isFuture || !isCurrentMonth
                      ? null
                      : () {
                          widget.onDateSelected(day);
                          Navigator.of(context).pop();
                        },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : null,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : isFuture || !isCurrentMonth
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
