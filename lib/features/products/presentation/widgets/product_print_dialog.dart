import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system/app_colors.dart';
import '../../domain/product.dart';

final TextTheme finalTextTheme = const TextTheme(
  headlineSmall: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w700,
  ),
  titleMedium: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
  bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14),
  bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 12),
  labelSmall: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w500,
  ),
);

const TextStyle skuStyle = TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11);

/// Monospace receipt-style text used in the thermal slip preview.
TextStyle _thermalStyle({double size = 11, bool bold = false}) =>
    skuStyle.copyWith(
      fontSize: size,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.ink,
    );

/// Dashed separator line for the thermal slip PDF.
pw.Widget _pdfDashedLine() {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: List.generate(
      36,
      (_) => pw.Container(width: 3, height: 0.8, color: PdfColors.black),
    ),
  );
}

String _statusLabel(ProductStatus s) => switch (s) {
  ProductStatus.active => 'Active',
  ProductStatus.paused => 'Inactive',
  ProductStatus.deleted => 'Archived',
};

class ProductPrintDialog extends StatefulWidget {
  const ProductPrintDialog({super.key, required this.products});

  final List<Product> products;

  static Future<void> show(
    BuildContext context, {
    required List<Product> products,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black38,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: ProductPrintDialog(products: products),
      ),
    );
  }

  @override
  State<ProductPrintDialog> createState() => _ProductPrintDialogState();
}

enum _PrintFormat { a4, thermal }

