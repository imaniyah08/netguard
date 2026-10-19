import 'package:flutter/material.dart';

const cyan = Color(0xFF29D3FF);
const deepBlue = Color(0xFF0A1B5C);

/// Latar gradasi bertema Cyber Grid.
class CyberBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  const CyberBackground({super.key, required this.child, this.colors});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors ?? const [Color(0xFF0B1450), Color(0xFF050B2E), Color(0xFF1A0B4A)],
          ),
        ),
        child: SafeArea(child: child),
      );
}

/// Panel ber-border neon.
class NeonPanel extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  const NeonPanel({super.key, required this.child, this.color = cyan, this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: deepBlue.withOpacity(.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [BoxShadow(color: color.withOpacity(.35), blurRadius: 12)],
        ),
        child: child,
      );
}

/// Tombol neon (MULAI, JAWAB, LANJUT, dst).
class NeonButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final bool big;
  const NeonButton(this.label, {super.key, this.icon, this.onTap, this.color = cyan, this.big = false});
  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : .45,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: big ? 16 : 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(.85), color.withOpacity(.35)]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white70, width: 1),
            boxShadow: [BoxShadow(color: color.withOpacity(.5), blurRadius: 14)],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: big ? 24 : 20), const SizedBox(width: 8)],
            Text(label,
                style: TextStyle(fontSize: big ? 22 : 16, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ]),
        ),
      ),
    );
  }
}
