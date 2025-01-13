import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class InvoiceScanner extends StatefulWidget {
  @override
  _InvoiceScannerState createState() => _InvoiceScannerState();
}

class _InvoiceScannerState extends State<InvoiceScanner> {
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, String>> extractedProducts = [];
  String statusMessage = 'No details extracted yet.';

  Future<void> processInvoiceImage({bool isFromCamera = false}) async {
    try {
      // Allow user to upload or capture an image
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

      // Debug: Print all extracted text
      print('Extracted Text:');
      List<String> lines = [];
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          print(line.text);
          lines.add(line.text);
        }
      }

      print('lines=> $lines');
      // Parse lines to extract product details dynamically
      // extractedProducts = extractTableData(lines);
      extractTableData(lines);

      // print('extractedProducts=> $extractedProducts');

      // Update UI
      // setState(() {
      //   if (extractedProducts.isNotEmpty) {
      //     statusMessage = 'Details extracted successfully!';
      //   } else {
      //     statusMessage = 'No product details found in the image.';
      //   }
      // });

      setState(() {
        if (lines.isNotEmpty) {
          statusMessage = 'Details extracted successfully!';
        } else {
          statusMessage = 'No product details found in the image.';
        }
      });

      // Release resources
      textRecognizer.close();
    } catch (e) {
      setState(() {
        statusMessage = 'Error extracting details: $e';
      });
    }
  }

  List<Map<String, String>> extractTableData(List<String> lines) {
    print('extractTableData-lines=> $lines');
    List<Map<String, String>> products = [];
    bool tableStarted = false;

    // Iterate through each line of extracted text
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      print('extract-lines=> $line');
      extractedProducts.add({line: line});

      // Detect the table header
      if (line.contains('Cant.') && line.contains('Modelo')) {
        tableStarted = true;
        print('Table header detected: $line');
        continue;
      }

      // Parse rows once the table header is detected
      if (tableStarted) {
        // Break the loop if unrelated footer content is detected
        if (line.toLowerCase().contains('subtotal') ||
            line.toLowerCase().contains('total')) {
          print('Footer detected, stopping table parsing.');
          break;
        }

        // Split the line dynamically into columns based on spaces
        List<String> columns = line.split(RegExp(r'\s{2,}'));
        print('Processing line: $line');
        print('Columns: $columns');

        // Ensure there are enough columns to match the table structure
        // if (columns.length >= 5) {
        // products.add({
        //   "Cant.": columns[0].trim(),
        //   "Modelo": columns[1].trim(),
        //   "Descripción": columns[2].trim(),
        //   "Pr. Unit.": columns[3].trim(),
        //   "Pr. Total.": columns[4].trim(),
        // });

        // } else {
        //   print('Skipping line: Not enough columns.');
        // }
      }
    }

    print('Extracted Products: $products');
    return products;
  }

  // List<Map<String, String>> extractTableData(List<String> lines) {
  //   List<Map<String, String>> products = [];
  //   bool tableStarted = false;

  //   for (var line in lines) {
  //     // Identify start of the table by detecting the headers
  //     if (line.contains('Cant.') && line.contains('Modelo')) {
  //       tableStarted = true;
  //       continue;
  //     }

  //     // Extract rows from the table
  //     if (tableStarted) {
  //       // Break the loop if the table ends (you can add logic for footer detection)
  //       if (line.trim().isEmpty) break;

  //       // Split the line into columns dynamically
  //       List<String> columns =
  //           line.split(RegExp(r'\s{2,}')); // Split on multiple spaces
  //       if (columns.length >= 5) {
  //         products.add({
  //           "Cant.": columns[0],
  //           "Modelo": columns[1],
  //           "Descripción": columns[2],
  //           "Pr. Unit.": columns[3],
  //           "Pr. Total.": columns[4],
  //         });
  //       }
  //     }
  //   }

  //   return products;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Scanner'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusMessage,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                extractedProducts.map((product) {
                  return product.entries
                      .map((entry) => '${entry.key}: ${entry.value}')
                      .join('\n');
                }).join('\n\n'),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: extractedProducts.length,
              //     itemBuilder: (context, index) {
              //       final product = extractedProducts[index];
              //       return Card(
              //         elevation: 4,
              //         margin: EdgeInsets.symmetric(vertical: 8),
              //         child: ListTile(
              //           title: Text('Product ${index + 1}'),
              //           subtitle: Text(
              //             'Cant: ${product["Cant."]}\n'
              //             'Modelo: ${product["Modelo"]}\n'
              //             'Descripción: ${product["Descripción"]}\n'
              //             'Pr. Unit.: ${product["Pr. Unit."]}\n'
              //             'Pr. Total.: ${product["Pr. Total."]}',
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
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



// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';

// class InvoiceScanner extends StatefulWidget {
//   @override
//   _InvoiceScannerState createState() => _InvoiceScannerState();
// }

// class _InvoiceScannerState extends State<InvoiceScanner> {
//   final ImagePicker _imagePicker = ImagePicker();
//   List<Map<String, dynamic>> extractedProducts = [];
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

