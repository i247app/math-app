part of '../../presentation/teacher_classroom_screens.dart';

class _ClassFunctionTile extends StatelessWidget {
  const _ClassFunctionTile({
    required this.scale,
    this.iconAsset,
    this.label,
    this.onTap,
  });

  final double scale;
  final String? iconAsset;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16 * scale);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: const Color(0xFFDDE4E6),
              width: 2 * scale,
            ),
          ),
          child: iconAsset == null
              ? const SizedBox.shrink()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      iconAsset!,
                      width: 44 * scale,
                      height: 44 * scale,
                    ),
                    SizedBox(height: 1 * scale),
                    Text(
                      label ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.andika(
                        color: _teacherInk,
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
