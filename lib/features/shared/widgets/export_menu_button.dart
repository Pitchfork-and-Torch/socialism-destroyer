import 'package:flutter/material.dart';

/// Compact share/export menu used across screens.
class ExportMenuButton extends StatelessWidget {
  const ExportMenuButton({
    super.key,
    required this.onShare,
    this.onExportPdf,
    this.onExportPng,
    this.tooltip = 'Share & export',
  });

  final VoidCallback onShare;
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportPng;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final hasExport = onExportPdf != null || onExportPng != null;
    if (!hasExport) {
      return IconButton(
        icon: const Icon(Icons.ios_share_rounded),
        tooltip: 'Share',
        onPressed: onShare,
      );
    }

    return PopupMenuButton<String>(
      tooltip: tooltip,
      icon: const Icon(Icons.ios_share_rounded),
      onSelected: (value) {
        switch (value) {
          case 'share':
            onShare();
          case 'pdf':
            onExportPdf?.call();
          case 'png':
            onExportPng?.call();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'share', child: Text('Share text')),
        if (onExportPdf != null)
          const PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
        if (onExportPng != null)
          const PopupMenuItem(value: 'png', child: Text('Export image')),
      ],
    );
  }
}