import 'package:flutter/material.dart';

/// Define los dos estilos disponibles para el chip.
enum RoutineCategoryChipType { clean, crystal }

/// Widget reutilizable para mostrar una categoría de rutina.
class RoutineCategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final RoutineCategoryChipType type;
  final bool selected;
  final bool shadow;
  final ValueChanged<bool>? onSelected;
  final double? width;

  const RoutineCategoryChip({
    Key? key,
    required this.label,
    required this.color,
    this.type = RoutineCategoryChipType.crystal,
    this.selected = false,
    this.shadow = false,
    this.onSelected,
    this.width,
  }) : super(key: key);

  RoutineCategoryChipType get crystal => RoutineCategoryChipType.crystal;
  RoutineCategoryChipType get clean => RoutineCategoryChipType.clean;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = selected
        ? color
        : type == RoutineCategoryChipType.clean
        ? Colors.white
        : (color as MaterialColor)[50]!;
    final Color labelColor = selected
        ? Colors.white
        : type == RoutineCategoryChipType.clean
        ? (color as MaterialColor)[600]!
        : (color as MaterialColor)[800]!;

    final bool rippleEnabled = onSelected != null;

    final Widget chipContainer = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadow
          ? [
              BoxShadow(
                color: color,
                blurRadius: 64,
                spreadRadius: 10,
              ),
            ]
          : null,
      ),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected ?? (_) {},
        backgroundColor: backgroundColor,
        selectedColor: color,
        disabledColor: backgroundColor,
        labelStyle: TextStyle(
          color: labelColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(
          side: BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
        ),
        elevation: 0,
        pressElevation: 0,
        selectedShadowColor: color,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        showCheckmark: false,
        visualDensity: const VisualDensity(
          vertical: -2,
        ),
      ),
    );

    final chip = width is double
      ? SizedBox(
        width: width,
        child: chipContainer,
      )
      : chipContainer;

    if (!rippleEnabled) {
      return Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: chip,
      );
    }

    return chip;
  }
}
