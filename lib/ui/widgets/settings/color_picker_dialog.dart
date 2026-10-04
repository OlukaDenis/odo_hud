import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../core/constants/app_colors.dart';

Future<void> showHudColorPicker({
  required BuildContext context,
  required String title,
  required Color currentColor,
  required ValueChanged<Color> onColorChanged,
  required bool isDark,
}) {
  Color selectedColor = currentColor;

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (dialogCtx, setDialogState) {
        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (newColor) {
                    setDialogState(() {
                      selectedColor = newColor;
                    });
                    onColorChanged(newColor);
                  },
                  enableAlpha: false,
                  displayThumbColor: true,
                  pickerAreaHeightPercent: 0.7,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.defaultSpeedColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Select',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ),
  );
}
