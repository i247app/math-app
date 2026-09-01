import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';

class TeacherExerciseCopy {
  const TeacherExerciseCopy({
    required this.titleKey,
    required this.createdTitleKey,
    required this.listLoadFailedKey,
    required this.detailLoadFailedKey,
    required this.createFailedKey,
    required this.emptyKey,
    required this.createTitleKey,
    required this.createdMessageKey,
    required this.titleHintKey,
    required this.titleRequiredKey,
    required this.descriptionHintKey,
  });

  final String titleKey;
  final String createdTitleKey;
  final String listLoadFailedKey;
  final String detailLoadFailedKey;
  final String createFailedKey;
  final String emptyKey;
  final String createTitleKey;
  final String createdMessageKey;
  final String titleHintKey;
  final String titleRequiredKey;
  final String descriptionHintKey;
}

TeacherExerciseCopy teacherExerciseCopy(String purpose) {
  if (purpose.trim().toUpperCase() == classroomExercisePurposeExam) {
    return const TeacherExerciseCopy(
      titleKey: AppKeys.teacherAssessments,
      createdTitleKey: AppKeys.teacherCreatedAssessments,
      listLoadFailedKey: AppKeys.teacherAssessmentListLoadFailed,
      detailLoadFailedKey: AppKeys.teacherAssessmentDetailLoadFailed,
      createFailedKey: AppKeys.teacherAssessmentCreateFailed,
      emptyKey: AppKeys.teacherNoAssessments,
      createTitleKey: AppKeys.teacherCreateAssessmentTitle,
      createdMessageKey: AppKeys.teacherAssessmentCreated,
      titleHintKey: AppKeys.teacherAssessmentTitleHint,
      titleRequiredKey: AppKeys.teacherAssessmentTitleRequired,
      descriptionHintKey: AppKeys.teacherAssessmentDescriptionHint,
    );
  }

  return const TeacherExerciseCopy(
    titleKey: AppKeys.teacherAssignments,
    createdTitleKey: AppKeys.teacherCreatedAssignments,
    listLoadFailedKey: AppKeys.teacherAssignmentListLoadFailed,
    detailLoadFailedKey: AppKeys.teacherAssignmentDetailLoadFailed,
    createFailedKey: AppKeys.teacherAssignmentCreateFailed,
    emptyKey: AppKeys.teacherNoAssignments,
    createTitleKey: AppKeys.teacherCreateAssignmentTitle,
    createdMessageKey: AppKeys.teacherAssignmentCreated,
    titleHintKey: AppKeys.teacherAssignmentTitleHint,
    titleRequiredKey: AppKeys.teacherAssignmentTitleRequired,
    descriptionHintKey: AppKeys.teacherAssignmentDescriptionHint,
  );
}
