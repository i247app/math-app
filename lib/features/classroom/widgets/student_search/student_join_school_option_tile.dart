import 'package:flutter/material.dart';

import 'package:numi_flutter/features/classroom/widgets/student_search/student_class_search_style.dart';

class StudentJoinSchoolOptionTile extends StatelessWidget {
  const StudentJoinSchoolOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? studentJoinTeal : studentJoinInk,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_rounded,
                  color: studentJoinTeal,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
