import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saaolhrmapp/BottomNavigationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constant/ConstantValues.dart';
import 'constant/ValidationCons.dart';
import 'constant/app_colors.dart';
import 'constant/network/ApiService.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool value = false;
  bool checkedValue = true;
  String mobileNumber = '';
  String storeKey = '';
  String googleID = '';
  bool _obscureText = true;
  late SharedPreferences sharedPreferences;
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? deviceModel;
  String? deviceID;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    _loadSavedCredentials();

  }

  Future<void> _saveCredentials() async {
    if (_rememberMe) {
      await _secureStorage.write(key: "username", value: userNameController.text);
      await _secureStorage.write(key: "password", value: userPasswordController.text);
    } else {
      await _secureStorage.delete(key: "username");
      await _secureStorage.delete(key: "password");
    }
  }

  Future<void> _loadSavedCredentials() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String? savedUsername = await _secureStorage.read(key: "username");
    String? savedPassword = await _secureStorage.read(key: "password");

    if (savedUsername != null && savedPassword != null) {
      setState(() {
        userNameController.text = savedUsername;
        userPasswordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }


  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      deviceID = androidInfo.id;
      print("Device Name: ${androidInfo.model}");
      print("Device ID: ${androidInfo.id}"); // Unique hardware ID
      print("Device Model: $deviceModel"); // Unique hardware ID
      print("Device MainID: $deviceID"); // Unique hardware ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print("Device Name: ${iosInfo.name}");
      print(
          "Device ID: ${iosInfo.identifierForVendor}"); // Unique ID for the app
    }
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


  Future<void> userLogin() async {
    final userName = userNameController.text.trim();
    String password = userPasswordController.text.trim();
    if (userName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials and try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection. Please check your network."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if no internet
    }
    _showLoadingDialog();
    try {
      final loginResponse = await _apiService.login(
          userName,
          password,
          deviceModel.toString(),
          deviceID.toString()
      );
      Navigator.pop(context); // Hide loading dialog
      if (loginResponse != null && loginResponse.accessToken != null) {
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setBool(ApiConstant.IS_LOGIN, true);
        await _saveCredentials();
        print('AccessToken: ${loginResponse.accessToken}');
        await _apiService.getUserDetails();
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const BottomNavigationScreen(initialIndex: 0)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to login. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on SocketException {
      Navigator.pop(context); // Hide loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection. Please check your network."),
          backgroundColor: Colors.red,
        ),
      );
    } on TimeoutException {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request timed out.Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } on Exception catch (error) {
      Navigator.pop(context);
      String errorMessage = error.toString();
      if (errorMessage.contains("Access denied for this user")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Access denied for this user"),
            backgroundColor: Colors.red,
          ),
        );
      }
      else if (errorMessage.contains("Unauthorized")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Incorrect username or password. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      } else if (errorMessage.contains("SocketException")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No internet connection. Please check your network."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, left: 5, right: 5),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(200, 253, 106, 111),
                    Color.fromARGB(200, 255, 155, 68),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Center(
                    child: Image(
                      image: AssetImage('assets/images/saool_logo.png'),
                      width: 120,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Center(
                    child: Text(
                      'HRM Login',
                      style: TextStyle(
                          fontFamily: 'FontPoppins',
                          fontSize: 23,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 40),
                    child: Card(
                      color: Colors.white,
                      elevation: 1, // Adds shadow to the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            15), // Rounded corners for the card
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15, left: 12, right: 12, bottom: 10),
                        // Inner padding for the card content
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Form(
                              key: _formKey,
                              autovalidateMode: autovalidateMode,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Username',
                                    style: TextStyle(
                                        fontFamily: 'FontPoppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    keyboardType: TextInputType.name,
                                    controller: userNameController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your username',
                                      hintStyle: const TextStyle(
                                          fontFamily: 'FontPoppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54),
                                      prefixIcon: const Icon(Icons.contact_page,
                                          color: AppColors.primaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 20.0),
                                      filled: true,
                                      fillColor: Colors.orange[50],
                                    ),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'FontPoppins',
                                        fontSize: 16,
                                        color: Colors.black),
                                    validator: ValidationCons().validateName,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                        fontFamily: 'FontPoppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: userPasswordController,
                                    obscureText: _obscureText,
                                    decoration: InputDecoration(
                                      hintText: 'Enter password',
                                      hintStyle: const TextStyle(
                                          fontFamily: 'FontPoppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54),
                                      prefixIcon: const Icon(Icons.lock,
                                          color: AppColors.primaryColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: AppColors.primaryColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: Colors.orange[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 20.0),
                                    ),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'FontPoppins',
                                        fontSize: 16,
                                        color: Colors.black),
                                    validator:
                                        ValidationCons().validatePassword,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height:20),
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _rememberMe = newValue!;
                                    });
                                  },
                                  activeColor: AppColors.primaryColor,
                                ),
                                const Text(
                                  "Remember Me",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                                      fontFamily:'FontPoppins',color:Colors.black87,),
                                ),
                              ],
                            ),
                            const SizedBox(height:20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(200, 253, 106, 111),
                                      Color.fromARGB(200, 255, 155, 68),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      userLogin();
                                    } else {
                                      setState(() {
                                        autovalidateMode =
                                            AutovalidateMode.always;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                          color: Colors.white, width: 0.1),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
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
                            const SizedBox(height: 20),
                          ],
                        ),
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