class _ProductPrintDialogState extends State<ProductPrintDialog> {
  _PrintFormat _format = _PrintFormat.a4;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Print Product Catalog',
                          style: finalTextTheme.titleMedium!.copyWith(
                            fontSize: 18,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _format == _PrintFormat.a4
                              ? 'A4 sheet preview. Opens the printer dialog when you print.'
                              : 'Thermal slip (80mm) preview. Opens the printer dialog when you print.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: _format == _PrintFormat.a4
                    ? _A4Preview(products: widget.products)
                    : _ThermalPreview(products: widget.products),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Container(
              color: const Color(0xFFFAFAF8),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Row(
                children: [
                  _FormatTab(
                    label: 'A4 Sheet',
                    selected: _format == _PrintFormat.a4,
                    onTap: () => setState(() => _format = _PrintFormat.a4),
                  ),
                  const SizedBox(width: 8),
                  _FormatTab(
                    label: 'Thermal Slip (80mm)',
                    selected: _format == _PrintFormat.thermal,
                    onTap: () => setState(() => _format = _PrintFormat.thermal),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: BorderSide(color: Colors.grey.shade500, width: 1.2),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final products = widget.products;
                      final now = DateTime.now();
                      final dateStr = formatShortDate(now);
                      final doc = pw.Document();

                      if (_format == _PrintFormat.a4) {
                        doc.addPage(
                          pw.MultiPage(
                            pageFormat: PdfPageFormat.a4,
                            margin: const pw.EdgeInsets.all(24),
                            build: (context) => [
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        'Product Catalog',
                                        style: pw.TextStyle(
                                          fontSize: 22,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                      pw.SizedBox(height: 2),
                                      pw.Text(
                                        'Generated $dateStr',
                                        style: const pw.TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.end,
                                    children: [
                                      pw.Text(
                                        'Product Catalog',
                                        style: const pw.TextStyle(fontSize: 10),
                                      ),
                                      pw.Text(
                                        '${products.length}',
                                        style: pw.TextStyle(
                                          fontSize: 28,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 16),
                              pw.Table(
                                border: pw.TableBorder(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.grey400,
                                  ),
                                ),
                                columnWidths: const {
                                  0: pw.FlexColumnWidth(1),
                                  1: pw.FlexColumnWidth(4),
                                  2: pw.FlexColumnWidth(2),
                                  3: pw.FlexColumnWidth(4),
                                  4: pw.FlexColumnWidth(3),
                                  5: pw.FlexColumnWidth(2),
                                  6: pw.FlexColumnWidth(2),
                                },
                                children: [
                                  pw.TableRow(
                                    decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                        bottom: pw.BorderSide(
                                          color: PdfColors.grey600,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    children: [
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: pw.Text(
                                          '#',
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: pw.Text(
                                          'Product',
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: pw.Text(
                                          'SKU',
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: pw.Text(
                                          'Category / Brand',
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: pw.Text(
                                          'Price',
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: pw.Text(
                                          'Stock',
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: pw.Text(
                                          'Status',
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  for (var i = 0; i < products.length; i++)
                                    pw.TableRow(
                                      decoration: pw.BoxDecoration(
                                        color: i.isEven
                                            ? PdfColors.white
                                            : PdfColor.fromInt(0xFFF9F9F9),
                                      ),
                                      children: [
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                          child: pw.Text(
                                            '${i + 1}',
                                            style: const pw.TextStyle(
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                          child: pw.Text(
                                            products[i].name,
                                            style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                          child: pw.Text(
                                            products[i].sku,
                                            style: const pw.TextStyle(
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                          child: pw.Text(
                                            products[i].categoryAndBrand,
                                            style: const pw.TextStyle(
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                          child: pw.Text(
                                            formatPkr(
                                              products[i].sellingPriceMinor,
                                            ),
                                            textAlign: pw.TextAlign.right,
                                            style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                          child: pw.Text(
                                            products[i].stockQty != null
                                                ? '${products[i].stockQty} ${products[i].unit}'
                                                : '-',
                                            textAlign: pw.TextAlign.right,
                                            style: const pw.TextStyle(
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                          child: pw.Text(
                                            _statusLabel(products[i].status),
                                            style: const pw.TextStyle(
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        doc.addPage(
                          pw.Page(
                            pageFormat: PdfPageFormat(
                              80 * PdfPageFormat.mm,
                              double.infinity,
                              marginAll: 8,
                            ),
                            build: (context) {
                              return pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  pw.Text(
                                    'DUKANOS',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  pw.Text(
                                    'ELECTRICAL & APPLIANCE STORE',
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(fontSize: 8),
                                  ),
                                  pw.Text(
                                    'Main Bazar Road, City 46000',
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(fontSize: 8),
                                  ),
                                  pw.Text(
                                    'Tel: 0300-1234567',
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(fontSize: 8),
                                  ),
                                  pw.SizedBox(height: 6),
                                  pw.Divider(),
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'PRODUCT CATALOG',
                                        style: pw.TextStyle(
                                          fontSize: 9,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                      pw.Text(
                                        '${products.length}',
                                        style: pw.TextStyle(
                                          fontSize: 9,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'Date',
                                        style: const pw.TextStyle(fontSize: 8),
                                      ),
                                      pw.Text(
                                        dateStr,
                                        style: const pw.TextStyle(fontSize: 8),
                                      ),
                                    ],
                                  ),
                                  pw.Divider(),
                                  pw.Row(
                                    children: [
                                      pw.Expanded(
                                        flex: 5,
                                        child: pw.Text(
                                          'ITEM',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 3,
                                        child: pw.Text(
                                          'PRICE',
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      pw.Expanded(
                                        flex: 2,
                                        child: pw.Text(
                                          'STOCK',
                                          textAlign: pw.TextAlign.right,
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.SizedBox(height: 4),
                                  for (var i = 0; i < products.length; i++)
                                    pw.Container(
                                      margin: const pw.EdgeInsets.only(
                                        bottom: 6,
                                      ),
                                      child: pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            '${i + 1}. ${products[i].name}',
                                            style: pw.TextStyle(
                                              fontSize: 9,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Expanded(
                                                flex: 5,
                                                child: pw.Text(
                                                  '${products[i].sku} - ${products[i].categoryName ?? '-'}',
                                                  style: const pw.TextStyle(
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              ),
                                              pw.Expanded(
                                                flex: 3,
                                                child: pw.Text(
                                                  formatPkr(
                                                    products[i]
                                                        .sellingPriceMinor,
                                                  ),
                                                  textAlign:
                                                      pw.TextAlign.center,
                                                  style: pw.TextStyle(
                                                    fontSize: 8,
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              pw.Expanded(
                                                flex: 2,
                                                child: pw.Text(
                                                  products[i].stockQty != null
                                                      ? '${products[i].stockQty} ${products[i].unit}'
                                                      : '-',
                                                  textAlign: pw.TextAlign.right,
                                                  style: const pw.TextStyle(
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  // ── Receipt-style footer ──
                                  pw.SizedBox(height: 4),
                                  _pdfDashedLine(),
                                  pw.SizedBox(height: 6),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.only(top: 6),
                                    decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                        top: pw.BorderSide(
                                          color: PdfColors.black,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          'TOTAL ITEMS',
                                          style: pw.TextStyle(
                                            font: pw.Font.courierBold(),
                                            fontSize: 10,
                                          ),
                                        ),
                                        pw.Text(
                                          '${products.length}',
                                          style: pw.TextStyle(
                                            font: pw.Font.courierBold(),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  pw.SizedBox(height: 12),
                                  pw.Text(
                                    '***',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      font: pw.Font.courier(),
                                      fontSize: 8,
                                    ),
                                  ),
                                  pw.SizedBox(height: 10),
                                  pw.Text(
                                    'END OF CATALOG',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      font: pw.Font.courierBold(),
                                      fontSize: 8,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    'Goods once sold will not be taken back.',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      font: pw.Font.courier(),
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }

                      await Printing.layoutPdf(
                        onLayout: (format) async => doc.save(),
                        name: _format == _PrintFormat.a4
                            ? 'Product_Catalog_A4.pdf'
                            : 'Product_Catalog_Thermal_80mm.pdf',
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: Text(
                      _format == _PrintFormat.a4
                          ? 'Print A4 Sheet'
                          : 'Print Thermal Slip',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
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
}

class _FormatTab extends StatelessWidget {
  const _FormatTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.ink : Colors.grey.shade500,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _A4Preview extends StatelessWidget {
  const _A4Preview({required this.products});

  final List<Product> products;

  static const Color _stockGreen = Color(0xFF166534);
  static const Color _stockRed = Color(0xFFDC2626);
  static const Color _stockOrange = Color(0xFFEA7C0B);

  Color _stockColor(Product p) {
    final qty = p.stockQty;
    if (qty == null) return AppColors.ink;
    if (qty < 0) return _stockOrange;
    if (qty == 0) return _stockRed;
    return _stockGreen;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = formatShortDate(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Catalog',
                      style: finalTextTheme.headlineSmall!.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Generated $dateStr',
                      style: finalTextTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Product Catalog',
                    style: finalTextTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${products.length}',
                    style: skuStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          // ── Table header ──
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.only(bottom: 10),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _A4Cell(flex: 2, text: '#', bold: true),
                _A4Cell(flex: 10, text: 'Product', bold: true),
                _A4Cell(flex: 4, text: 'SKU', bold: true),
                _A4Cell(flex: 10, text: 'Category / Brand', bold: true),
                _A4Cell(flex: 5, text: 'Price', bold: true, right: true),
                _A4Cell(flex: 4, text: 'Stock', bold: true, right: true),
                _A4Cell(flex: 4, text: 'Status', bold: true, right: true),
              ],
            ),
          ),

          // ── Rows ──
          ...products.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _A4Cell(
                    flex: 2,
                    text: '${i + 1}',
                    color: AppColors.textSecondary,
                  ),
                  _A4Cell(flex: 10, text: p.name, bold: true),
                  _A4Cell(
                    flex: 4,
                    text: p.sku,
                    mono: true,
                    color: AppColors.textSecondary,
                  ),
                  _A4Cell(flex: 10, text: p.categoryAndBrand),
                  _A4Cell(
                    flex: 5,
                    text: formatPkr(p.sellingPriceMinor),
                    bold: true,
                    right: true,
                  ),
                  _A4Cell(
                    flex: 4,
                    text: p.stockQty != null ? '${p.stockQty} ${p.unit}' : '—',
                    semi: true,
                    right: true,
                    color: _stockColor(p),
                  ),
                  _A4Cell(
                    flex: 4,
                    text: _statusLabel(p.status),
                    right: true,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _A4Cell extends StatelessWidget {
  const _A4Cell({
    required this.flex,
    required this.text,
    this.bold = false,
    this.semi = false,
    this.mono = false,
    this.right = false,
    this.color,
  });

  final int flex;
  final String text;
  final bool bold;
  final bool semi;
  final bool mono;
  final bool right;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          textAlign: right ? TextAlign.right : TextAlign.left,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: finalTextTheme.bodyMedium!.copyWith(
            fontWeight: bold
                ? FontWeight.w700
                : semi
                ? FontWeight.w600
                : FontWeight.w400,
            fontFamily: mono ? 'JetBrainsMono' : null,
            color: color ?? AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _ThermalPreview extends StatelessWidget {
  const _ThermalPreview({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final dateStr = formatShortDate(DateTime.now());

    return Center(
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'DUKANOS',
              textAlign: TextAlign.center,
              style: _thermalStyle(
                size: 16,
                bold: true,
              ).copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 2),
            Text(
              'ELECTRICAL & APPLIANCE STORE',
              textAlign: TextAlign.center,
              style: _thermalStyle(size: 9),
            ),
            Text(
              'Main Bazar Road, City 46000',
              textAlign: TextAlign.center,
              style: _thermalStyle(size: 9),
            ),
            Text(
              'Tel: 0300-1234567',
              textAlign: TextAlign.center,
              style: _thermalStyle(size: 9),
            ),
            const SizedBox(height: 10),
            const _DashedDivider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PRODUCT CATALOG',
                  style: _thermalStyle(size: 10, bold: true),
                ),
                Text(
                  '${products.length}',
                  style: _thermalStyle(size: 10, bold: true),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date', style: _thermalStyle(size: 9)),
                Text(dateStr, style: _thermalStyle(size: 9)),
              ],
            ),
            const SizedBox(height: 8),
            const _DashedDivider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'ITEM',
                    style: _thermalStyle(size: 9, bold: true),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'PRICE',
                    textAlign: TextAlign.center,
                    style: _thermalStyle(size: 9, bold: true),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'STOCK',
                    textAlign: TextAlign.right,
                    style: _thermalStyle(size: 9, bold: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...products.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ${p.name}', style: _thermalStyle(size: 10)),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            '${p.sku} · ${p.categoryName ?? '—'}',
                            style: _thermalStyle(size: 9),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            formatPkr(p.sellingPriceMinor),
                            textAlign: TextAlign.center,
                            style: _thermalStyle(size: 9, bold: true),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            p.stockQty != null
                                ? '${p.stockQty} ${p.unit}'
                                : '—',
                            textAlign: TextAlign.right,
                            style: _thermalStyle(size: 9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            // ── Receipt-style footer ──
            const SizedBox(height: 4),
            const _DashedDivider(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.ink, width: 1.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL ITEMS',
                    style: _thermalStyle(size: 12, bold: true),
                  ),
                  Text(
                    '${products.length}',
                    style: _thermalStyle(size: 12, bold: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '***',
              textAlign: TextAlign.center,
              style: _thermalStyle(size: 10),
            ),
            const SizedBox(height: 14),
            Text(
              'END OF CATALOG',
              textAlign: TextAlign.center,
              style: _thermalStyle(size: 10, bold: true),
            ),
            const SizedBox(height: 6),
            Text(
              'Goods once sold will not be taken back.',
              textAlign: TextAlign.center,
              style: _thermalStyle(size: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Each "- " is 2 monospace characters (12px at size 10).
        final count = (constraints.maxWidth / 12).floor();
        return Text(
          '- ' * count,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
          style: _thermalStyle(size: 10),
        );
      },
    );
  }
}
