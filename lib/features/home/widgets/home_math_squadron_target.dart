part of '../home_screen.dart';

class _HomeMathSquadronTarget extends StatelessWidget {
  const _HomeMathSquadronTarget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFF625F),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x99FF625F), blurRadius: 14),
        ],
      ),
      child: const Center(
        child: Text(
          '× 7',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
