class InspectionItem {
  final String name;
  final bool passed;
  final String? notes;

  InspectionItem({
    required this.name,
    required this.passed,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'passed': passed,
      'notes': notes,
    };
  }

  factory InspectionItem.fromMap(Map<String, dynamic> map) {
    return InspectionItem(
      name: map['name'],
      passed: map['passed'],
      notes: map['notes'],
    );
  }
}

class Inspection {
  final String id;
  final String vehicleId;
  final DateTime date;
  final int mileage;
  final String inspector;
  final List<InspectionItem> items;
  final List<String>? photoUrls;
  final String? pdfUrl;

  Inspection({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.mileage,
    required this.inspector,
    required this.items,
    this.photoUrls,
    this.pdfUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.millisecondsSinceEpoch,
      'mileage': mileage,
      'inspector': inspector,
      'items': items.map((item) => item.toMap()).toList(),
      'photoUrls': photoUrls,
      'pdfUrl': pdfUrl,
    };
  }

  factory Inspection.fromMap(Map<String, dynamic> map) {
    return Inspection(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      mileage: map['mileage'],
      inspector: map['inspector'],
      items: List<InspectionItem>.from(
          map['items']?.map((x) => InspectionItem.fromMap(x))),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      pdfUrl: map['pdfUrl'],
    );
  }
}