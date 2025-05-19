import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'constant/app_colors.dart';
import 'constant/network/ApiService.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, String>> faqs = [
    {
      "question": "How do I check in?",
      "answer":
          "To check in, go to the main screen and tap the 'Check In' button."
    },
    {
      "question": "How does the background tracking work?",
      "answer":
          "Once checked in, the app continues tracking your time even when closed."
    },
    {
      "question": "How can I contact support?",
      "answer":
          "You can contact support via email or phone from the 'Contact Us' section below."
    },
  ];
  TextEditingController reasonController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  final ApiService _apiService = ApiService();

  Future<void> pickImage() async {
    final pickedFiles =
        await _picker.pickMultiImage(); // Allow multiple image selection

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<File> selectedImages = [];

      for (var pickedFile in pickedFiles) {
        File originalFile = File(pickedFile.path);
        print("Original Image Path: ${originalFile.path}"); // Print image path
        // Validate file size (must be < 2MB)
        int maxSizeInBytes = 2048 * 1024; // 2MB
        if (originalFile.lengthSync() > maxSizeInBytes) {
          File? compressedImage = await compressImage(originalFile);

          if (compressedImage != null &&
              compressedImage.lengthSync() <= maxSizeInBytes) {
            selectedImages.add(compressedImage);
          } else {
            showSnackBar("Some images exceed 2MB and were not added");
          }
        } else {
          selectedImages.add(originalFile);
        }
      }

      setState(() {
        _images.addAll(selectedImages); // Append images to the list
      });
    }
  }
  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        "${dir.absolute.path}/compressed_${file.path.split('/').last}";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return result != null ? File(result.path) : null;
  }
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: 70.0,
          height: 70.0,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(200, 253, 106, 111),
                Color.fromARGB(200, 255, 155, 68),
              ],
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: CupertinoActivityIndicator(
              color: Colors.white,
              radius: 20,
            ),
          ),
        ),
      ),
    );
  }

  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> submitFeedback() async {
    String reason = reasonController.text.trim();
    if (reason.isEmpty) {
      showSnackBar("Please enter a reason");
      return;
    }
    if (_images.isEmpty) {
      showSnackBar("Please select at least one image");
      return;
    }
    _showLoadingDialog();
    await _apiService.feedback(reason, _images, context);
    Navigator.pop(context); // Close the loading dialog
    Navigator.pop(context); // Navigate back to the previous screen

  }

  void launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mohdmuratib0@gmail.com',
      query: 'subject=Support Request&body=Hi, I need help with...',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print('Could not launch email client');

    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');

    if (!await launchUrl(phoneUri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $phoneUri';
    }
  }
  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=Hello&body=I would like to contact you'),
    );

    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $emailUri';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.grey[200],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Help & Support",
          style: TextStyle(
            fontFamily: 'FontPoppins',
            fontSize: 18,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const Image(
                      image: AssetImage('assets/images/help_and_support.png'),
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  ),
                  const SizedBox(width:20), // spacing between image and text
                  const Expanded(
                    child: Text(
                      'Hello, How can we\nhelp you?',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'FontPoppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),

              Row(mainAxisAlignment:MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _makePhoneCall('9318404512');
                    },
                    icon:  const Icon(Icons.call, color: AppColors.primaryColor),
                    label:  const Text(
                      'Call',
                      style: TextStyle(
                        fontFamily: 'FontPoppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor:Colors.white,
                      side:  BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      _sendEmail('info@saaolinfotech.com');
                    },
                    icon:  const Icon(Icons.directions, color: AppColors.primaryColor),
                    label:  const Text(
                      'Email',
                      style: TextStyle(
                        fontFamily: 'FontPoppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor:Colors.white,
                      side:  const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height:15,),
              const Divider(
                thickness: 1,
                color: AppColors.gradientBG,
                height: 30,
              ),
              const Text(
                'Reason',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'FontPoppins',
                    fontSize: 15,
                    color: Colors.black87),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter your reason",
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'FontPoppins',
                      fontSize: 15,
                      color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      // Change this to your desired color
                      width: 1.0, // Adjust the width if necessary
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      // Change this to your desired color for normal state
                      width: 1.0, // Adjust the width if necessary
                    ),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'FontPoppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 253, 106, 111),
                          Color.fromARGB(200, 255, 155, 68),
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.add, size: 24, color: Colors.white),
                      onPressed: pickImage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Add & Upload Images',
                    style: TextStyle(
                        fontSize:14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'FontPoppins'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _images.isNotEmpty
                  ? Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _images.asMap().entries.map((entry) {
                        int index = entry.key;
                        File image = entry.value;
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => removeImage(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close,
                                      size: 13, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    )
                  : Container(),
              const SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 45,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 253, 106, 111),
                        Color.fromARGB(200, 255, 155, 68),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      submitFeedback();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.white, width: 0.1),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'FontPoppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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

