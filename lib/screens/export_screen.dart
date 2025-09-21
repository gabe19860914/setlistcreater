import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/setlist_model.dart';
import '../utils/pdf_generator.dart';

class ExportScreen extends StatelessWidget {
  // HomeScreenからセットリストデータを受け取る
  final Setlist setlist;

  const ExportScreen({super.key, required this.setlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      // PDFのプレビュー、共有、印刷機能を提供するウィジェット
      body: PdfPreview(
        // buildコールバックでPDFを生成する関数を呼び出す
        build: (format) => generatePdf(setlist),
      ),
    );
  }
}