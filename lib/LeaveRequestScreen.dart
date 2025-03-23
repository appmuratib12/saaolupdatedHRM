import 'package:flutter/material.dart';
import 'constant/app_colors.dart';


class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  List<String> titleArrays = ["Casual", "Sick Leave.", 'Emergency leave',"Paid Leave"];


  void _showTitlePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Select Title',
            style: TextStyle(
              fontFamily: 'FontPoppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: titleArrays.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    titleArrays[index],
                    style: const TextStyle(
                      fontFamily: 'FontPoppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectTitle = titleArrays[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
  String? selectTitle;
  String selectedValue = "Full Day";
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor: Colors.lightBlue.shade50, // Background color of the calendar
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Set the selected date to the corresponding controller
        if (isStartDate) {
          startDateController.text = "${picked.day}-${picked.month}-${picked.year}";
        } else {
          endDateController.text = "${picked.day}-${picked.month}-${picked.year}";
        }
      });
    }
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Leave Request",
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
      body:SingleChildScrollView(
        physics: const ScrollPhysics(),
        child:Padding(padding: const EdgeInsets.all(10),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Form(key:_formKey,
              autovalidateMode:AutovalidateMode.always,
              child:Column(crossAxisAlignment:CrossAxisAlignment.start,
              mainAxisAlignment:MainAxisAlignment.start,
              children: [
                const Text('Leave Type',
                  style:TextStyle(fontWeight:FontWeight.w600,
                      fontFamily:'FontPoppins',fontSize:16,color:Colors.black),),
                const SizedBox(height:10,),
                GestureDetector(
                  onTap: _showTitlePickerDialog,
                  child: AbsorbPointer(
                    child: SizedBox(
                      height: 52,
                      child: DropdownButtonFormField<String>(
                        value: selectTitle,
                        decoration: InputDecoration(
                          hintText: 'Leave Type',
                          hintStyle: const TextStyle(
                            fontFamily: 'FontPoppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 20.0,
                          ),
                          filled: true,
                          fillColor: AppColors.primaryColor.withOpacity(0.3),
                        ),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'FontPoppins',
                            fontWeight: FontWeight.w600),
                        items: titleArrays
                            .map((gender) => DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        ))
                            .toList(),
                        onChanged: (String? value) {},
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded, // Your custom arrow icon
                          color:AppColors.primaryColor,  // Adjust the icon color as needed
                        ),
                        iconEnabledColor: Colors.black54,  // Icon color when enabled
                        iconDisabledColor: Colors.grey,    // Icon color when disabled
                      ),
                    ),
                  ),
                ),
                const SizedBox(height:10,),
                const Text('Leave Mode',
                  style:TextStyle(fontWeight:FontWeight.w600,
                      fontFamily:'FontPoppins',fontSize:16,color:Colors.black87),),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildRadioOption("Full Day"),
                    _buildRadioOption("First Half"),
                    _buildRadioOption("Second"),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Choose the Date',
                  style:TextStyle(fontWeight:FontWeight.w600,
                      fontFamily:'FontPoppins',fontSize:16,color:Colors.black87),),
                const SizedBox(height:15),
                const Text(
                  "Start Date",
                  style: TextStyle(fontSize:15, fontWeight: FontWeight.w500,fontFamily:'FontPoppins',color:Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  controller: startDateController,
                  decoration: InputDecoration(
                    hintText: 'Start Date',
                    hintStyle: const TextStyle(
                      fontFamily: 'FontPoppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    filled: true,
                    fillColor:AppColors.primaryColor.withOpacity(0.3),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () =>  _selectDate(context,true),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'FontPoppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "End Date",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,fontFamily:'FontPoppins',color:Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  controller:endDateController,
                  decoration: InputDecoration(
                    hintText: 'End Date',
                    hintStyle: const TextStyle(
                      fontFamily: 'FontPoppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    filled: true,
                    fillColor:AppColors.primaryColor.withOpacity(0.3),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () =>  _selectDate(context,true),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'FontPoppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Reason',
                  style:TextStyle(fontWeight:FontWeight.w600,
                      fontFamily:'FontPoppins',fontSize:16,color:Colors.black87),),
                const SizedBox(height: 8),
                TextFormField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Enter your reason",
                    hintStyle:const TextStyle(fontWeight:FontWeight.w500,fontFamily:'FontPoppins',fontSize:15,color:Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor, // Change this to your desired color
                        width: 1.0, // Adjust the width if necessary
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:  const BorderSide(
                        color:AppColors.primaryColor, // Change this to your desired color for normal state
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
                const SizedBox(height:16),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height:48,
                  child: ElevatedButton(
                    onPressed: () async {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
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
              ],
             ),
            ),

          ],
         ),
        ),
      ),
    );
  }
  Widget _buildRadioOption(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedValue,
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue!;
            });
          },
          activeColor: Colors.orange, // Selected radio button color
        ),
        Text(
          value,
          style: const TextStyle(fontSize:14,fontWeight:FontWeight.w500,fontFamily:'FontPoppins',color:Colors.black87), // Adjust the font size
        ),
      ],
    );
  }
}
