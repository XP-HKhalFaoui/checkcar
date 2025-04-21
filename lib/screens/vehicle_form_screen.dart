import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;
  final Function(Vehicle) onSave;

  const VehicleFormScreen({Key? key, this.vehicle, required this.onSave})
      : super(key: key);

  @override
  _VehicleFormScreenState createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _brand;
  late String _model;
  late int _year;
  late int _currentMileage;
  late String _licensePlate;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _brand = widget.vehicle!.brand;
      _model = widget.vehicle!.model;
      _year = widget.vehicle!.year;
      _currentMileage = widget.vehicle!.currentMileage;
      _licensePlate = widget.vehicle!.licensePlate;
    } else {
      _brand = '';
      _model = '';
      _year = DateTime.now().year;
      _currentMileage = 0;
      _licensePlate = '';
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newVehicle = Vehicle(
        id: widget.vehicle?.id ?? DateTime.now().toString(),
        brand: _brand,
        model: _model,
        year: _year,
        currentMileage: _currentMileage,
        licensePlate: _licensePlate,
        ownerId: 'user1', // Example owner ID
      );
      widget.onSave(newVehicle);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _brand,
                decoration: InputDecoration(labelText: 'Brand'),
                onSaved: (value) => _brand = value!,
                validator: (value) => value!.isEmpty ? 'Please enter a brand' : null,
              ),
              TextFormField(
                initialValue: _model,
                decoration: InputDecoration(labelText: 'Model'),
                onSaved: (value) => _model = value!,
                validator: (value) => value!.isEmpty ? 'Please enter a model' : null,
              ),
              TextFormField(
                initialValue: _year.toString(),
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _year = int.parse(value!),
                validator: (value) => value!.isEmpty ? 'Please enter a year' : null,
              ),
              TextFormField(
                initialValue: _currentMileage.toString(),
                decoration: InputDecoration(labelText: 'Current Mileage'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _currentMileage = int.parse(value!),
                validator: (value) => value!.isEmpty ? 'Please enter the current mileage' : null,
              ),
              TextFormField(
                initialValue: _licensePlate,
                decoration: InputDecoration(labelText: 'License Plate'),
                onSaved: (value) => _licensePlate = value!,
                validator: (value) => value!.isEmpty ? 'Please enter a license plate' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
