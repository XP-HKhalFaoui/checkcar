import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/part.dart';

class PartDetailScreen extends StatefulWidget {
  final Part part;
  final Function(Part) onUpdate;

  const PartDetailScreen({
    Key? key,
    required this.part,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _PartDetailScreenState createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  late Part _part;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _part = widget.part;
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentRemaining = _part.lifePercentageRemaining;
    final lifeSpanText = _part.lifeSpanUnit == LifespanUnit.kilometers
        ? '${_part.expectedLifespan} km'
        : '${_part.expectedLifespan} months';

    return Scaffold(
      appBar: AppBar(
        title: Text(_part.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Part status card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expected Lifespan: $lifeSpanText'),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: percentRemaining / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  percentRemaining > 70
                                      ? Colors.green
                                      : percentRemaining > 30
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                                minHeight: 10,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${percentRemaining.toStringAsFixed(0)}% remaining',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: percentRemaining > 70
                                      ? Colors.green
                                      : percentRemaining > 30
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: percentRemaining > 70
                              ? Colors.green
                              : percentRemaining > 30
                                  ? Colors.orange
                                  : Colors.red,
                          child: Icon(
                            percentRemaining > 70
                                ? Icons.check_circle
                                : percentRemaining > 30
                                    ? Icons.warning
                                    : Icons.error,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Installation details
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Installation Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Installation Date', _dateFormat.format(_part.installationDate)),
                    _buildInfoRow('Installation Mileage', '${_part.installationMileage} km'),
                    if (_part.lastReplacementDate != null)
                      _buildInfoRow('Last Replacement', _dateFormat.format(_part.lastReplacementDate!)),
                    if (_part.lastReplacementMileage != null)
                      _buildInfoRow('Replacement Mileage', '${_part.lastReplacementMileage} km'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('View History'),
                  onPressed: () {
                    // Show replacement history
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.autorenew),
                  label: const Text('Record Replacement'),
                  onPressed: _showReplacementDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final TextEditingController nameController = TextEditingController(text: _part.name);
    final TextEditingController lifespanController = TextEditingController(text: _part.expectedLifespan.toString());
    LifespanUnit selectedUnit = _part.lifeSpanUnit;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Part'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Part Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lifespanController,
                decoration: const InputDecoration(
                  labelText: 'Expected Lifespan',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<LifespanUnit>(
                value: selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Lifespan Unit',
                ),
                items: LifespanUnit.values.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit == LifespanUnit.kilometers ? 'Kilometers' : 'Months'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedUnit = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Update part with new values
              final updatedPart = Part(
                id: _part.id,
                vehicleId: _part.vehicleId,
                name: nameController.text,
                expectedLifespan: int.tryParse(lifespanController.text) ?? _part.expectedLifespan,
                lifeSpanUnit: selectedUnit,
                installationDate: _part.installationDate,
                installationMileage: _part.installationMileage,
                lastReplacementDate: _part.lastReplacementDate,
                lastReplacementMileage: _part.lastReplacementMileage,
              );
              
              setState(() {
                _part = updatedPart;
              });
              
              widget.onUpdate(updatedPart);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showReplacementDialog() {
    final currentDate = DateTime.now();
    _mileageController.text = '';
    _notesController.text = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Replacement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${_dateFormat.format(currentDate)}'),
              const SizedBox(height: 16),
              TextField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Current Mileage (km)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Record replacement
              final mileage = int.tryParse(_mileageController.text);
              if (mileage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid mileage')),
                );
                return;
              }
              
              final updatedPart = Part(
                id: _part.id,
                vehicleId: _part.vehicleId,
                name: _part.name,
                expectedLifespan: _part.expectedLifespan,
                lifeSpanUnit: _part.lifeSpanUnit,
                installationDate: _part.installationDate,
                installationMileage: _part.installationMileage,
                lastReplacementDate: currentDate,
                lastReplacementMileage: mileage,
              );
              
              setState(() {
                _part = updatedPart;
              });
              
              widget.onUpdate(updatedPart);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Replacement recorded successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}