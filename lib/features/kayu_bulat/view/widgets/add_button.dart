import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const AddButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color(0xFF8B5A3C).withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        icon: Icon(icon, color: const Color(0xFF8B5A3C)),
        label: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B5A3C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
