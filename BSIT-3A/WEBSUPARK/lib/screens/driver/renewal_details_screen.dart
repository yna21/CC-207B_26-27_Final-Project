import 'package:flutter/material.dart';
import 'package:websupark/routes/app_routes.dart';
import 'package:websupark/screens/driver/driver_common.dart';
import 'package:websupark/screens/driver/renewal_common.dart';
import 'package:websupark/theme/app_colors.dart';

const List<String> _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

// Turns a DateTime into text like "March 31, 2027".
String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// Renewal step 2 of 3: where to pay and the preferred visit date.
/// The cashier is open Monday to Friday, so weekends cannot be picked.
class RenewalDetailsScreen extends StatefulWidget {
  const RenewalDetailsScreen({super.key});

  @override
  State<RenewalDetailsScreen> createState() => _RenewalDetailsScreenState();
}

class _RenewalDetailsScreenState extends State<RenewalDetailsScreen> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _visitDate;
  String? _error; // shown under the field when no date is chosen

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // The first date offered must be a weekday, or the picker rejects it.
    var first = today;
    while (first.weekday > DateTime.friday) {
      first = first.add(const Duration(days: 1));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? first,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      selectableDayPredicate: (day) => day.weekday <= DateTime.friday,
    );

    if (picked != null) {
      setState(() {
        _visitDate = picked;
        _dateController.text = _formatDate(picked);
        _error = null;
      });
    }
  }

  void _review() {
    if (_visitDate == null) {
      setState(() => _error = 'Please choose a visit date.');
      return;
    }
    Navigator.pushNamed(context, AppRoutes.driverRenewalReview);
  }

  @override
  Widget build(BuildContext context) {
    return RenewalScaffold(
      title: 'Vehicle Pass Renewal',
      subtitle: 'Step 2 of 3',
      icon: Icons.refresh,
      step: 2,
      children: [
        const RenewalHeading(
          title: 'Admin payment details',
          subtitle: 'Confirm your visit details before submitting.',
        ),
        const SizedBox(height: 18),
        // Two columns on a wide screen, one column (same order) on a phone.
        DriverColumns(
          gap: 18,
          left: const [_VisitCard()],
          right: [
            const Text(
              'Preferred visit date',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _dateController,
              readOnly: true, // the date comes from the picker, not the keyboard
              onTap: _pickDate,
              decoration: InputDecoration(
                hintText: 'Select a date',
                errorText: _error,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 14),
            const _WhatToBring(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _review,
                child: const Text('Review renewal'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// White card: payment location and office hours.
class _VisitCard extends StatelessWidget {
  const _VisitCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            _VisitLine(
              icon: Icons.location_on_outlined,
              label: 'Payment location',
              value: 'Admin Cashier',
            ),
            Divider(height: 24, color: AppColors.border),
            _VisitLine(
              icon: Icons.schedule,
              label: 'Office hours',
              value: 'Mon–Fri, 8:00 AM–5:00 PM',
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitLine extends StatelessWidget {
  const _VisitLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pale blue reminder of what to bring to the cashier.
class _WhatToBring extends StatelessWidget {
  const _WhatToBring();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.help_outline, size: 18, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What to bring',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your current vehicle pass, valid ID, and $renewalFee payment.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
