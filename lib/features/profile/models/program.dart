class ProgramModel {
  const ProgramModel({
    this.id,
    this.programId,
    this.label,
    this.description,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  final int? id;
  final int? programId;
  final String? label;
  final String? description;
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;
}
