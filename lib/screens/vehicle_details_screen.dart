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
    _tabController = TabController(length: 4, vsync: this);
    _loadDemoData(); // These lists are populated here
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
            Tab(text: 'Summary 📊'),
            Tab(text: 'Parts 🛠️'),
            Tab(text: 'Papers 📄'),
            Tab(text: 'Inspections ✅'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Summary Tab
          _buildSummaryTab(_parts, _documents, _inspections),
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
        // Summary tab - no direct add action
        // Maybe show a dialog to choose which type to add
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add New Item'),
            content: const Text('What would you like to add?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddPartDialog();
                },
                child: const Text('Part'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddDocumentDialog();
                },
                child: const Text('Document'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddInspectionDialog();
                },
                child: const Text('Inspection'),
              ),
            ],
          ),
        );
        break;
      case 1:
        // Add new part
        _showAddPartDialog();
        break;
      case 2:
        // Add new document
        _showAddDocumentDialog();
        break;
      case 3:
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

Widget _buildSummaryTab(List<Part> _parts, List<Document> _documents,
    List<Inspection> _inspections) {
  // Calculate overall health metrics
  final totalParts = _parts.length;
  final healthyParts =
      _parts.where((part) => part.lifePercentageRemaining > 30).length;
  // Ensure partsHealth is double by using 100.0
  final double partsHealth =
      totalParts > 0 ? (healthyParts / totalParts) * 100.0 : 100.0;

  final expiredDocs = _documents.where((doc) => doc.daysUntilExpiry < 0).length;
  final warningDocs = _documents
      .where((doc) => doc.daysUntilExpiry >= 0 && doc.daysUntilExpiry < 30)
      .length;
  // Ensure docsHealth is double by using floating-point numbers
  final double docsHealth = _documents.isNotEmpty && expiredDocs == 0
      ? 100.0 - (warningDocs / _documents.length) * 20.0
      : _documents.isEmpty
          ? 100.0
          : 0.0;

  final totalInspectionItems = _inspections.fold<int>(
      0, (sum, inspection) => sum + inspection.items.length);
  final passedItems = _inspections.fold<int>(
      0,
      (sum, inspection) =>
          sum + inspection.items.where((item) => item.passed).length);
  // Ensure inspectionHealth is double by using 100.0
  final double inspectionHealth = totalInspectionItems > 0
      ? (passedItems / totalInspectionItems) * 100.0
      : 100.0;

  // Calculate overall health (weighted average) - this will be double
  final overallHealth =
      (partsHealth * 0.4) + (docsHealth * 0.3) + (inspectionHealth * 0.3);

  Color healthColor = Colors.green;
  if (overallHealth < 70) healthColor = Colors.orange;
  if (overallHealth < 50) healthColor = Colors.red;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall health card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Overall Vehicle Health',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  width: 300,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: overallHealth / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(healthColor),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${overallHealth.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: healthColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  overallHealth > 80
                      ? 'Excellent Condition'
                      : overallHealth > 60
                          ? 'Good Condition'
                          : overallHealth > 40
                              ? 'Needs Attention'
                              : 'Requires Immediate Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: healthColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Component health cards
        const Text(
          'Component Health',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Parts health - partsHealth is now guaranteed to be double
        _buildHealthCard(
            'Parts & Components',
            partsHealth,
            '${healthyParts}/${totalParts} parts in good condition',
            Icons.build),

        // Documents health - docsHealth is now guaranteed to be double
        _buildHealthCard(
            'Documents & Registrations',
            docsHealth,
            expiredDocs > 0
                ? '$expiredDocs document(s) expired'
                : warningDocs > 0
                    ? '$warningDocs document(s) expiring soon'
                    : 'All documents valid',
            Icons.description),

        // Inspection health - inspectionHealth is now guaranteed to be double
        _buildHealthCard(
            'Inspection Status',
            inspectionHealth,
            '$passedItems/$totalInspectionItems checks passed',
            Icons.check_circle),

        const SizedBox(height: 16),

        // Maintenance due soon
        if (_parts.any((part) => part.lifePercentageRemaining < 30))
          _buildMaintenanceCard(_parts),
      ],
    ),
  );
}

Widget _buildHealthCard(
    String title, double healthPercentage, String subtitle, IconData icon) {
  Color color = Colors.green;
  if (healthPercentage < 70) color = Colors.orange;
  if (healthPercentage < 50) color = Colors.red;

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      leading: Icon(icon, color: color, size: 36),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: healthPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            '${healthPercentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMaintenanceCard(List<Part> _parts) {
  final urgentParts = _parts
      .where((part) => part.lifePercentageRemaining < 30)
      .toList()
    ..sort((a, b) =>
        a.lifePercentageRemaining.compareTo(b.lifePercentageRemaining));

  return Card(
    margin: const EdgeInsets.only(top: 8),
    color: Colors.amber[50],
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Maintenance Due Soon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...urgentParts
              .take(3)
              .map((part) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_right,
                          color: part.lifePercentageRemaining < 10
                              ? Colors.red
                              : Colors.orange,
                        ),
                        Expanded(
                          child: Text(
                            '${part.name} (${part.lifePercentageRemaining.toStringAsFixed(0)}% remaining)',
                            style: TextStyle(
                              color: part.lifePercentageRemaining < 10
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          if (urgentParts.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${urgentParts.length - 3} more items need attention',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
