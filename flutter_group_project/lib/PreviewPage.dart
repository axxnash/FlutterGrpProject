import 'package:flutter/material.dart';

class CertificatePreviewPage extends StatelessWidget {
  final String name, org, purpose, issued, expiry;

  CertificatePreviewPage({
    required this.name,
    required this.org,
    required this.purpose,
    required this.issued,
    required this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview Certificate")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Digital Certificate",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text("Recipient: $name"),
                Text("Organization: $org"),
                Text("Purpose: $purpose"),
                Text("Issued: $issued"),
                Text("Expires: $expiry"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
