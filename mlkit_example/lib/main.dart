import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Text Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TextRecognitionPage(),
    );
  }
}

class TextRecognitionPage extends StatefulWidget {
  @override
  _TextRecognitionPageState createState() => _TextRecognitionPageState();
}

class _TextRecognitionPageState extends State<TextRecognitionPage> {
  File? _image; // Holds the selected image file
  String _recognizedText = ''; // Stores the recognized text
  final ImagePicker _picker = ImagePicker(); // For picking images

  // Method to pick an image from gallery or camera
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery); // Change to ImageSource.camera for camera
      if (image != null) {
        setState(() {
          _image = File(image.path); // Store the selected image
        });
        await _performTextRecognition(image.path); // Perform text recognition
      }
    } catch (e) {
      // Handle potential errors gracefully
      _showSnackbar('Error picking image: ${e.toString()}');
    }
  }

  // Method to perform text recognition using ML Kit
  Future<void> _performTextRecognition(String imagePath) async {
    final textRecognizer = GoogleMlKit.vision.textRecognizer(); // Initialize the text recognizer
    try {
      final inputImage = InputImage.fromFilePath(imagePath); // Prepare the input image
      final recognizedText = await textRecognizer.processImage(inputImage); // Process the image

      // Format the recognized text
      String formattedText = _formatRecognizedText(recognizedText.text);

      // Update the UI with formatted text
      setState(() {
        _recognizedText = formattedText;
      });
    } catch (e) {
      // Handle potential errors gracefully
      _showSnackbar('Error recognizing text: ${e.toString()}');
    } finally {
      textRecognizer.close(); // Close the recognizer
    }
  }

// Helper method to format recognized text
  String _formatRecognizedText(String text) {
    // Remove extra spaces and clean up the text
    return text
        .replaceAll('\n\n', '\n') // Replace double line breaks with a single line break
        .trim(); // Trim unnecessary whitespace from the start and end
  }


  // Helper method to show snackbars
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Display image or placeholder
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: _image != null ? 300 : 150, // Dynamic height based on image availability
                  width: double.infinity, // Full width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    color: Colors.grey[200], // Placeholder background
                  ),
                  child: _image == null
                      ? const Center(
                    child: Text(
                      'No image selected.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Clip corners
                    child: Image.file(
                      _image!,
                      fit: BoxFit.contain, // Adjust the fit as needed
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Failed to load image.',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Button to pick an image
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded button
                  ),
                ),
                child: const Text(
                  'Pick an Image',
                  style: TextStyle(fontSize: 16, color: Colors.white), // Button text style
                ),
              ),
              const SizedBox(height: 20),
              // Display recognized text
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color for text area
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  padding: const EdgeInsets.all(10),
                  child: _recognizedText.isEmpty
                      ? const Text(
                    'Recognized text will appear here.',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                    textAlign: TextAlign.center,
                  )
                      : InkWell(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: _recognizedText)); // Copy text to clipboard
                      _showSnackbar('Text copied to clipboard!');
                    },
                    child: Text(
                      _recognizedText,
                      style: const TextStyle(
                        fontSize: 16, // Adjust font size
                        color: Colors.black87, // Text color
                        height: 1.5, // Line height for better readability
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
