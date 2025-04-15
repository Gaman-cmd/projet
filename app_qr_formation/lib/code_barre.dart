import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr/qr.dart';

class CodeBarrePage extends StatelessWidget {
  final String name;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String lieuNaissance;

  const CodeBarrePage({
    Key? key,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.lieuNaissance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Code-barre', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoRow('Email:', email),
            const SizedBox(height: 12),
            _buildInfoRow('Téléphone:', phoneNumber),
            const SizedBox(height: 12),
            _buildInfoRow('Date de naissance:', dateOfBirth),
            const SizedBox(height: 30),
            _buildInfoRow('Lieu de Naissance:', lieuNaissance),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: QrImageView(
                      data: '$name\nEmail: $email\nTéléphone: $phoneNumber\nDOB: $dateOfBirth\n  $lieuNaissance\nLieu de Naissance:',
                      version: QrVersions.auto,
                      size: 90,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final pdf = pw.Document();

                    pdf.addPage(pw.Page(
                      build: (pw.Context context) {
                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 12),
                            pw.Text('Email: $email'),
                            pw.SizedBox(height: 12),
                            pw.Text('Téléphone: $phoneNumber'),
                            pw.SizedBox(height: 12),
                            pw.Text('Date de naissance: $dateOfBirth'),
                            pw.SizedBox(height: 20),
                            pw.Text('Date de naissance: $lieuNaissance'),
                            pw.SizedBox(height: 20),
                            pw.BarcodeWidget(
                              data: '$name\nEmail: $email\nTéléphone: $phoneNumber\nDOB: $dateOfBirth\n  $lieuNaissance\nLieu de Naissance:',
                             barcode: pw.Barcode.qrCode(),
                              width: 100,
                              height: 100,
                            ),
                          ],
                        );
                      },
                    ));

                    await Printing.sharePdf(bytes: await pdf.save(), filename: 'code_barre.pdf');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Imprimer', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pdf = pw.Document();

                    pdf.addPage(pw.Page(
                      build: (pw.Context context) {
                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 12),
                            pw.Text('Email: $email'),
                            pw.SizedBox(height: 12),
                            pw.Text('Téléphone: $phoneNumber'),
                            pw.SizedBox(height: 12),
                            pw.Text('Date de naissance: $dateOfBirth'),
                            pw.SizedBox(height: 20),
                            pw.Text('Lieu de naissance: $lieuNaissance'),
                            pw.SizedBox(height: 20),
                            pw.BarcodeWidget(
                             data: '$name\nEmail: $email\nTéléphone: $phoneNumber\nDOB: $dateOfBirth\n  $lieuNaissance\nLieu de Naissance:',
                             barcode: pw.Barcode.qrCode(),
                              width: 100,
                              height: 100,
                            ),
                          ],
                        );
                      },
                    ));

                    await Share.shareXFiles(
                      [XFile.fromData(await pdf.save(), name: 'code_barre.pdf')],
                      subject: 'Informations du participant',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Envoyer', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}