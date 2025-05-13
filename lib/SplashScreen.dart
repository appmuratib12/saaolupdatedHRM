import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:saaolhrmapp/BottomNavigationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';
import 'constant/app_colors.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Widget nextScreen = const BottomNavigationScreen(initialIndex: 0);


  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      nextScreen = isLoggedIn
          ?  const BottomNavigationScreen(initialIndex: 0)
          : const LoginScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: const Center(
        child: Text(
          'Saaol HRM',
          style: TextStyle(
              fontSize: 35,
              fontFamily: 'FontPoppins',
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.1),
        ),
      ),
      backgroundColor: AppColors.gradientBG,
      nextScreen: nextScreen,
      splashIconSize: 250,
      duration: 5000,
      splashTransition: SplashTransition.slideTransition,
      pageTransitionType: PageTransitionType.leftToRight,
    );
  }
}
