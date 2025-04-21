enum DocumentType { insurance, registration, technicalInspection, vignette }

class Document {
  final String id;
  final String vehicleId;
  final DocumentType type;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String documentNumber;
  final String? fileUrl;

  Document({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.issueDate,
    required this.expiryDate,
    required this.documentNumber,
    this.fileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'type': type.toString(),
      'issueDate': issueDate.millisecondsSinceEpoch,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'documentNumber': documentNumber,
      'fileUrl': fileUrl,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      vehicleId: map['vehicleId'],
      type: DocumentType.values.firstWhere(
          (e) => e.toString() == map['type'],
          orElse: () => DocumentType.insurance),
      issueDate: DateTime.fromMillisecondsSinceEpoch(map['issueDate']),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      documentNumber: map['documentNumber'],
      fileUrl: map['fileUrl'],
    );
  }

  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }
}