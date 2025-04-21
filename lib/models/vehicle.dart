class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final int currentMileage;
  final String licensePlate;
  final String imageUrl;
  final String ownerId;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.currentMileage,
    required this.licensePlate,
    this.imageUrl = '',
    required this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'currentMileage': currentMileage,
      'licensePlate': licensePlate,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      currentMileage: map['currentMileage'],
      licensePlate: map['licensePlate'],
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'],
    );
  }
}