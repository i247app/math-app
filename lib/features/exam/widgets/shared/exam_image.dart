import 'package:flutter/material.dart';

/// Image URLs are transient. The enclosing exam controller refreshes them.
class ExamImage extends StatelessWidget {
  const ExamImage({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: Image.network(
          url!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
