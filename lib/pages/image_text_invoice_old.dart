// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';

// class InvoiceScannerOld extends StatefulWidget {
//   @override
//   _InvoiceScannerOldState createState() => _InvoiceScannerOldState();
// }

// class _InvoiceScannerOldState extends State<InvoiceScannerOld> {
//   final ImagePicker _imagePicker = ImagePicker();
//   List<Map<String, dynamic>> invoiceProductDetails = [];
//   String statusMessage = 'No details extracted yet.';

//   Future<void> processInvoiceImage({bool isFromCamera = false}) async {
//     try {
//       // Allow user to upload or capture image
//       final XFile? imageFile = await _imagePicker.pickImage(
//         source: isFromCamera ? ImageSource.camera : ImageSource.gallery,
//       );
//       if (imageFile == null) return;

//       // Convert image to InputImage format for ML Kit
//       final inputImage = InputImage.fromFilePath(imageFile.path);

//       // Initialize TextRecognizer
//       final textRecognizer = TextRecognizer();

//       // Perform OCR on the image
//       final RecognizedText recognizedText =
//           await textRecognizer.processImage(inputImage);

//       // Extract product details and prices
//       List<Map<String, dynamic>> extractedDetails = [];
//       int idCounter = 1;

//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           // Regex to match the product lines (e.g., "1 HTS40R SOUND BAR...")
//           final productLineRegex = RegExp(
//               r'^\d+\s+(?<modelo>\w+)\s+(?<description>.+?)\s+(?<unit>\d+\.\d{2})\s+(?<total>\d+\.\d{2})$');

//           final match = productLineRegex.firstMatch(line.text);
//           if (match != null) {
//             extractedDetails.add({
//               'id': idCounter++,
//               'modelo': match.namedGroup('modelo') ?? '',
//               'description': match.namedGroup('description') ?? '',
//               'unit': match.namedGroup('unit') ?? '',
//               'total': match.namedGroup('total') ?? '',
//             });
//           }
//         }
//       }

//       // Update state
//       setState(() {
//         if (extractedDetails.isNotEmpty) {
//           invoiceProductDetails = extractedDetails;
//           statusMessage = 'Details extracted successfully!';
//         } else {
//           statusMessage = 'No product details found in the image.';
//         }
//       });

//       // Release resources
//       textRecognizer.close();
//     } catch (e) {
//       setState(() {
//         statusMessage = 'Error extracting details: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Invoice Scanner'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               statusMessage,
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: invoiceProductDetails.length,
//                 itemBuilder: (context, index) {
//                   final item = invoiceProductDetails[index];
//                   return Card(
//                     elevation: 4,
//                     margin: EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       title: Text('Product ${item['id']}'),
//                       subtitle: Text(
//                           'Model: ${item['modelo']}\nDescription: ${item['description']}\nUnit Price: ${item['unit']}\nTotal Price: ${item['total']}'),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () => processInvoiceImage(isFromCamera: false),
//               child: Text('Upload Invoice Image'),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () => processInvoiceImage(isFromCamera: true),
//               child: Text('Capture Invoice'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class InvoiceScannerOld extends StatefulWidget {
  @override
  _InvoiceScannerOldState createState() => _InvoiceScannerOldState();
}

class _InvoiceScannerOldState extends State<InvoiceScannerOld> {
  final ImagePicker _imagePicker = ImagePicker();
  String extractedDetails = 'No details extracted yet.';

  Future<void> processInvoiceImage({bool isFromCamera = false}) async {
    try {
      // Allow user to upload image or capture image from camera
      final XFile? imageFile = await _imagePicker.pickImage(
        source: isFromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (imageFile == null) return;

      // Convert image to InputImage format for ML Kit
      final inputImage = InputImage.fromFilePath(imageFile.path);

      // Initialize TextRecognizer
      final textRecognizer = TextRecognizer();

      // Perform OCR on the image
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      // Extract product details and prices
      List<String> productDetails = [];
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          // Match lines with product details and prices using regex
          if (RegExp(r'^(\d+)\s+HTS40R').hasMatch(line.text) ||
              RegExp(r'\d+\.\d{2}').hasMatch(line.text)) {
            productDetails.add(line.text);
          }
        }
      }

      // Update UI with extracted details
      setState(() {
        extractedDetails = productDetails.isNotEmpty
            ? productDetails.join('\n')
            : 'No product details found in the image.';
      });

      // Release resources
      textRecognizer.close();
    } catch (e) {
      setState(() {
        extractedDetails = 'Error extracting details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Scanner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                extractedDetails,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => processInvoiceImage(isFromCamera: false),
                child: Text('Upload Invoice Image'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => processInvoiceImage(isFromCamera: true),
                child: Text('Capture Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
