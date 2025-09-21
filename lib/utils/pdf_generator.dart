import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/setlist_model.dart';

Future<Uint8List> generatePdf(Setlist setlist) async {
  final pdf = pw.Document();

  // プロジェクトのアセットから日本語フォントを読み込む
  final fontData = await rootBundle.load('assets/fonts/NotoSansJP-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);
  final boldTtf = pw.Font.ttf((await rootBundle.load('assets/fonts/NotoSansJP-Bold.ttf')));

  // PDF全体のテーマとしてフォントを設定
  final theme = pw.ThemeData.withFont(
    base: ttf,
    bold: boldTtf,
  );

  // 曲リストのヘッダー
  const tableHeaders = ['#', '曲名', 'アーティスト'];
  // 曲リストのデータを作成
  final tableData = setlist.songs
      .asMap()
      .map((index, song) => MapEntry(index, [
            (index + 1).toString(),
            song.title,
            song.artist,
          ]))
      .values
      .toList();

  pdf.addPage(
    pw.Page(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ヘッダー部分
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(setlist.title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    DateFormat('yyyy年MM月dd日').format(setlist.date),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.Text(
              '会場: ${setlist.venue}',
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.Divider(height: 30),

            // 曲リストのテーブル
            pw.Table.fromTextArray(
              headers: tableHeaders,
              data: tableData,
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
              },
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FlexColumnWidth(),
                2: const pw.FlexColumnWidth(),
              }
            ),
          ],
        );
      },
    ),
  );

  // PDFをバイトデータとして保存
  return pdf.save();
}