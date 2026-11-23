import 'package:flutter/material.dart';
import 'package:websupark/theme/app_colors.dart';

// Small building blocks shared by the driver screens (D2 to D5).
// They live inside the driver folder because only the driver interface uses them.

/// Small gray caps label used above some values, e.g. "YOUR VEHICLE".
const TextStyle driverLabelStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.8,
  color: AppColors.textMuted,
);

/// Screen width at which the driver interface switches from the phone layout
/// (bottom bar, one column) to the wide layout (side menu, two columns).
const double driverWideBreakpoint = 720;

/// Standard page body: scrollable and centered. The side padding and the
/// widest allowed content change with the screen width.
class DriverPage extends StatelessWidget {
  const DriverPage({super.key, required this.children, this.maxWidth = 1000});

  final List<Widget> children;

  /// The widest the content may get. On bigger screens it stays centered.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder tells us the width this page really has.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // very narrow phone: 12, normal phone: 16, tablet or desktop: 24
        final side =
            width < 360 ? 12.0 : (width >= driverWideBreakpoint ? 24.0 : 16.0);
        final contentWidth = (width - 2 * side).clamp(0.0, maxWidth).toDouble();

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(side, 16, side, 24),
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shows [left] and [right] side by side when there is room (a tablet or a
/// desktop window), and stacked, left first, on a phone.
class DriverColumns extends StatelessWidget {
  const DriverColumns({
    super.key,
    required this.left,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.gap = 20,
  });

  final List<Widget> left;
  final List<Widget> right;

  /// How the width is shared between the two columns (1 : 1 by default).
  final int leftFlex;
  final int rightFlex;

  /// Space between the two parts when they are stacked on a phone.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 640) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: leftFlex,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: left,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: rightFlex,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: right,
                ),
              ),
            ],
          );
        }
        // Phone: one column, in the same order as the prototype.
        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [...left, SizedBox(height: gap), ...right],
          ),
        );
      },
    );
  }
}

/// Screen title and subtitle on the left, one icon button on the right.
class DriverHeader extends StatelessWidget {
  const DriverHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onIconTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        DriverIconBox(icon: icon, onTap: onIconTap),
      ],
    );
  }
}

/// Rounded square holding an icon. Pale blue by default.
class DriverIconBox extends StatelessWidget {
  const DriverIconBox({
    super.key,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onTap; // null = not tappable
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.5,
            color: iconColor ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Section title on the left, optional small blue text on the right.
class DriverSectionHeader extends StatelessWidget {
  const DriverSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // The title takes the free space and wraps if it is too long.
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 12),
          // The action text may use at most 160 px, then it wraps.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: GestureDetector(
              onTap: onActionTap,
              child: Text(
                action!,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A label on the left and its value on the right.
/// On a narrow screen, or with big text, the value drops under the label
/// instead of overflowing. Pass [trailing] to show a widget (like a status
/// chip) instead of the value text.
class DriverInfoRow extends StatelessWidget {
  const DriverInfoRow({
    super.key,
    required this.label,
    this.value,
    this.trailing,
  });

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // Wrap only stretches to the full width when it is inside a SizedBox
    // with an infinite width, which is what makes spaceBetween work.
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 2,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          trailing ??
              Text(
                value ?? '',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
        ],
      ),
    );
  }
}

/// Stops very large phone text sizes (an accessibility setting) from
/// breaking the layout. Text can still grow, up to 1.3 times its normal size.
class DriverTextScale extends StatelessWidget {
  const DriverTextScale({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: child,
    );
  }
}
