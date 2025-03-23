import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_month_picker/flutter_custom_month_picker.dart';
import 'package:intl/intl.dart';
import 'constant/app_colors.dart';
import 'constant/network/ApiService.dart';
import 'data/responsedata/AttendanceReportResponse.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DateFormat apiDateFormat =
      DateFormat('yyyy/MM'); // Format for API request
  final DateFormat displayDateFormat =
      DateFormat('MMMM yyyy'); // Format for display
  String selectedDate = DateFormat('yyyy/MM')
      .format(DateTime.now()); // Default month for API request
  String displayDate =
      DateFormat('MMMM yyyy').format(DateTime.now()); // Default display format

  Future<void> _selectMonth(BuildContext context) async {
    DateTime now = DateTime.now();

    showMonthPicker(
      context,
      onSelected: (month, year) {
        setState(() {
          selectedDate =
              "$year/${month.toString().padLeft(2, '0')}"; // Format as yyyy/MM
          displayDate =
              "$year ${DateFormat('MMMM').format(DateTime(year, month))}"; // Display as 'Month Year'
        });
        _fetchReportData(); // Fetch data when month changes
      },
      initialSelectedMonth: now.month,
      initialSelectedYear: now.year,
      firstYear: now.year,
      firstEnabledMonth: 2,
      lastYear: now.year,
      // Ensure only the current year is selectable
      lastEnabledMonth: now.month,
      // Restrict selection only to the current month
      selectButtonText: 'OK',
      cancelButtonText: 'Cancel',
      highlightColor: AppColors.primaryColor,
      textColor: Colors.black,
      contentBackgroundColor: Colors.white,
      dialogBackgroundColor: Colors.grey[200],
    );
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      DateTime dateTime =
          DateFormat("HH:mm:ss").parse(time); // Parse 24-hour format
      return DateFormat("hh:mm a")
          .format(dateTime); // Convert to 12-hour format
    } catch (e) {
      print("Error formatting time: $e");
      return time; // Return original if error occurs
    }
  }

  Future<AttendanceReportResponse?>? _reportFuture; // Store future data

  @override
  void initState() {
    super.initState();
    _fetchReportData(); // Fetch initial data
  }

  Future<void> _fetchReportData() async {
    setState(() {
      _reportFuture = ApiService().getReportData(context, selectedDate);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await _fetchReportData(); // Fetch latest data when refreshed
        },
        color: AppColors.primaryColor,
        backgroundColor: Colors.white,
        strokeWidth: 3.0,
        displacement: 100.0,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 80,
                padding: const EdgeInsets.only(top: 45),
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(200, 253, 106, 111),
                      Color.fromARGB(200, 255, 155, 68),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Attendance',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'FontPoppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _selectMonth(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10, bottom: 15),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(200, 253, 106, 111),
                              Color.fromARGB(200, 255, 155, 68),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.filter_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        displayDate,
                        style: const TextStyle(
                            fontFamily: 'FontPoppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(200, 253, 106, 111),
                      Color.fromARGB(200, 255, 155, 68),
                    ],
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Date',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FontPoppins',
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Punch IN',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FontPoppins',
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Punch Out',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FontPoppins',
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Working Hrs',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FontPoppins',
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<AttendanceReportResponse?>(
                future: _reportFuture, // Pass dynamically selected date
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                          backgroundColor: AppColors.gradientBG,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.records == null ||
                      snapshot.data!.records!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No data available.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'FontPoppins',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    );
                  } else {
                    final reportData =
                        snapshot.data!.records!.reversed.toList();
                    String month = snapshot.data!.month.toString();
                    print('Month:$month');

                    return Column(
                      children: List.generate(reportData.length, (index) {
                        final record = reportData[index];
                        // Parse and format date
                        DateTime parsedDate =
                            DateFormat('dd::MM::yy').parse(record.date!);
                        String formattedDate =
                            DateFormat('dd MMM').format(parsedDate);
                        String dayOfWeek = DateFormat('EEE').format(parsedDate);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'FontPoppins',
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            dayOfWeek,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'FontPoppins',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Text(
                                    formatTime(record.firstLogin),
                                    style: const TextStyle(
                                      fontFamily: 'FontPoppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Text(
                                    formatTime(record.lastLogout),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'FontPoppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Text(
                                    record.workingHours ?? '',
                                    style: const TextStyle(
                                      color: AppColors.gradientBG,
                                      fontFamily: 'FontPoppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  }
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
