enum SignupGender {
  studentMale('student_male'),
  studentFemale('student_female'),
  parentFather('parent_father'),
  parentMother('parent_mother'),
  teacherMale('teacher_male'),
  teacherFemale('teacher_female');

  const SignupGender(this.value);

  final String value;
}
