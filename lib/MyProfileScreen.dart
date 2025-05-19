import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HelpSupportScree.dart';
import 'LoginScreen.dart';
import 'constant/ConstantValues.dart';
import 'constant/app_colors.dart';
import 'constant/network/ApiService.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {

  String userName = '';
  String userEmail = '';
  String userMobile = '';
  String joinDate = '';
  String team = '';
  String department = '';
  String designation = '';
  String? image;
  final ApiService _apiService = ApiService();


  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString(ApiConstant.NAME) ?? 'N/A';
      team = prefs.getString(ApiConstant.TEAM) ?? 'N/A';
      department = prefs.getString(ApiConstant.DEPARTMENT) ?? 'N/A';
      designation = prefs.getString(ApiConstant.DESIGNATION) ?? 'N/A';
      image = prefs.getString('Image') ?? 'N/A';
      userEmail = prefs.getString(ApiConstant.EMAIL) ?? 'N/A';
      userMobile = prefs.getString(ApiConstant.MOBILE) ?? 'N/A';
      print('Name:$userName');

    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    return Scaffold(
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 170,
                  padding: const EdgeInsets.only(top:45,left:10,right:10),
                  width: double.infinity,
                  decoration:const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 253, 106, 111),
                        Color.fromARGB(200, 255, 155, 68),
                      ],
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'My Profile',
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'FontPoppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.03,
                      right: screenWidth * 0.03,
                      top: screenHeight * 0.13),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    child: Container(
                      height: screenHeight * 0.16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:const Column(
                        children: [],
                      ),
                    ),
                  ),
                ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.09),
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval( // Ensures the image stays inside the circle
                    child: Image.network(
                      image.toString(),
                      fit: BoxFit.cover, // Ensures the image fills the circular space properly
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person, // Default icon in case of an error
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userName.isNotEmpty
                    ? '${userName[0].toUpperCase()}${userName.substring(1)}'
                    : '',
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'FontPoppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    designation,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'FontPoppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Container(
                    height: screenHeight * 0.02,
                    width: 1,
                    color: Colors.grey,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    '$team department',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'FontPoppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                joinDate.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'FontPoppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        ],
            ),
            const Padding(
              padding: EdgeInsets.only(left:15,top:10),
              child: Text(
                'Personal Information',
                style: TextStyle(
                    fontSize:16,
                    fontFamily: 'FontPoppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildInfoText('Center Name',department),
                        Divider(
                          height: screenHeight * 0.03,
                          color: Colors.black87,
                          thickness: 0.2,
                        ),
                        _buildInfoText('Phone',userMobile.toString()),
                        Divider(
                          height: screenHeight * 0.03,
                          color: Colors.black87,
                          thickness: 0.2,
                        ),
                        _buildInfoText('Email',userEmail.toString()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /*GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                          child: const Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.privacy_tip,
                                    size: 25,
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'FontPoppins',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.black,
                                    size: 14,
                                  )
                                ],
                              ),
                              Divider(
                                height: 30,
                                color: Colors.black87,
                                thickness: 0.2,
                              ),
                            ],
                          ),
                        ),*/
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                 const HelpSupportScreen(),
                              ),
                            );
                          },
                          child: const Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.help_outlined,
                                    size: 25,
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Help & Support',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'FontPoppins',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.black,
                                    size: 14,
                                  )
                                ],
                              ),
                              Divider(
                                height: 30,
                                color: Colors.black87,
                                thickness: 0.2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height:15),
                        GestureDetector(
                          onTap: () {
                            _showLogoutPopup(context);

                          },
                          child: const Column(
                            children: [
                              Row(crossAxisAlignment:CrossAxisAlignment.center,
                                mainAxisAlignment:MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    size:30,
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                        fontSize:17,
                                        fontFamily: 'FontPoppins',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.gradientBG),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoText(String centerName, String label) {
    return Column(crossAxisAlignment:CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(centerName,
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'FontPoppins',
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height:10),
        Text(label,
          style: const TextStyle(
              fontFamily: 'FontPoppins',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.gradientBG),
        ),
      ],
    );
  }
  void _showLogoutPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/images/logout.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'FontPoppins',
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ],
          ),
          actions: <Widget>[
            SizedBox(
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'FontPoppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'FontPoppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                onPressed: () async {
                  await _apiService.logout(context);
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Clears all stored preferences
                  print('Remove token:${await prefs.remove('UserToken')}');
                  //Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
