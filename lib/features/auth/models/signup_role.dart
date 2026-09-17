enum SignupRole {
  student('STUDENT'),
  parent('PARENT'),
  teacher('TEACHER');

  const SignupRole(this.apiValue);

  final String apiValue;
}
