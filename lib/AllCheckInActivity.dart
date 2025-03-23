import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constant/app_colors.dart';
import '../data/responsedata/CheckInActivityResponse.dart';
import 'constant/network/ApiService.dart';


class AllCheckInActivity extends StatefulWidget {
  const AllCheckInActivity({super.key});

  @override
  State<AllCheckInActivity> createState() => _AllCheckInActivityState();
}

class _AllCheckInActivityState extends State<AllCheckInActivity> {
  String? firstLogin;

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      DateTime dateTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      print("Error formatting time: $e");
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Your Check In Activity",
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
      body: FutureBuilder<CheckInActivityResponse?>(
        future: ApiService().checkInActivity(
            context, DateFormat('yyyy-MM-dd').format(DateTime.now())),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                width: 60, // Set custom width
                height:60, // Set custom height
                decoration: BoxDecoration(
                  color:AppColors.gradientBG.withOpacity(0.1), // Background color for the progress indicator
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor, // Custom color
                    strokeWidth:6, // Set custom stroke width
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            print('Error fetching data: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data!.userActivity == null ||
              snapshot.data!.userActivity!.isEmpty) {
            return const Center(child: Text('No Check-in Activity Available.',
              style:TextStyle(fontWeight:FontWeight.w500,fontFamily:'FontPoppins',
                  fontSize:16,color:Colors.black87),));
          } else {
            final activityData = snapshot.data!.userActivity!;
            firstLogin = snapshot.data!.firstLoginTime;
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FontPoppins',
                      fontSize: 14,
                      color: AppColors.gradientBG,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.separated(
                      itemCount: activityData.length,
                      separatorBuilder: (context, index) =>
                      const Divider(thickness:0.8,color:AppColors.gradientBG),
                      itemBuilder: (context, index) {
                        return ActivityTile(
                          icon: Icons.login,
                          title: 'Check in',
                          checkOutTitle: 'Check out',
                          checkOutTime: formatTime(activityData[index].logoutTime.toString()),
                          workinghrsTitle: 'Working hrs',
                          workinghrsTime: activityData[index].workingHours.toString(),
                          workinghrsIcon: Icons.work_history,
                          checkOutIcon: Icons.logout,
                          time: formatTime(activityData[index].loginTime.toString()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}


class ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String checkOutTitle;
  final String checkOutTime;
  final IconData checkOutIcon;
  final String workinghrsTitle;
  final String workinghrsTime;
  final IconData workinghrsIcon;

  const ActivityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.checkOutTitle,
    required this.checkOutTime,
    required this.checkOutIcon,
    required this.workinghrsTitle,
    required this.workinghrsTime,
    required this.workinghrsIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FontPoppins',
                      fontSize: 15,
                      color: Colors.black),
                ),
              ),
              Text(time,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FontPoppins',
                      fontSize: 15,
                      color: Colors.black)),
            ],
          ),


          Row(
            children: [
              Icon(checkOutIcon, color: AppColors.gradientBG, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(checkOutTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'FontPoppins',
                        fontSize: 15,
                        color: Colors.black)),
              ),
              Text(
                (checkOutTime == null || checkOutTime == "null" || checkOutTime == "00:00:00") ? "" : checkOutTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'FontPoppins',
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),


          Row(
            children: [
              Icon(workinghrsIcon, color: AppColors.primaryColor, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  workinghrsTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FontPoppins',
                      fontSize: 15,
                      color: Colors.black),
                ),
              ),
              Text(
                (workinghrsTime == null || workinghrsTime == "null" || workinghrsTime == "00:00:00") ? "" : workinghrsTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'FontPoppins',
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
