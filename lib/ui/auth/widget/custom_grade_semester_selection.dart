import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/data/providers/grades_provider.dart';
import 'package:math_ai_app/data/providers/levels_provider.dart';
import 'package:provider/provider.dart';

class GradeSemesterSelectionWidget extends StatelessWidget {
  final String? selectedGradeId;
  final String? selectedSemesterId;
  final String? gradeError;
  final String? semesterError;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onSemesterChanged;

  const GradeSemesterSelectionWidget({
    super.key,
    required this.selectedGradeId,
    required this.selectedSemesterId,
    required this.gradeError,
    required this.semesterError,
    required this.onGradeChanged,
    required this.onSemesterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'Lớp học:',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((255 * 0.1).round()),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Consumer<GradesProvider>(
                  builder: (context, gradesProvider, child) {
                    if (gradesProvider.isLoading) {
                      return Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: selectedGradeId,
                      decoration: InputDecoration(
                        hintText: 'Chọn lớp',
                        hintStyle: GoogleFonts.nunito(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.school_outlined,
                          color: Color(0xFFFFC107),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFC107),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      items:
                          gradesProvider.grades?.map((grade) {
                            return DropdownMenuItem<String>(
                              value: grade.id,
                              child: Text(
                                grade.label,
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList() ??
                          [],
                      onChanged: onGradeChanged,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFFFFC107),
                      ),
                      dropdownColor: Colors.white,
                    );
                  },
                ),
              ),
              if (gradeError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, top: 4.0),
                  child: Text(
                    gradeError!,
                    style: GoogleFonts.nunito(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'Học kỳ:',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((255 * 0.1).round()),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Consumer<LevelsProvider>(
                  builder: (context, levelsProvider, child) {
                    if (levelsProvider.isLoading) {
                      return Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: selectedSemesterId,
                      decoration: InputDecoration(
                        hintText: 'Chọn học kỳ',
                        hintStyle: GoogleFonts.nunito(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.calendar_view_month_outlined,
                          color: Color(0xFFFFC107),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFC107),
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                      ),
                      items:
                          levelsProvider.levels?.map((level) {
                            return DropdownMenuItem<String>(
                              value: level.id,
                              child: Text(
                                level.label,
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList() ??
                          [],
                      onChanged: onSemesterChanged,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFFFFC107),
                      ),
                      dropdownColor: Colors.white,
                    );
                  },
                ),
              ),
              if (semesterError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, top: 4.0),
                  child: Text(
                    semesterError!,
                    style: GoogleFonts.nunito(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
