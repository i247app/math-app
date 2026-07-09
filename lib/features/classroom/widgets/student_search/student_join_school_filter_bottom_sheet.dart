import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/school_models.dart';
import 'package:numi/features/classroom/helpers/student_class_search_helpers.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_school_option_tile.dart';

class StudentJoinSchoolFilterBottomSheet extends StatelessWidget {
  const StudentJoinSchoolFilterBottomSheet({
    super.key,
    required this.schools,
    required this.selectedSchoolIds,
  });

  final List<SchoolModel> schools;
  final Set<int> selectedSchoolIds;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final draftSelectedIds = Set<int>.from(selectedSchoolIds);
    return StatefulBuilder(
      builder: (context, setModalState) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.72,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Text(
                    context.getText(AppKeys.chooseSchool),
                    style: const TextStyle(
                      color: AppColors.textNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(8, 0, 8, bottomInset + 12),
                    children: [
                      StudentJoinSchoolOptionTile(
                        label: context.getText(AppKeys.studentClassAll),
                        selected: draftSelectedIds.isEmpty,
                        onTap: () => setModalState(draftSelectedIds.clear),
                      ),
                      for (final school in schools)
                        StudentJoinSchoolOptionTile(
                          label: studentJoinSchoolName(context, school),
                          selected: draftSelectedIds.contains(
                            schoolStableId(school),
                          ),
                          onTap: () {
                            final schoolId = schoolStableId(school);
                            if (schoolId == null) {
                              return;
                            }
                            setModalState(() {
                              if (!draftSelectedIds.add(schoolId)) {
                                draftSelectedIds.remove(schoolId);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 16),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(draftSelectedIds),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tealActive,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      context.getText(AppKeys.continueUpper),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
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
