// ignore_for_file: unnecessary_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
//import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // Ajoutez ceci pour l'encodage JSON

class CodeBarrePage extends StatefulWidget {
  final String name;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String lieuNaissance;
  final String formationTitre;
  final String formationDate;
  final String qrCode; // Peut rester pour compatibilité

  const CodeBarrePage({
    super.key,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.lieuNaissance,
    required this.formationTitre,
    required this.formationDate,
    required this.qrCode,
  });

  @override
  State<CodeBarrePage> createState() => _CodeBarrePageState();
}

class _CodeBarrePageState extends State<CodeBarrePage> {
  final GlobalKey _cardKey = GlobalKey();

  /// Génère une chaîne JSON avec toutes les infos du participant
  String _buildQrData() {
    final data = {
      "nom": widget.name,
      "email": widget.email,
      "telephone": widget.phoneNumber,
      "date_naissance": widget.dateOfBirth,
      "lieu_naissance": widget.lieuNaissance,
      "formation": widget.formationTitre,
      "date_formation": widget.formationDate,
      "qr_code": widget.qrCode,
    };
    return jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _buildQrData(); // Utilise la nouvelle méthode

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Carte Participant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('À propos de la carte'),
                      content: const Text(
                        'Cette carte contient vos informations personnelles et le QR code unique pour cette formation. '
                        'Vous pouvez la partager ou l\'imprimer pour un accès facile.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[100]!, Colors.grey[50]!],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: RepaintBoundary(
                key: _cardKey,
                child: _buildParticipantCard(qrData),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.print,
                label: 'Imprimer',
                color: Colors.deepPurple,
                onPressed: () => _printCard(qrData),
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Partager',
                color: Colors.blue[700]!,
                onPressed: () => _shareCard(qrData),
              ),
              _buildActionButton(
                icon: Icons.save_alt,
                label: 'Sauvegarder',
                color: Colors.teal[600]!,
                onPressed: () => _saveCardAsPdf(qrData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantCard(String qrData) {
    return Card(
      elevation: 12,
      shadowColor: Colors.indigo.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8F9FF)],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Éléments décoratifs
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Contenu de la carte
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 400;
                    return isWide
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _qrSection(qrData),
                            const SizedBox(width: 32),
                            Expanded(child: _infoSection()),
                          ],
                        )
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _infoHeader(),
                            const SizedBox(height: 20),
                            _qrSection(qrData),
                            const SizedBox(height: 24),
                            _infoDetails(),
                          ],
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoHeader() {
    return Column(
      children: [
        /*Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo[400]!, Colors.indigo[800]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            Text(
              _initials(widget.name),
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ), */
        //const SizedBox(height: 10),
        Text(
          widget.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _infoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_infoHeader(), const SizedBox(height: 24), _infoDetails()],
    );
  }

  Widget _infoDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _infoRow(Icons.school, 'Formation', widget.formationTitre),
          _divider(),
          _infoRow(Icons.email_outlined, 'Email', widget.email),
          _divider(),
          _infoRow(Icons.phone_outlined, 'Téléphone', widget.phoneNumber),
          _divider(),
          _infoRow(Icons.cake_outlined, 'Né(e) le', widget.dateOfBirth),
          _divider(),
          _infoRow(Icons.location_on_outlined, 'Lieu', widget.lieuNaissance),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.grey[200], height: 16);
  }

  Widget _qrSection(String qrData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo[50]!, Colors.indigo[100]!],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 130,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.indigo,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.indigo,
            ),
          ),
        ),
        /* const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.indigo[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'QR Code',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),  */
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.indigo[700], size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Future<void> _printCard(String qrData) async {
    final pdf = await _generatePdf(qrData);
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'Carte_Participant_${widget.name.replaceAll(' ', '_')}',
    );
  }

  Future<void> _shareCard(String qrData) async {
    final pdf = await _generatePdf(qrData);
    await Share.shareXFiles(
      [
        XFile.fromData(
          await pdf.save(),
          name: 'Carte_Participant_${widget.name.replaceAll(' ', '_')}.pdf',
          mimeType: 'application/pdf',
        ),
      ],
      subject: 'Votre carte de participant',
      text: 'Voici votre carte de participant personnalisée.',
    );
  }

  Future<void> _saveCardAsPdf(String qrData) async {
    final pdf = await _generatePdf(qrData);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Carte_Participant_${widget.name.replaceAll(' ', '_')}.pdf',
    );
  }

  Future<pw.Document> _generatePdf(String qrData) async {
    final pdf = pw.Document();

    // Capture l'image de la carte
    Uint8List? cardImage = await _captureCardImage();

    // Créer une image PDF à partir de la capture si disponible
    final cardPwImage = cardImage != null ? pw.MemoryImage(cardImage) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child:
                cardPwImage != null
                    ? pw.Image(cardPwImage, width: 500)
                    : _buildPdfCardManually(qrData),
          );
        },
      ),
    );
    return pdf;
  }

  pw.Widget _buildPdfCardManually(String qrData) {
    final initialsName = _initials(widget.name);

    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(20),
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.indigo, width: 2),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.grey300,
            offset: const PdfPoint(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      padding: const pw.EdgeInsets.all(24),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColors.indigo,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  initialsName,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            widget.name,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.indigo900,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.indigo50,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      pw.BarcodeWidget(
                        data: qrData, // Utilise la chaîne JSON
                        barcode: pw.Barcode.qrCode(),
                        width: 120,
                        height: 120,
                        color: PdfColors.indigo800,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.indigo700,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Text(
                          'QR Code',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 24),
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: PdfColors.grey200),
                  ),
                  child: pw.Column(
                    children: [
                      _buildPdfInfoRow('Formation', widget.formationTitre),
                      pw.Divider(color: PdfColors.grey200),
                      _buildPdfInfoRow('Email', widget.email),
                      pw.Divider(color: PdfColors.grey200),
                      _buildPdfInfoRow('Téléphone', widget.phoneNumber),
                      pw.Divider(color: PdfColors.grey200),
                      _buildPdfInfoRow('Date de naissance', widget.dateOfBirth),
                      pw.Divider(color: PdfColors.grey200),
                      _buildPdfInfoRow(
                        'Lieu de naissance',
                        widget.lieuNaissance,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Carte générée le ${_getCurrentDate()}',
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 8,
            height: 8,
            margin: const pw.EdgeInsets.only(top: 4, right: 8),
            decoration: const pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.indigo,
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                label,
                style: const pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  /// Capture l'image de la carte participant sous forme de Uint8List (PNG)
  Future<Uint8List?> _captureCardImage() async {
    try {
      RenderRepaintBoundary boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return _captureCardImage();
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Erreur lors de la capture de la carte: $e');
      return null;
    }
  }
}
