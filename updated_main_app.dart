// Add this to your existing _BillingAppState class

class _BillingAppState extends State<BillingApp> {
  // ... existing code ...
  
  // Add signature path variable
  String? _signaturePath;

  // Add this method to handle signature capture
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signature captured successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Add this method to remove signature
  void _removeSignature() {
    setState(() {
      _signaturePath = null;
    });
  }

  // Update the _goToPreview method to include signature
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
            signaturePath: _signaturePath, // Pass signature path
          ),
        ),
      );
    }
  }

  // Add signature section to your form (add this after the Totals section)
  Widget _buildSignatureSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signature', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            if (_signaturePath != null)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_signaturePath!),
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              )
            else
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.draw, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No signature captured',
                        style: TextStyle(color: Colors.grey[600]),
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Update your _buildDataEntryForm method to include the signature section
  // Add this line after the Totals section and before Action Buttons:
  // _buildSignatureSection(),
  // SizedBox(height: 20),
}