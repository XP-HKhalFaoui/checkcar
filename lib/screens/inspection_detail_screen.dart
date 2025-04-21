import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inspection.dart';

class InspectionDetailScreen extends StatefulWidget {
  final Inspection inspection;
  final Function(Inspection) onUpdate;

  const InspectionDetailScreen({
    Key? key,
    required this.inspection,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _InspectionDetailScreenState createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  late Inspection _inspection;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _inspection = widget.inspection;
  }

  @override
  Widget build(BuildContext context) {
    final passedItems = _inspection.items.where((item) => item.passed).length;
    final totalItems = _inspection.items.length;
    final passRate = totalItems > 0 ? (passedItems / totalItems) * 100 : 0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspection Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inspection Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Date', _dateFormat.format(_inspection.date)),
                    _buildInfoRow('Inspector', _inspection.inspector),
                    _buildInfoRow('Mileage', '${_inspection.mileage} km'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inspection Result',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: passedItems / totalItems,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  passRate == 100 ? Colors.green : Colors.orange,
                                ),
                                minHeight: 10,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Passed: $passedItems/$totalItems items (${passRate.toStringAsFixed(0)}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: passRate == 100 ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: passRate == 100 ? Colors.green : Colors.orange,
                          child: Icon(
                            passRate == 100 ? Icons.check_circle : Icons.warning,
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
            
            // Inspection items
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inspection Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _inspection.items.length,
                      itemBuilder: (context, index) {
                        final item = _inspection.items[index];
                        return ListTile(
                          leading: Icon(
                            item.passed ? Icons.check_circle : Icons.cancel,
                            color: item.passed ? Colors.green : Colors.red,
                          ),
                          title: Text(item.name),
                          subtitle: item.notes != null && item.notes!.isNotEmpty
                              ? Text(item.notes!)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditItemDialog(index),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Inspection Item'),
                        onPressed: _showAddItemDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Photos section
            if (_inspection.photoUrls != null && _inspection.photoUrls!.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _inspection.photoUrls!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  // View full-size photo
                                },
                                child: Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _inspection.photoUrls![index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.broken_image, size: 40),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Add Photos'),
                  onPressed: _addPhotos,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share Report'),
                  onPressed: _shareReport,
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
    final TextEditingController inspectorController = 
        TextEditingController(text: _inspection.inspector);
    final TextEditingController mileageController = 
        TextEditingController(text: _inspection.mileage.toString());
    DateTime inspectionDate = _inspection.date;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Inspection'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: inspectorController,
                decoration: const InputDecoration(
                  labelText: 'Inspector',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mileageController,
                decoration: const InputDecoration(
                  labelText: 'Mileage (km)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Inspection Date'),
                subtitle: Text(_dateFormat.format(inspectionDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: inspectionDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != inspectionDate) {
                    setState(() {
                      inspectionDate = picked;
                    });
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
              // Validate input
              final mileage = int.tryParse(mileageController.text);
              if (mileage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid mileage')),
                );
                return;
              }
              
              // Update inspection with new values
              final updatedInspection = Inspection(
                id: _inspection.id,
                vehicleId: _inspection.vehicleId,
                date: inspectionDate,
                mileage: mileage,
                inspector: inspectorController.text,
                items: _inspection.items,
                photoUrls: _inspection.photoUrls,
                pdfUrl: _inspection.pdfUrl,
              );
              
              setState(() {
                _inspection = updatedInspection;
              });
              
              widget.onUpdate(updatedInspection);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(int index) {
    final item = _inspection.items[index];
    final TextEditingController nameController = TextEditingController(text: item.name);
    final TextEditingController notesController = TextEditingController(text: item.notes);
    bool passed = item.passed;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Inspection Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Passed'),
                value: passed,
                onChanged: (value) {
                  setState(() {
                    passed = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
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
              // Update item
              final updatedItem = InspectionItem(
                name: nameController.text,
                passed: passed,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              
              final List<InspectionItem> updatedItems = List.from(_inspection.items);
              updatedItems[index] = updatedItem;
              
              final updatedInspection = Inspection(
                id: _inspection.id,
                vehicleId: _inspection.vehicleId,
                date: _inspection.date,
                mileage: _inspection.mileage,
                inspector: _inspection.inspector,
                items: updatedItems,
                photoUrls: _inspection.photoUrls,
                pdfUrl: _inspection.pdfUrl,
              );
              
              setState(() {
                _inspection = updatedInspection;
              });
              
              widget.onUpdate(updatedInspection);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    bool passed = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Inspection Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Passed'),
                value: passed,
                onChanged: (value) {
                  setState(() {
                    passed = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
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
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an item name')),
                );
                return;
              }
              
              // Add new item
              final newItem = InspectionItem(
                name: nameController.text,
                passed: passed,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              
              final List<InspectionItem> updatedItems = List.from(_inspection.items)..add(newItem);
              
              final updatedInspection = Inspection(
                id: _inspection.id,
                vehicleId: _inspection.vehicleId,
                date: _inspection.date,
                mileage: _inspection.mileage,
                inspector: _inspection.inspector,
                items: updatedItems,
                photoUrls: _inspection.photoUrls,
                pdfUrl: _inspection.pdfUrl,
              );
              
              setState(() {
                _inspection = updatedInspection;
              });
              
              widget.onUpdate(updatedInspection);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addPhotos() {
    // This would use image_picker to select photos
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Photos'),
        content: const Text('This would allow you to take or select photos'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Mock successful photo addition
              final List<String> updatedPhotos = 
                  _inspection.photoUrls != null ? List.from(_inspection.photoUrls!) : [];
              
              // Add a mock photo URL
              updatedPhotos.add('https://example.com/inspection_photo.jpg');
              
              final updatedInspection = Inspection(
                id: _inspection.id,
                vehicleId: _inspection.vehicleId,
                date: _inspection.date,
                mileage: _inspection.mileage,
                inspector: _inspection.inspector,
                items: _inspection.items,
                photoUrls: updatedPhotos,
                pdfUrl: _inspection.pdfUrl,
              );
              
              setState(() {
                _inspection = updatedInspection;
              });
              
              widget.onUpdate(updatedInspection);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _generatePdf() {
    // This would generate a PDF report
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate PDF Report'),
        content: const Text('This would generate a PDF report of the inspection'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Mock successful PDF generation
              final updatedInspection = Inspection(
                id: _inspection.id,
                vehicleId: _inspection.vehicleId,
                date: _inspection.date,
                mileage: _inspection.mileage,
                inspector: _inspection.inspector,
                items: _inspection.items,
                photoUrls: _inspection.photoUrls,
                pdfUrl: 'https://example.com/inspection_report.pdf',
              );
              
              setState(() {
                _inspection = updatedInspection;
              });
              
              widget.onUpdate(updatedInspection);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF report generated successfully')),
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _shareReport() {
    // This would share the inspection report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing functionality would be implemented here')),
    );
  }
}