class SchoolModel {
  const SchoolModel({
    this.id,
    this.schoolId,
    this.name,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  final int? id;
  final int? schoolId;
  final String? name;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;
}
