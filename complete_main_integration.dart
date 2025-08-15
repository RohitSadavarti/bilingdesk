import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';

// Add your SignatureCaptureScreen and SignatureManager imports here

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

  // Signature management
  String? _signaturePath;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
    // Clean up old signatures when app starts
    SignatureManager.cleanupOldSignatures();
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

  // Signature capture functionality
  Future<void> _captureSignature() async {
    final String? signaturePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => SignatureCaptureScreen(),
      ),
    );
    
    if (signaturePath != null) {
      setState(() {
        _signaturePath = signaturePath;
      });
      
      // Show file size info
      final double fileSize = await SignatureManager.getSignatureFileSize(signaturePath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signature captured successfully (${fileSize.toStringAsFixed(1)} KB)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _removeSignature() {
    setState(() {
      _signaturePath = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signature removed'),
        backgroundColor: Colors.orange,
      ),
    );
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
            signaturePath: _signaturePath,
          ),
        ),
      );
    }
  }

  Widget _buildSignatureSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signature', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: _signaturePath == null ? Colors.grey[50] : Colors.white,
              ),
              child: _signaturePath != null && SignatureManager.validateSignatureFile(_signaturePath)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_signaturePath!),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, size: 48, color: Colors.red),
                                SizedBox(height: 8),
                                Text('Error loading signature', 
                                  style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.draw, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'No signature captured',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap "Capture Signature" to add',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_signaturePath != null) ...[
                  ElevatedButton.icon(
                    onPressed: _removeSignature,
                    icon: Icon(Icons.delete),
                    label: Text('Remove'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                ],
                ElevatedButton.icon(
                  onPressed: _captureSignature,
                  icon: Icon(Icons.draw),
                  label: Text(_signaturePath != null ? 'Update Signature' : 'Capture Signature'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            // Show signature info if available
            if (_signaturePath != null)
              FutureBuilder<double>(
                future: SignatureManager.getSignatureFileSize(_signaturePath!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'File size: ${snapshot.data!.toStringAsFixed(1)} KB',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
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
            
            SizedBox(height: 20),
            
            // Signature Section
            _buildSignatureSection(),
            
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
                