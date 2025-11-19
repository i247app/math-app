import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/class_item_data.dart';

class ClassCard extends StatefulWidget {
  final ClassItemData data;
  final bool isSelected;
  final VoidCallback? onTap;
  final double selectionAnimation;

  const ClassCard({
    super.key,
    required this.data,
    this.isSelected = false,
    this.onTap,
    this.selectionAnimation = 0.0,
  });

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _tapController.reverse();
  }

  void _handleTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tapController,
      builder: (context, child) {
        return Transform.scale(
          scale: _tapAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The Main Colored Card
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.data.color,
                      borderRadius: BorderRadius.circular(12),
                      border: widget.isSelected
                          ? Border.all(color: const Color(0xFF3E2723), width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: widget.isSelected
                              ? const Color(
                                  0xFF3E2723,
                                ).withAlpha((255 * 0.3).round())
                              : Colors.grey.withAlpha((255 * 0.2).round()),
                          blurRadius: widget.isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                          spreadRadius: widget.isSelected ? 2 : 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image
                            Expanded(
                              child: AnimatedOpacity(
                                opacity: widget.isSelected ? 1.0 : 0.8,
                                duration: const Duration(milliseconds: 200),
                                child: Image.asset(
                                  widget.data.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white54,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Text
                            Text(
                              widget.data.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: widget.isSelected
                                    ? Colors.black
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        // Selection checkmark
                        if (widget.isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: AnimatedOpacity(
                              opacity: widget.selectionAnimation,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        // Badge for special classes
                        if (widget.data.hasBadge)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "HOT",
                                style: GoogleFonts.nunito(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