//       // Debug: Print all extracted text
//       print('Extracted Text:');
//       List<String> lines = [];
//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           print(line.text);
//           lines.add(line.text);
//         }
//       }

//       // Combine lines to group product details
//       extractedProducts = extractProductsFromLines(lines);

//       // Update UI
//       setState(() {
//         if (extractedProducts.isNotEmpty) {
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

//   List<Map<String, dynamic>> extractProductsFromLines(List<String> lines) {
//     List<Map<String, dynamic>> products = [];
//     int idCounter = 1;

//     for (int i = 0; i < lines.length; i++) {
//       if (lines[i].contains('Cant.') && i + 2 < lines.length) {
//         String modelo = lines[i + 1].trim(); // Extract "HTS40R"
//         String description =
//             lines[i + 2].trim(); // Extract "SOUND BAR SONY 5.1CH NEGRO"
//         String unitPrice = "265.95"; // Placeholder (update logic if needed)
//         String totalPrice = "265.95"; // Placeholder (update logic if needed)

//         products.add({
//           "id": idCounter++,
//           "modelo": modelo,
//           "description": description,
//           "unit": unitPrice,
//           "total": totalPrice,
//         });

//         // Skip processed lines
//         i += 2;
//       }
//     }

//     return products;
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
//                 itemCount: extractedProducts.length,
//                 itemBuilder: (context, index) {
//                   final product = extractedProducts[index];
//                   return Card(
//                     elevation: 4,
//                     margin: EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       title: Text('Product ${product['id']}'),
//                       subtitle: Text(
//                           'Model: ${product['modelo']}\nDescription: ${product['description']}\nUnit Price: ${product['unit']}\nTotal Price: ${product['total']}'),
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


// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';

// class InvoiceScanner extends StatefulWidget {
//   @override
//   _InvoiceScannerState createState() => _InvoiceScannerState();
// }

// class _InvoiceScannerState extends State<InvoiceScanner> {
//   final ImagePicker _imagePicker = ImagePicker();
//   List<Map<String, dynamic>> extractedProducts = [];
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

//       // Debug: Print all extracted text
//       print('Extracted Text:');
//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           print(line.text);
//         }
//       }

//       // Extract product details and prices
//       List<Map<String, dynamic>> products = [];
//       int idCounter = 1;

//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           // Update regex based on the text structure
//           final productLineRegex = RegExp(
//               r'^(?<id>\d+)\s+(?<modelo>[A-Z0-9]+)\s+(?<description>.+?)\s+(?<unit>\d+\.\d{2})\s+(?<total>\d+\.\d{2})$');
//           final match = productLineRegex.firstMatch(line.text);

//           if (match != null) {
//             products.add({
//               "id": idCounter++,
//               "modelo": match.namedGroup('modelo') ?? '',
//               "description": match.namedGroup('description') ?? '',
//               "unit": match.namedGroup('unit') ?? '',
//               "total": match.namedGroup('total') ?? '',
//             });

//             print('products=> $products');
//           }
//         }
//       }

//       // Update UI with extracted details
//       setState(() {
//         if (products.isNotEmpty) {
//           extractedProducts = products;
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
//                 itemCount: extractedProducts.length,
//                 itemBuilder: (context, index) {
//                   final product = extractedProducts[index];
//                   return Card(
//                     elevation: 4,
//                     margin: EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       title: Text('Product ${product['id']}'),
//                       subtitle: Text(
//                           'Model: ${product['modelo']}\nDescription: ${product['description']}\nUnit Price: ${product['unit']}\nTotal Price: ${product['total']}'),
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



// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';

// class InvoiceScanner extends StatefulWidget {
//   @override
//   _InvoiceScannerState createState() => _InvoiceScannerState();
// }

// class _InvoiceScannerState extends State<InvoiceScanner> {
//   final ImagePicker _imagePicker = ImagePicker();
//   String extractedDetails = 'No details extracted yet.';

//   Future<void> processInvoiceImage({bool isFromCamera = false}) async {
//     try {
//       // Allow user to upload image or capture image from camera
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
//       List<String> productDetails = [];
//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           // Match lines with product details and prices using regex
//           if (RegExp(r'^(\d+)\s+HTS40R').hasMatch(line.text) ||
//               RegExp(r'\d+\.\d{2}').hasMatch(line.text)) {
//             print('line=> ${line.text}');
//             productDetails.add(line.text);
//           }
//         }
//       }

//       // Update UI with extracted details
//       setState(() {
//         extractedDetails = productDetails.isNotEmpty
//             ? productDetails.join('\n')
//             : 'No product details found in the image.';
//       });

//       // Release resources
//       textRecognizer.close();
//     } catch (e) {
//       setState(() {
//         extractedDetails = 'Error extracting details: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Invoice Scanner'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 extractedDetails,
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => processInvoiceImage(isFromCamera: false),
//                 child: Text('Upload Invoice Image'),
//               ),
//               SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () => processInvoiceImage(isFromCamera: true),
//                 child: Text('Capture Invoice'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
