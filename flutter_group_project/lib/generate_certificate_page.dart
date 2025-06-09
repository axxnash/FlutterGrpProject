import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class GenerateCertificatePage extends StatefulWidget {
  @override
  _GenerateCertificatePageState createState() =>
      _GenerateCertificatePageState();
}

class _GenerateCertificatePageState extends State<GenerateCertificatePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '', organization = '', purpose = '';
  DateTime issuedDate = DateTime.now(),
      expiryDate = DateTime.now().add(Duration(days: 365));
  bool isUploading = false;
  String? downloadUrl;

  // Generate the PDF in memory
  Future<Uint8List> _buildPdfBytes() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    "Digital Certificate",
                    style: pw.TextStyle(fontSize: 24),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text("Recipient: $name"),
                  pw.Text("Organization: $organization"),
                  pw.Text("Purpose: $purpose"),
                  pw.Text(
                    "Issued Date: ${DateFormat.yMMMd().format(issuedDate)}",
                  ),
                  pw.Text(
                    "Expiry Date: ${DateFormat.yMMMd().format(expiryDate)}",
                  ),
                ],
              ),
            ),
      ),
    );
    return pdf.save();
  }

  // Upload the PDF to Firebase (only if not Web)
  Future<String?> _uploadPDF(Uint8List bytes) async {
    if (kIsWeb) return null;

    final fileName = "certificate_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(bytes);

    final ref = FirebaseStorage.instance.ref().child('certificates/$fileName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  // Save metadata to Firestore
  Future<void> _saveToFirestore(String? url) async {
    await FirebaseFirestore.instance.collection('certificates').add({
      'name': name,
      'organization': organization,
      'purpose': purpose,
      'issuedDate': issuedDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'url': url,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Main submit handler
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isUploading = true);

      try {
        final pdfBytes = await _buildPdfBytes();

        if (kIsWeb) {
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdfBytes,
          );
          await _saveToFirestore(null); // Web can't generate URL
        } else {
          final url = await _uploadPDF(pdfBytes);
          await _saveToFirestore(url);
          setState(() => downloadUrl = url);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Certificate')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Recipient Name'),
                onSaved: (val) => name = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Organization'),
                onSaved: (val) => organization = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Purpose'),
                onSaved: (val) => purpose = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isUploading ? null : _submit,
                child: Text(isUploading ? 'Uploading...' : 'Generate & Upload'),
              ),
              if (downloadUrl != null && !kIsWeb) ...[
                SizedBox(height: 20),
                Text(
                  'Download URL:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SelectableText(downloadUrl!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
