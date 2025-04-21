import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document.dart';
import '../l10n/app_localizations.dart';

class DocumentDetailScreen extends StatefulWidget {
  final Document document;
  final Function(Document) onUpdate;

  const DocumentDetailScreen({
    Key? key,
    required this.document,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _DocumentDetailScreenState createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  late Document _document;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _document = widget.document;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!; // Helper variable
    final daysUntilExpiry = _document.daysUntilExpiry;
    final isExpired = daysUntilExpiry < 0;

    // Dynamic status text
    String statusText;
    if (isExpired) {
      statusText = localizations
          .translate('expiredAgo')
          .replaceAll('{days}', (-daysUntilExpiry).toString());
    } else {
      statusText = localizations
          .translate('daysUntilExpiry')
          .replaceAll('{days}', daysUntilExpiry.toString());
    }

    return Scaffold(
      appBar: AppBar(
        // Translate title using document type name (which should also be translated)
        title: Text(_getDocumentTypeName(_document.type, localizations)),
        actions: [
          IconButton(
            tooltip: localizations.translate('edit'), // Tooltip for edit
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
            // Status card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations
                              .translate('status'), // Translate 'Status'
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: isExpired
                              ? Colors.red
                              : daysUntilExpiry < 30
                                  ? Colors.orange
                                  : Colors.green,
                          child: Icon(
                            isExpired
                                ? Icons.error
                                : daysUntilExpiry < 30
                                    ? Icons.warning
                                    : Icons.check_circle,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      statusText, // Use the dynamic status text
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isExpired
                            ? Colors.red
                            : daysUntilExpiry < 30
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Document details
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate(
                          'documentDetails'), // Translate 'Document Details'
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    // Use keys for labels in _buildInfoRow
                    _buildInfoRow('documentType',
                        _getDocumentTypeName(_document.type, localizations)),
                    _buildInfoRow('documentNumber', _document.documentNumber),
                    _buildInfoRow(
                        'issueDate', _dateFormat.format(_document.issueDate)),
                    _buildInfoRow(
                        'expiryDate', _dateFormat.format(_document.expiryDate)),
                    if (_document.fileUrl != null &&
                        _document.fileUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.remove_red_eye),
                          label: Text(localizations.translate(
                              'viewDocument')), // Translate 'View Document'
                          onPressed: () {
                            // Open document viewer
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons (already translated in previous step, ensure keys 'scan' and 'renew' exist)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: Text(localizations.translate('scan')),
                      onPressed: _uploadDocument,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.autorenew),
                      label: Text(localizations.translate('renew')),
                      onPressed: _showRenewDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pass localizations to _buildInfoRow
  Widget _buildInfoRow(String labelKey, String value) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizations.translate(labelKey), // Translate the label key
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  // Pass localizations to _getDocumentTypeName
  String _getDocumentTypeName(
      DocumentType type, AppLocalizations localizations) {
    switch (type) {
      case DocumentType.insurance:
        return localizations.translate('insurance');
      case DocumentType.registration:
        return localizations.translate('registration');
      case DocumentType.technicalInspection:
        return localizations.translate('technicalInspection');
      case DocumentType.vignette:
        return localizations.translate('vignette');
    }
  }

  void _showEditDialog() {
    final localizations = AppLocalizations.of(context)!;
    final TextEditingController documentNumberController =
        TextEditingController(text: _document.documentNumber);
    DateTime issueDate = _document.issueDate;
    DateTime expiryDate = _document.expiryDate;

    showDialog(
      context: context,
      // Use stateful builder to update dates within the dialog
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(localizations.translate('edit') +
              ' ' +
              _getDocumentTypeName(_document.type, localizations)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: documentNumberController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('documentNumber'),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(localizations.translate('issueDate')),
                  subtitle: Text(_dateFormat.format(issueDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: issueDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      // Pass locale for date picker localization
                      locale: Localizations.localeOf(context),
                    );
                    if (picked != null && picked != issueDate) {
                      setDialogState(() {
                        // Use setDialogState here
                        issueDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text(localizations.translate('expiryDate')),
                  subtitle: Text(_dateFormat.format(expiryDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: expiryDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      // Pass locale for date picker localization
                      locale: Localizations.localeOf(context),
                    );
                    if (picked != null && picked != expiryDate) {
                      setDialogState(() {
                        // Use setDialogState here
                        expiryDate = picked;
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
              child: Text(localizations.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                // Update document with new values
                final updatedDocument = Document(
                  id: _document.id,
                  vehicleId: _document.vehicleId,
                  type: _document.type,
                  issueDate: issueDate,
                  expiryDate: expiryDate,
                  documentNumber: documentNumberController.text,
                  fileUrl: _document.fileUrl,
                );

                setState(() {
                  // Use setState from the main screen state
                  _document = updatedDocument;
                });

                widget.onUpdate(updatedDocument);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(localizations.translate(
                          'documentUpdatedSuccess'))), // Translate success message
                );
              },
              child: Text(localizations.translate('save')),
            ),
          ],
        );
      }),
    );
  }

  void _showRenewDialog() {
    final localizations = AppLocalizations.of(context)!;
    final TextEditingController documentNumberController =
        TextEditingController();
    DateTime issueDate = DateTime.now(); // Keep issue date separate
    DateTime expiryDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(// Use StatefulBuilder for date updates
              builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(localizations.translate('renew') +
              ' ' +
              _getDocumentTypeName(_document.type, localizations)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: documentNumberController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('newDocumentNumber'),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(localizations.translate('issueDate')),
                  subtitle: Text(_dateFormat
                      .format(issueDate)), // Display fixed issue date
                  trailing: const Icon(Icons.calendar_today),
                  enabled: false, // Issue date is fixed to now
                ),
                ListTile(
                  title: Text(localizations.translate('expiryDate')),
                  subtitle: Text(_dateFormat.format(expiryDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: expiryDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      locale: Localizations.localeOf(context), // Pass locale
                    );
                    if (picked != null && picked != expiryDate) {
                      setDialogState(() {
                        // Use setDialogState
                        expiryDate = picked;
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
              child: Text(localizations.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                if (documentNumberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(localizations.translate(
                            'enterDocumentNumberError'))), // Translate error
                  );
                  return;
                }

                // Create renewed document
                final renewedDocument = Document(
                  id: _document
                      .id, // Keep the same ID or generate new? Depends on logic
                  vehicleId: _document.vehicleId,
                  type: _document.type,
                  issueDate: issueDate, // Use the fixed issue date
                  expiryDate: expiryDate,
                  documentNumber: documentNumberController.text,
                  fileUrl: null, // Reset file URL
                );

                setState(() {
                  // Use main screen setState
                  _document = renewedDocument;
                });

                widget.onUpdate(renewedDocument);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(localizations.translate(
                          'documentRenewedSuccess'))), // Translate success
                );
              },
              child: Text(localizations.translate('renew')),
            ),
          ],
        );
      }),
    );
  }

  void _uploadDocument() {
    final localizations = AppLocalizations.of(context)!;
    // This would use file_picker to select a document
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(localizations.translate('uploadDocument')), // Translate title
        content: Text(
            localizations.translate('selectFilePrompt')), // Translate prompt
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              // Mock successful upload
              final updatedDocument = Document(
                id: _document.id,
                vehicleId: _document.vehicleId,
                type: _document.type,
                issueDate: _document.issueDate,
                expiryDate: _document.expiryDate,
                documentNumber: _document.documentNumber,
                fileUrl: 'https://example.com/document.pdf', // Mock URL
              );

              setState(() {
                _document = updatedDocument;
              });

              widget.onUpdate(updatedDocument);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(localizations.translate(
                        'documentUploadedSuccess'))), // Translate success
              );
            },
            child: Text(localizations.translate('upload')), // Translate button
          ),
        ],
      ),
    );
  }
}
