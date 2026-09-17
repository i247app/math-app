class SemesterModel {
  const SemesterModel({
    this.id,
    this.semesterId,
    this.name,
    this.description,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  final int? id;
  final int? semesterId;
  final String? name;
  final String? description;
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;
}
