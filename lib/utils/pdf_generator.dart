import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/setlist/setlist_model.dart';

Future<Uint8List> generatePdf(
  Setlist setlist, {
  required bool isLandscape,
  required int divisionCount,
}) async {
  final pdf = pw.Document();

  // ★★★ 日本語フォントの読み込み処理 (インデント修正) ★★★
  final fontData = await rootBundle.load('assets/fonts/NotoSansJP-Regular.ttf');
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());
  final pageTheme = pw.PageTheme(
    pageFormat: isLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4.portrait,
    theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
  );
  // ★★★ ここまで ★★★

  // 1つのセットリストカラムを作成するウィジェットを定義
  pw.Widget buildSetlistColumn(Setlist setlist) {
    // 曲リストのヘッダー
    const tableHeaders = ['#', '曲名'];
    // 曲リストのデータを作成
    final tableData = setlist.songs
        .asMap()
        .map((index, song) => MapEntry(index, [
              (index + 1).toString(),
              song.title,
            ]))
        .values
        .toList();

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
            },
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(),
            }),
      ],
    );
  }

  // ★★★ divisionCount に基づいてカラムを動的に生成する関数 (追加) ★★★
  List<pw.Widget> buildColumns() {
    List<pw.Widget> columns = [];
    for (int i = 0; i < divisionCount; i++) {
      columns.add(pw.Expanded(child: buildSetlistColumn(setlist)));
      // 最後のカラム以外は、間に余白を追加
      if (i < divisionCount - 1) {
        columns.add(pw.SizedBox(width: 20)); // カラム間の余白
      }
    }
    return columns;
  }
  // ★★★ ここまで ★★★

  pdf.addPage(
    pw.Page(
      pageTheme: pageTheme, // 修正した pageTheme を適用
      build: (pw.Context context) {
        // RowとExpandedを使ってカラムを作成
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: buildColumns(), // divisionCount に応じたカラムを動的に生成
        );
      },
    ),
  );

  // PDFをバイトデータとして保存
  return pdf.save();
}