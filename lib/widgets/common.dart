import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, required this.onTap, this.icon, this.light = false, this.trailing});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool light;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bg = onTap == null ? AppColors.accentTint : (light ? Colors.white : AppColors.accent);
    final fg = onTap == null ? AppColors.textTertiary : (light ? AppColors.accent : Colors.white);
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, color: fg, size: 20), const SizedBox(width: 8)],
            Text(label, style: AppText.label(color: fg).copyWith(fontSize: 16)),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ]),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, required this.onTap, this.onDark = false, this.icon});
  final String label;
  final VoidCallback onTap;
  final bool onDark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = onDark ? Colors.white : AppColors.accent;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: BorderSide(color: onDark ? Colors.white54 : AppColors.accent, width: 1.5),
          backgroundColor: onDark ? Colors.transparent : Colors.white,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 18, color: c), const SizedBox(width: 8)],
          Text(label, style: AppText.label(color: c).copyWith(fontSize: 16)),
        ]),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.onTap, this.border});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
        border: Border.all(color: border ?? AppColors.border.withValues(alpha: .6), width: border != null ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  const PillChip(this.label, {super.key, this.selected = false, this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.accent;
    return Material(
      color: selected ? AppColors.accent : AppColors.chip,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 6)],
            Text(label, style: AppText.label(color: fg)),
          ]),
        ),
      ),
    );
  }
}

/// Small rounded label, e.g. "ACTIVE NOW" (gold) or "Granted" (green).
class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.bg = AppColors.support, this.fg = AppColors.textPrimary, this.icon});
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Text(label, style: AppText.overline(color: fg).copyWith(fontSize: 11, letterSpacing: .6)),
        ]),
      );
}

class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.values, required this.value, required this.label, required this.onChanged});
  final List<T> values;
  final T value;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final v in values)
          GestureDetector(
            key: Key('seg-${label(v)}'),
            onTap: () => onChanged(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
              decoration: BoxDecoration(color: v == value ? AppColors.accent : Colors.transparent, borderRadius: BorderRadius.circular(999)),
              child: Text(label(v), style: AppText.label(color: v == value ? Colors.white : AppColors.textSecondary)),
            ),
          ),
      ]),
    );
  }
}

class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.size = 48, this.bg = AppColors.surfaceAlt, this.fg = AppColors.accent});
  final IconData icon;
  final double size;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, size: size * .46, color: fg),
      );
}

/// Brand-colored rounded tile for a third-party app (Instagram, TikTok...).
class AppTile extends StatelessWidget {
  const AppTile({super.key, required this.icon, required this.colors, this.size = 44});
  final IconData icon;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(size * .28),
        ),
        child: Icon(icon, color: Colors.white, size: size * .5),
      );
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.value, required this.size, this.stroke = 8, this.track = AppColors.accentTint, this.color = AppColors.support, this.child});
  final double value;
  final double size;
  final double stroke;
  final Color track;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(value, stroke, track, color),
          child: Center(child: child),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.track, this.color);
  final double value, stroke;
  final Color track, color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    if (value > 0) canvas.drawArc(r, -math.pi / 2, math.pi * 2 * value, false, p..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.value != value || o.color != color;
}

class LinearBar extends StatelessWidget {
  const LinearBar({super.key, required this.value, this.height = 8, this.color = AppColors.accent, this.gradient});
  final double value;
  final double height;
  final Color color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: SizedBox(
          height: height,
          child: Stack(children: [
            Container(color: const Color(0xFFF1E6F0)),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: Container(decoration: BoxDecoration(color: gradient == null ? color : null, gradient: gradient, borderRadius: BorderRadius.circular(height))),
            ),
          ]),
        ),
      );
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 52, this.dot = false});
  final double size;
  final bool dot;

  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: AppShadows.card),
          child: ClipOval(child: Image.asset('assets/images/avatar-maya.jpg', fit: BoxFit.cover)),
        ),
        if (dot)
          Positioned(
            right: 0,
            bottom: 2,
            child: Container(
              width: size * .24,
              height: size * .24,
              decoration: BoxDecoration(color: AppColors.support, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            ),
          ),
      ]);
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.title, this.onBack, this.trailing, this.center = true});
  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool center;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        child: Row(children: [
          if (onBack != null)
            IconButton(key: const Key('back'), onPressed: onBack, icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary))
          else
            const SizedBox(width: 48),
          Expanded(
            child: title == null
                ? const SizedBox()
                : Text(title!, textAlign: center ? TextAlign.center : TextAlign.start, style: AppText.title(size: 18), overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 48, child: trailing),
        ]),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.badge});
  final String title;
  final String? badge;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: Row(children: [
          Text(title, style: AppText.title()),
          if (badge != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(999)),
              child: Text(badge!, style: AppText.caption(color: AppColors.textSecondary).copyWith(fontWeight: FontWeight.w700)),
            ),
          ],
          const Spacer(),
          ?trailing,
        ]),
      );
}

class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.step, required this.of});
  final int step, of;

  @override
  Widget build(BuildContext context) => Column(children: [
        Text('STEP $step OF $of', style: AppText.overline(color: AppColors.textTertiary)),
        const SizedBox(height: 8),
        SizedBox(width: 120, child: LinearBar(value: step / of, height: 4)),
      ]);
}
