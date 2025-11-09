import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/setlist/setlist_model.dart';
import '../utils/pdf_generator.dart';

class ExportScreen extends StatelessWidget {
  final Setlist setlist;
  // --- 機能追加：設定を受け取るプロパティ ---
  final bool isLandscape;
  final int divisionCount;

  const ExportScreen({
    super.key,
    required this.setlist,
    required this.isLandscape,
    required this.divisionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: PdfPreview(
        // --- 機能追加：設定をPDF生成関数に渡す ---
        build: (format) => generatePdf(
          setlist,
          isLandscape: isLandscape,
          divisionCount: divisionCount,
        ),
      ),
    );
  }
}

