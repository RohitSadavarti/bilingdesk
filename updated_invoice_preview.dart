// Update the InvoicePreviewScreen class constructor and properties

class InvoicePreviewScreen extends StatelessWidget {
  final String customerName;
  final String customerAddress;
  final String invoiceNo;
  final String date;
  final List<InvoiceItem> items;
  final double totalAmount;
  final double advanceAmount;
  final double balanceAmount;
  final String numberToWords;
  final String? signaturePath; // Add signature path

  const InvoicePreviewScreen({
    Key? key,
    required this.customerName,
    required this.customerAddress,
    required this.invoiceNo,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.advanceAmount,
    required this.balanceAmount,
    required this.numberToWords,
    this.signaturePath, // Optional signature path
  }) : super(key: key);

  // Update the signature area in your build method
  Widget _buildSignatureArea() {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: signaturePath != null && File(signaturePath!).existsSync()
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(signaturePath!),
                      fit: BoxFit.contain,
                    ),
                  )
                : Center(
                    child: Text(
                      "🖋️\nSignature\nStamp",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ),
          ),
          SizedBox(height: 5),
          Text(
            "Authorised Signatory",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Updated PDF generation method with signature support
  Future<void> _generateAndPrintPDF(BuildContext context) async {
    final pdf = pw.Document();

    // Load signature image if available
    pw.ImageProvider? signatureImage;
    if (signaturePath != null && File(signaturePath!).existsSync()) {
      try {
        final signatureFile = File(signaturePath!);
        final signatureBytes = await signatureFile.readAsBytes();
        signatureImage = pw.MemoryImage(signatureBytes);
      } catch (e) {
        print('Error loading signature: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Header
              pw.Container(
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 2)),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(border: pw.Border.all()),
                          child: pw.Text('ॐ', style: pw.TextStyle(fontSize: 20)),
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('📞 8355836030', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('7666717724', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      'DNYANESHWAR TRANSPORT SERVICES',
                      style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 15),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('✉ dnyaneshwartransport@gmail.com'),
                        pw.Text('📍 Kamothe, Navi Mumbai - 410 209'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Invoice Title
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.symmetric(vertical: 12),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 2)),
                child: pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              
              // Customer Details
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                padding: pw.EdgeInsets.all(8),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("M/s.: $customerName", style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 5),
                          pw.Text("Add.: $customerAddress", style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    pw.Container(width: 1, height: 45, color: PdfColors.black),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Invoice No.: $invoiceNo", style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 5),
                          pw.Text("Date: $date", style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 10),
              
              // Bank details and signature
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("FOR DNYANESHWAR TRANSPORT SERVICE", style: pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 8),
                  pw.Text("BANK NAME: STATE BANK OF INDIA A/C. NO.: 20206528530", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text("BRANCH : KHANDESHWAR IFSC CODE: SBIN0016374", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(
                      children: [
                        pw.Container(
                          width: 100,
                          height: 60,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey, width: 1),
                          ),
                          child: signatureImage != null
                              ? pw.Image(signatureImage, fit: pw.BoxFit.contain)
                              : pw.Center(
                                  child: pw.Text(
                                    "Signature\nStamp",
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                                  ),
                                ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text("Authorised Signatory", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Table with items
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Table(
                  border: pw.TableBorder(
                    top: pw.BorderSide(),
                    bottom: pw.BorderSide(),
                    left: pw.BorderSide(),
                    right: pw.BorderSide(),
                    verticalInside: pw.BorderSide(),
                  ),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(40),
                    1: pw.FixedColumnWidth(80),
                    2: pw.FixedColumnWidth(100),
                    3: pw.FlexColumnWidth(),
                    4: pw.FixedColumnWidth(60),
                    5: pw.FixedColumnWidth(50),
                    6: pw.FixedColumnWidth(50),
                    7: pw.FixedColumnWidth(80),
                  },
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Container(padding: pw.EdgeInsets.all(4), child: pw.Text("Trip No.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                        pw.Container(padding: pw.EdgeInsets.all(4), child: pw.Text("Date", style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                        pw.Container(padding: pw.EdgeInsets.all(4), child: pw.Text("Vehicle No.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                        pw.Container(padding: pw.EdgeInsets.all(4), child: pw.Text("Particulars", style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                        pw.Container(padding: pw.EdgeInsets.all(4), child: pw.Text("Weight", style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                        pw.Container(padding: pw.EdgeInsets.all(4), child: pw.Text("Type", style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                        pw.Container(padding: pw.EdgeInsets.all(4), child: pw.Text("Adv.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                        pw.Container(padding: pw.EdgeInsets.all(4), child: pw.Text("Amount", style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      ],
                    ),
                    // Data rows
                    ...items.asMap().entries.map((entry) {
                      int index = entry.key;
                      InvoiceItem item = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Container(height: 25, padding: pw.EdgeInsets.all(4), child: pw.Text("${index + 1}", textAlign: pw.TextAlign.center)),
                          pw.Container(height: 25, padding: pw.EdgeInsets.all(4), child: pw.Text(item.date, textAlign: pw.TextAlign.center)),
                          pw.Container(height: 25, padding: pw.EdgeInsets.all(4), child: pw.Text(item.vehicleNo, textAlign: pw.TextAlign.center)),
                          pw.Container(height: 25, padding: pw.EdgeInsets.all(4), child: pw.Text(item.particulars, textAlign: pw.TextAlign.left)),
                          pw.Container(height: 25, padding: pw.EdgeInsets.all(4), child: pw.Text(item.weight, textAlign: pw.TextAlign.center)),
                          pw.Container(height: 25, padding: pw.EdgeInsets.all(4), child: pw.Text(item.type, textAlign: pw.TextAlign.center)),
                          pw.Container(height: 25, padding: pw.EdgeInsets.all(4), child: pw.Text(item.advance, textAlign: pw.TextAlign.center)),
                          pw.Container(height: 25, padding: pw.EdgeInsets.all(4), child: pw.Text(item.amount, textAlign: pw.TextAlign.center)),
                        ],
                      );
                    }).toList(),
                    // Blank rows
                    ...List.generate((items.length < 8 ? 8 - items.length : 0), (index) {
                      return pw.TableRow(
                        children: List.generate(8, (col) => pw.Container(height: 25)),
                      );
                    }),
                  ],
                ),
              ),
              
              // Footer with totals
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 25,
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 6,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide())),
                              child: pw.Text("TAX INVOICE - GST IS PAYABLE BY CONSIGNOR", style: pw.TextStyle(fontSize: 12)),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide())),
                              child: pw.Text("TOTAL", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text("₹${totalAmount.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(height: 1, color: PdfColors.black),
                    pw.Container(
                      height: 25,
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 6,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide())),
                              child: pw.Text("TAX INVOICE - GST IS PAYABLE BY TRANSPORTER", style: pw.TextStyle(fontSize: 12)),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide())),
                              child: pw.Text("ADVANCE", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text("₹${advanceAmount.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(height: 1, color: PdfColors.black),
                    pw.Container(
                      height: 25,
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 6,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide())),
                              child: pw.Text("RUPEES IN WORDS: ${numberToWords.toUpperCase()}", style: pw.TextStyle(fontSize: 12)),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide())),
                              child: pw.Text("BALANCE", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text("₹${balanceAmount.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(height: 1, color: PdfColors.black),
                    pw.Container(
                      height: 25,
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 6,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide())),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text("PAN No. AWZPN4133A PROPRIETOR", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                                  pw.Text("SHUBHAM NANDKUMAR NATE", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide())),
                              child: pw.Text("G-TOTAL", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text("₹${totalAmount.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                            ),
                          ),
                        