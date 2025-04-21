import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/part.dart';
import '../models/document.dart';
import '../models/inspection.dart';
import 'part_detail_screen.dart';
import 'document_detail_screen.dart';
import 'inspection_detail_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({Key? key, required this.vehicle})
      : super(key: key);

  @override
  _VehicleDetailsScreenState createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo data - would come from database in real app
  List<Part> _parts = [];
  List<Document> _documents = [];
  List<Inspection> _inspections = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDemoData();
  }

  void _loadDemoData() {
    // Demo parts
    _parts = [
      Part(
        id: '1',
        vehicleId: widget.vehicle.id,
        name: 'Engine Oil',
        expectedLifespan: 10000,
        lifeSpanUnit: LifespanUnit.kilometers,
        installationDate: DateTime.now().subtract(const Duration(days: 90)),
        installationMileage: widget.vehicle.currentMileage - 3000,
      ),
      Part(
        id: '2',
        vehicleId: widget.vehicle.id,
        name: 'Air Filter',
        expectedLifespan: 15000,
        lifeSpanUnit: LifespanUnit.kilometers,
        installationDate: DateTime.now().subtract(const Duration(days: 180)),
        installationMileage: widget.vehicle.currentMileage - 5000,
      ),
    ];

    // Demo documents
    _documents = [
      Document(
        id: '1',
        vehicleId: widget.vehicle.id,
        type: DocumentType.insurance,
        issueDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 335)),
        documentNumber: 'INS-12345',
      ),
      Document(
        id: '2',
        vehicleId: widget.vehicle.id,
        type: DocumentType.registration,
        issueDate: DateTime.now().subtract(const Duration(days: 365)),
        expiryDate: DateTime.now().add(const Duration(days: 730)),
        documentNumber: 'REG-67890',
      ),
    ];

    // Demo inspections
    _inspections = [
      Inspection(
        id: '1',
        vehicleId: widget.vehicle.id,
        date: DateTime.now().subtract(const Duration(days: 60)),
        mileage: widget.vehicle.currentMileage - 2000,
        inspector: 'Auto Service Center',
        items: [
          InspectionItem(name: 'Brakes', passed: true),
          InspectionItem(name: 'Lights', passed: true),
          InspectionItem(
              name: 'Suspension', passed: false, notes: 'Needs attention'),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicle.brand} ${widget.vehicle.model}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Parts  🛠️'),
            Tab(text: 'Papers 📄'),
            Tab(text: 'Inspections ✅'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Parts Tab
          _buildPartsTab(),
          // Documents Tab
          _buildDocumentsTab(),
          // Inspections Tab
          _buildInspectionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewItem();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPartsTab() {
    return _parts.isEmpty
        ? Center(
            child: Text(
                'No parts added for ${widget.vehicle.brand} ${widget.vehicle.model}'),
          )
        : ListView.builder(
            itemCount: _parts.length,
            itemBuilder: (context, index) {
              final part = _parts[index];
              final percentRemaining = part.lifePercentageRemaining;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(part.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Installed: ${_formatDate(part.installationDate)}'),
                      const SizedBox(height: 4),
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentRemaining.toStringAsFixed(0)}% remaining',
                        style: TextStyle(
                          color: percentRemaining > 70
                              ? Colors.green
                              : percentRemaining > 30
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show options menu
                    },
                  ),
                  onTap: () {
                    // Navigate to part details
                  },
                ),
              );
            },
          );
  }

  Widget _buildDocumentsTab() {
    return _documents.isEmpty
        ? Center(
            child: Text(
                'No documents added for ${widget.vehicle.brand} ${widget.vehicle.model}'),
          )
        : ListView.builder(
            itemCount: _documents.length,
            itemBuilder: (context, index) {
              final document = _documents[index];
              final daysLeft = document.daysUntilExpiry;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    _getDocumentIcon(document.type),
                    color: daysLeft < 30 ? Colors.red : Colors.blue,
                    size: 36,
                  ),
                  title: Text(_getDocumentTypeName(document.type)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Number: ${document.documentNumber}'),
                      Text('Expires: ${_formatDate(document.expiryDate)}'),
                      Text(
                        daysLeft < 0
                            ? 'Expired ${-daysLeft} days ago'
                            : '$daysLeft days remaining',
                        style: TextStyle(
                          color: daysLeft < 30 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentDetailScreen(
                            document: document,
                            onUpdate: (updatedDocument) {
                              setState(() {
                                _documents[index] = updatedDocument;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentDetailScreen(
                          document: document,
                          onUpdate: (updatedDocument) {
                            setState(() {
                              _documents[index] = updatedDocument;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }

  Widget _buildInspectionsTab() {
    return _inspections.isEmpty
        ? Center(
            child: Text(
                'No inspections added for ${widget.vehicle.brand} ${widget.vehicle.model}'),
          )
        : ListView.builder(
            itemCount: _inspections.length,
            itemBuilder: (context, index) {
              final inspection = _inspections[index];
              final passedItems =
                  inspection.items.where((item) => item.passed).length;
              final totalItems = inspection.items.length;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Inspection on ${_formatDate(inspection.date)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inspector: ${inspection.inspector}'),
                      Text('Mileage: ${inspection.mileage} km'),
                      Text(
                        'Passed: $passedItems/$totalItems items',
                        style: TextStyle(
                          color: passedItems == totalItems
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.description),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InspectionDetailScreen(
                            inspection: inspection,
                            onUpdate: (updatedInspection) {
                              setState(() {
                                _inspections[index] = updatedInspection;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InspectionDetailScreen(
                          inspection: inspection,
                          onUpdate: (updatedInspection) {
                            setState(() {
                              _inspections[index] = updatedInspection;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }

  void _addNewItem() {
    // Add new item based on current tab
    switch (_tabController.index) {
      case 0:
        // Add new part
        _showAddPartDialog();
        break;
      case 1:
        // Add new document
        _showAddDocumentDialog();
        break;
      case 2:
        // Add new inspection
        _showAddInspectionDialog();
        break;
    }
  }

  void _showAddPartDialog() {
    // Show dialog to add new part
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Part'),
        content: const Text('This would show a form to add a new part'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add new part logic
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddDocumentDialog() {
    // Show dialog to add new document
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Document'),
        content: const Text('This would show a form to add a new document'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add new document logic
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddInspectionDialog() {
    // Show dialog to add new inspection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Inspection'),
        content: const Text('This would show a form to add a new inspection'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add new inspection logic
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.insurance:
        return Icons.health_and_safety;
      case DocumentType.registration:
        return Icons.car_rental;
      case DocumentType.technicalInspection:
        return Icons.build;
      case DocumentType.vignette:
        return Icons.receipt;
    }
  }

  String _getDocumentTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.insurance:
        return 'Insurance';
      case DocumentType.registration:
        return 'Registration';
      case DocumentType.technicalInspection:
        return 'Technical Inspection';
      case DocumentType.vignette:
        return 'Vignette';
    }
  }
}
