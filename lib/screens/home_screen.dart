import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import 'vehicle_details_screen.dart';
import '../l10n/app_localizations.dart'; // Import localizations
import 'settings_screen.dart'; // Assuming you have settings screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // This would eventually come from a database
    final List<Vehicle> demoVehicles = [
      Vehicle(
        id: '1',
        brand: 'Toyota',
        model: 'Corolla',
        year: 2019,
        currentMileage: 45000,
        licensePlate: '123 ABC',
        ownerId: 'user1',
      ),
      Vehicle(
        id: '2',
        brand: 'Honda',
        model: 'Civic',
        year: 2020,
        currentMileage: 30000,
        licensePlate: '456 DEF',
        ownerId: 'user1',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('appTitle')),
        actions: [
          IconButton(
            tooltip: localizations.translate('settingsTitle'),
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: demoVehicles.length,
        itemBuilder: (context, index) {
          final vehicle = demoVehicles[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('${vehicle.brand} ${vehicle.model}'),
              subtitle: Text('${vehicle.year} - ${vehicle.licensePlate}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VehicleDetailsScreen(vehicle: vehicle),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: localizations.translate('addVehicleTooltip'),
        onPressed: () {
          // Navigate to add vehicle screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
