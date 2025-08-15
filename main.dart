import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dnyaneshwar Transport Services - Billing App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BillingApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BillingApp extends StatefulWidget {
  @override
  _BillingAppState createState() => _BillingAppState();
}

class InvoiceItem {
  String tripNo;
  String date;
  String vehicleNo;
  String particulars;
  String weight;
  String type;
  String advance;
  String amount;

  InvoiceItem({
    this.tripNo = '',
    this.date = '',
    this.vehicleNo = '',
    this.particulars = '',
    this.weight = '',
    this.type = '',
    this.advance = '',
    this.amount = '',
  });
}

class _BillingAppState extends State<BillingApp> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _invoiceNoController = TextEditingController();
  final _dateController = TextEditingController();
  
  List<InvoiceItem> items = [InvoiceItem()];
  
  double totalAmount = 0.0;
  double advanceAmount = 0.0;
  double balanceAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  void _addNewItem() {
    setState(() {
      items.add(InvoiceItem());
    });
  }

  void _removeItem(int index) {
    setState(() {
      if (items.length > 1) {
        items.removeAt(index);
        _calculateTotals();
      }
    });
  }

  void _calculateTotals() {
    double total = 0.0;
    double advance = 0.0;
    
    for (var item in items) {
      if (item.amount.isNotEmpty) {
        total += double.tryParse(item.amount) ?? 0.0;
      }
      if (item.advance.isNotEmpty) {
        advance += double.tryParse(item.advance) ?? 0.0;
      }
    }
    
    setState(() {
      totalAmount = total;
      advanceAmount = advance;
      balanceAmount = total - advance;
    });
  }

  String _numberToWords(double number) {
    if (number == 0) return "Zero Rupees Only";
    
    List<String> ones = [
      "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
      "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
      "Seventeen", "Eighteen", "Nineteen"
    ];
    
    List<String> tens = [
      "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
    ];
    
    List<String> thousands = ["", "Thousand", "Lakh", "Crore"];
    
    int intNumber = number.toInt();
    if (intNumber == 0) return "Zero Rupees Only";
    
    String result = "";
    int thousandCounter = 0;
    
    while (intNumber > 0) {
      int chunk = 0;
      if (thousandCounter == 0) {
        chunk = intNumber % 1000;
        intNumber ~/= 1000;
      } else if (thousandCounter == 1) {
        chunk = intNumber % 100;
        intNumber ~/= 100;
      } else {
        chunk = intNumber % 100;
        intNumber ~/= 100;
      }
      
      if (chunk != 0) {
        String chunkStr = "";
        
        if (chunk >= 100) {
          chunkStr += ones[chunk ~/ 100] + " Hundred ";
          chunk %= 100;
        }
        
        if (chunk >= 20) {
          chunkStr += tens[chunk ~/ 10];
          if (chunk % 10 != 0) {
            chunkStr += " " + ones[chunk % 10];
          }
        } else if (chunk > 0) {
          chunkStr += ones[chunk];
        }
        
        result = chunkStr + " " + thousands[thousandCounter] + " " + result;
      }
      thousandCounter++;
    }
    
    return result.trim() + " Rupees Only";
  }

  void _goToPreview() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoicePreviewScreen(
            customerName: _customerNameController.text,
            customerAddress: _customerAddressController.text,
            invoiceNo: _invoiceNoController.text,
            date: _dateController.text,
            items: items,
            totalAmount: totalAmount,
            advanceAmount: advanceAmount,
            balanceAmount: balanceAmount,
            numberToWords: _numberToWords(balanceAmount),
          ),
        ),
      );
    }
  }

  Widget _buildDataEntryForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Invoice Data Entry',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Customer Details
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _customerAddressController,
                      decoration: InputDecoration(
                        labelText: 'Customer Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter customer address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _invoiceNoController,
                            decoration: InputDecoration(
                              labelText: 'Invoice Number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter invoice number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Invoice Items
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Invoice Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: _addNewItem,
                          icon: Icon(Icons.add),
                          label: Text('Add Item'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    ...List.generate(items.length, (index) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Item ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  if (items.length > 1)
                                    IconButton(
                                      onPressed: () => _removeItem(index),
                                      icon: Icon(Icons.delete, color: Colors.red),
                                    ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Trip No.',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        items[index].tripNo = value;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Date',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        items[index].date = value;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Vehicle No.',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        items[index].vehicleNo = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Particulars',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        items[index].particulars = value;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Weight',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        items[index].weight = value;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Type',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        items[index].type = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Advance',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        items[index].advance = value;
                                        _calculateTotals();
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Amount',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        items[index].amount = value;
                                        _calculateTotals();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Totals Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Totals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('₹${totalAmount.toStringAsFixed(2)}', 
                              style: TextStyle(fontSize: 18, color: Colors.green)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Advance Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('₹${advanceAmount.toStringAsFixed(2)}', 
                              style: TextStyle(fontSize: 18, color: Colors.orange)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Balance Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('₹${balanceAmount.toStringAsFixed(2)}', 
                              style: TextStyle(fontSize: 18, color: Colors.blue)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Action Buttons
            ElevatedButton.icon(
              onPressed: _goToPreview,
              icon: Icon(Icons.preview),
              label: Text('Preview Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dnyaneshwar Transport - Billing'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _buildDataEntryForm(),
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _invoiceNoController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

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
  }) : super(key: key);

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: Text('ॐ', style: TextStyle(fontSize: 20)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('📞 8355836030', style: TextStyle(fontSize: 12)),
                Text('7666717724', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          "DNYANESHWAR TRANSPORT SERVICES",
          style: TextStyle(
            fontSize: 30, 
            fontWeight: FontWeight.bold, 
            color: Colors.orange,
            fontFamily: 'Times New Roman'
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("📧 dnyaneshwartransport@gmail.com", 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text("📌 Kamothe, Navi Mumbai - 410 209", 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerDetails() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("M/s.: $customerName", style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                Text("Add.: $customerAddress", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Container(width: 1, height: 45, color: Colors.black, margin: EdgeInsets.symmetric(horizontal: 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Invoice No.: $invoiceNo", style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                Text("Date: $date", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Container(
      padding: EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFooterRow(String leftText, String rightLabel, double amount) {
    return Container(
      height: 30,
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black, width: 1)),
              ),
              child: Text(leftText, style: TextStyle(fontSize: 12)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black, width: 1)),
              ),
              child: Text(
                rightLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(4),
              child: Text(
                "₹${amount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndPrintPDF(BuildContext context) async {
    final pdf = pw.Document();

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
              
              // Customer Details and rest of PDF content...
              // (PDF generation code continues here)
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    int blankRows = items.isEmpty ? 8 : (items.length < 8 ? 8 : items.length);

    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice Preview"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _generateAndPrintPDF(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    "INVOICE",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _buildCustomerDetails(),
              SizedBox(height: 10),
              
              // ===== TABLE WITHOUT HORIZONTAL LINES =====
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Table(
                  border: TableBorder(
                    top: BorderSide(color: Colors.black, width: 1),
                    bottom: BorderSide(color: Colors.black, width: 1),
                    left: BorderSide(color: Colors.black, width: 1),
                    right: BorderSide(color: Colors.black, width: 1),
                    verticalInside: BorderSide(color: Colors.black, width: 1),
                    horizontalInside: BorderSide.none, // NO HORIZONTAL LINES
                  ),
                  columnWidths: const {
                    0: FixedColumnWidth(40),
                    1: FixedColumnWidth(80),
                    2: FixedColumnWidth(100),
                    3: FlexColumnWidth(),
                    4: FixedColumnWidth(60),
                    5: FixedColumnWidth(50),
                    6: FixedColumnWidth(50),
                    7: FixedColumnWidth(80),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: [
                        _tableHeaderCell("Trip No."),
                        _tableHeaderCell("Date"),
                        _tableHeaderCell("Vehicle No."),
                        _tableHeaderCell("Particulars"),
                        _tableHeaderCell("Weight"),
                        _tableHeaderCell("Type"),
                        _tableHeaderCell("Adv."),
                        _tableHeaderCell("Amount"),
                      ],
                    ),
                    // Dynamic rows from items list
                    for (int i = 0; i < items.length; i++)
                      TableRow(
                        children: [
                          Container(height: 35, padding: EdgeInsets.all(4), child: Text("${i + 1}", textAlign: TextAlign.center)),
                          Container(height: 35, padding: EdgeInsets.all(4), child: Text(items[i].date, textAlign: TextAlign.center)),
                          Container(height: 35, padding: EdgeInsets.all(4), child: Text(items[i].vehicleNo, textAlign: TextAlign.center)),
                          Container(height: 35, padding: EdgeInsets.all(4), child: Text(items[i].particulars, textAlign: TextAlign.left)),
                          Container(height: 35, padding: EdgeInsets.all(4), child: Text(items[i].weight, textAlign: TextAlign.center)),
                          Container(height: 35, padding: EdgeInsets.all(4), child: Text(items[i].type, textAlign: TextAlign.center)),
                          Container(height: 35, padding: EdgeInsets.all(4), child: Text(items[i].advance, textAlign: TextAlign.center)),
                          Container(height: 35, padding: EdgeInsets.all(4), child: Text(items[i].amount, textAlign: TextAlign.center)),
                        ],
                      ),
                    // Blank rows for handwriting
                    for (int i = items.length; i < blankRows; i++)
                      TableRow(
                        children: List.generate(8, (col) => Container(height: 35)),
                      ),
                  ],
                ),
              ),
              
              SizedBox(height: 5),
              
              // ===== FOOTER SECTION =====
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Column(
                  children: [
                    _buildFooterRow("TAX INVOICE - GST IS PAYABLE BY CONSIGNOR", "TOTAL", totalAmount),
                    Container(height: 1, color: Colors.black), // Separator line
                    _buildFooterRow("TAX INVOICE - GST IS PAYABLE BY TRANSPORTER", "ADVANCE", advanceAmount),
                    Container(height: 1, color: Colors.black), // Separator line
                    _buildFooterRow("RUPEES IN WORDS: ${numberToWords.toUpperCase()}", "BALANCE", balanceAmount),
                    Container(height: 1, color: Colors.black), // Separator line
                    Container(
                      height: 30,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.black, width: 1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("PAN No. AWZPN4133A PROPRIETOR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text("SHUBHAM NANDKUMAR NATE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.black, width: 1)),
                              ),
                              child: Text(
                                "G-TOTAL",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: Text(
                                "₹${totalAmount.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 10),
              
              // ===== BANK & SIGNATURE =====
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FOR DNYANESHWAR TRANSPORT SERVICE",
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "BANK NAME: STATE BANK OF INDIA A/C. NO.: 20206528530",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "BRANCH : KHANDESHWAR IFSC CODE: SBIN0016374",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}