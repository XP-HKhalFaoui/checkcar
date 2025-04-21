enum LifespanUnit { kilometers, months }

class Part {
  final String id;
  final String vehicleId;
  final String name;
  final int expectedLifespan;
  final LifespanUnit lifeSpanUnit;
  final DateTime installationDate;
  final int installationMileage;
  final DateTime? lastReplacementDate;
  final int? lastReplacementMileage;

  Part({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.expectedLifespan,
    required this.lifeSpanUnit,
    required this.installationDate,
    required this.installationMileage,
    this.lastReplacementDate,
    this.lastReplacementMileage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'name': name,
      'expectedLifespan': expectedLifespan,
      'lifeSpanUnit': lifeSpanUnit.toString(),
      'installationDate': installationDate.millisecondsSinceEpoch,
      'installationMileage': installationMileage,
      'lastReplacementDate': lastReplacementDate?.millisecondsSinceEpoch,
      'lastReplacementMileage': lastReplacementMileage,
    };
  }

  factory Part.fromMap(Map<String, dynamic> map) {
    return Part(
      id: map['id'],
      vehicleId: map['vehicleId'],
      name: map['name'],
      expectedLifespan: map['expectedLifespan'],
      lifeSpanUnit: LifespanUnit.values.firstWhere(
          (e) => e.toString() == map['lifeSpanUnit'],
          orElse: () => LifespanUnit.kilometers),
      installationDate:
          DateTime.fromMillisecondsSinceEpoch(map['installationDate']),
      installationMileage: map['installationMileage'],
      lastReplacementDate: map['lastReplacementDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReplacementDate'])
          : null,
      lastReplacementMileage: map['lastReplacementMileage'],
    );
  }

  double get lifePercentageRemaining {
    if (lifeSpanUnit == LifespanUnit.kilometers) {
      final usedLifespan = lastReplacementMileage != null
          ? lastReplacementMileage! - installationMileage
          : 0;
      return (expectedLifespan - usedLifespan) / expectedLifespan * 100;
    } else {
      final installDate = lastReplacementDate ?? installationDate;
      final monthsPassed =
          DateTime.now().difference(installDate).inDays / 30;
      return (expectedLifespan - monthsPassed) / expectedLifespan * 100;
    }
  }
}