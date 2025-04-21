import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import 'vehicle_details_screen.dart';
import '../l10n/app_localizations.dart'; // Import localizations
import 'settings_screen.dart'; // Assuming you have settings screen
import 'vehicle_form_screen.dart'; // Add this import

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
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two cards per row
          childAspectRatio: 1.0, // Square cards
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: demoVehicles.length,
        itemBuilder: (context, index) {
          final vehicle = demoVehicles[index];
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VehicleDetailsScreen(vehicle: vehicle),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.year} - ${vehicle.licensePlate}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: localizations.translate('addVehicleTooltip'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleFormScreen(
                onSave: (newVehicle) {
                  // Here you would typically add the vehicle to your data source
                  // For now, we'll just navigate back
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vehicle added successfully!')),
                  );
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
