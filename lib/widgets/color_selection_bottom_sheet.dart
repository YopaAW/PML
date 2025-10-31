import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers/color_palette_provider.dart';

class ColorSelectionBottomSheet extends ConsumerWidget {
  const ColorSelectionBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPalette = ref.watch(colorPaletteProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pilih Skema Warna', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20.0,
            runSpacing: 20.0,
            children: AppColorPalette.palettes.map((palette) {
              return InkWell(
                onTap: () => ref.read(colorPaletteProvider.notifier).setColorPalette(palette),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: palette.primaryColor,
                      child: selectedPalette.name == palette.name
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(palette.name, style: theme.textTheme.bodyMedium),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
