import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AttendanceScreen.dart';
import 'DashBoardScreen.dart';
import 'MyProfileScreen.dart';
import 'constant/app_colors.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key, required this.initialIndex});

  final int initialIndex;
  static List<NavigationDestination> navigation = <NavigationDestination>[
    const NavigationDestination(
      selectedIcon: Icon(
        Icons.home,
        color: AppColors.primaryColor,
      ),
      icon: Icon(
        Icons.home_outlined,
        color: Colors.white,
      ),
      label: 'Home',
    ),
    /*const NavigationDestination(
      selectedIcon: Icon(
        Icons.calendar_month,
        color:AppColors.primaryColor,
      ),
      icon: Icon(
        Icons.calendar_month_outlined,
        color: Colors.white,
      ),
      label: 'Task',
    ),*/
    const NavigationDestination(
      selectedIcon: Icon(
        Icons.access_time,
        color: AppColors.primaryColor,
      ),
      icon: Icon(
        Icons.access_time_outlined,
        color: Colors.white,
      ),
      label: 'Attendance',
    ),
     const NavigationDestination(
      selectedIcon: Icon(
        Icons.account_circle,
        color: AppColors.primaryColor,
      ),
      icon: Icon(
        Icons.account_circle_outlined,
        color: Colors.white,
      ),
      label: 'My Profile',
    ),
  ];

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late int currentIndex;

  final pages = [
    const DashboardScreen(),
    // const TaskScreen(),
    const AttendanceScreen(),
    const MyProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex == 0) {
          SystemNavigator.pop(); // Properly exits the app
        } else {
          setState(() {
            currentIndex = 0;
          });
        }
        return false;
      },
      child:Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(200, 253, 106, 111),
                Color.fromARGB(200, 255, 155, 68),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.white,
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'FontPoppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            child: NavigationBar(
              animationDuration: const Duration(milliseconds: 500),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: currentIndex,
              height: 60,
              elevation: 0,
              backgroundColor: Colors.transparent,
              // Transparent to allow gradient
              onDestinationSelected: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              destinations: BottomNavigationScreen.navigation,
            ),
          ),
        ),
      ),
    );
  }
}
