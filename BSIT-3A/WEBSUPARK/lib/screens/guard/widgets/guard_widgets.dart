import 'package:flutter/material.dart';
import 'package:websupark/theme/app_colors.dart';

/// Monospace style used for plates, space codes and reference numbers.
const TextStyle monoStyle = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.w700,
  color: AppColors.textPrimary,
);

/// White 44x44 rounded button used in screen headers.
class SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const SquareIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.border),
    );
    return Material(
      color: AppColors.surface,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}

/// Back button + small eyebrow label + title + optional trailing button.
class ScreenHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final bool showBack;
  final IconData? trailingIcon;
  final VoidCallback? onTrailing;

  const ScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.showBack = true,
    this.trailingIcon,
    this.onTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          SquareIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (trailingIcon != null)
          SquareIconButton(icon: trailingIcon!, onTap: onTrailing),
      ],
    );
  }
}

/// Small uppercase caption ("VEHICLE", "ASSIGNED SPACE", ...).
class CaptionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const CaptionLabel(this.text, {super.key, this.color = AppColors.textMuted});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: color,
      ),
    );
  }
}

/// White bordered card with an optional bold title (and trailing widget).
class SectionCard extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;

  const SectionCard({super.key, this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

/// "Label ........ value" row used in the record and review cards.
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const DetailRow(this.label, this.value, {super.key, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueStyle ??
                  const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Action area pinned to the bottom of a mobile screen.
/// Use it as `Scaffold(bottomNavigationBar: BottomActionBar(child: ...))`.
class BottomActionBar extends StatelessWidget {
  final Widget child;

  const BottomActionBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: child,
        ),
      ),
    );
  }
}

/// Header of the guard screens, in the prototype style: square white back
/// button, small caption above the title, square white action buttons.
/// Used as `Scaffold(appBar: GuardAppBar(...))`. Tab screens pass showBack: false.
class GuardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> actions; // usually SquareIconButton

  const GuardAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final canGoBack = showBack && (ModalRoute.of(context)?.canPop ?? false);

    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              if (canGoBack) ...[
                SquareIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              for (final a in actions) ...[const SizedBox(width: 8), a],
            ],
          ),
        ),
      ),
    );
  }
}

/// Body of a flow screen, as in the prototype: the content scrolls, and the
/// main button(s) come right under it. When the content is short, the button
/// sits at the bottom of the screen; when it is long, it scrolls with it.
/// (Uses a minimum height instead of measuring the content, so it never
/// causes "bottom overflowed" warnings.)
class ScreenBody extends StatelessWidget {
  final List<Widget> children;
  final Widget? bottom;

  const ScreenBody({super.key, required this.children, this.bottom});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight =
            (constraints.maxHeight - 32).clamp(0.0, double.infinity).toDouble();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
                if (bottom != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: bottom,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}