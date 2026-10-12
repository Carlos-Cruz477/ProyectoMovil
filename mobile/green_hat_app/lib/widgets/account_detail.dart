import 'package:flutter/material.dart';
import '../main.dart';

class AccountDetail extends StatelessWidget {
  const AccountDetail({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F6F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: forest, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(
                color: valueColor ?? ink, fontWeight: FontWeight.w700, fontSize: 14,
              )),
            ],
          ),
        ),
      ],
    );
  }
}
