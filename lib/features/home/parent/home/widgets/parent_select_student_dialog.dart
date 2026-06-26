part of '../../../home_screen.dart';

class _ParentSelectStudentDialog extends StatelessWidget {
  const _ParentSelectStudentDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: 303,
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.42),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 155,
                      height: 155,
                      decoration: BoxDecoration(
                        color: const Color(0xFFAA2A6C).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFAA2A6C).withValues(alpha: 0.14),
                            blurRadius: 26,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      _parentNoStudentMascot,
                      width: 176,
                      height: 158,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  context.getText(AppKeys.parentNoStudentTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF001741),
                    fontSize: FontSize.xxxl,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.getText(AppKeys.parentSelectStudentMessage),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF444650),
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      _ParentProfileDialogAction.choose,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFAA2A6C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.getText(AppKeys.parentSwitchStudentAction),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(
                      _ParentProfileDialogAction.create,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFAA2A6C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      context.getText(AppKeys.parentCreateStudent),
                      style: const TextStyle(
                        color: Color(0xFFAA2A6C),
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
