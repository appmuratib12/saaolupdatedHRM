import 'package:flutter/material.dart';
import 'package:saaolhrmapp/LeaveApprovalScreen.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'constant/app_colors.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  List<String> titleArrays = ["Casual","Sick Leave",'Emergency leave',"Paid Leave"];

  void _showTitlePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Select Leave Type',
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  List<DateTime> _selectedDates = [];
  final Map<DateTime, String> _daySelections = {};
  void _showDatePickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Dates',style:TextStyle(
            color: Colors.black87,
            fontSize:18,
            fontFamily:'FontPoppins',
            fontWeight: FontWeight.w500,
          ),),
          backgroundColor:Colors.grey[200],
          content: Container(
            height: 400,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.multiple,
              minDate: DateTime.now(),
              initialSelectedDates: _selectedDates,
              backgroundColor:Colors.grey[200],
              headerStyle: DateRangePickerHeaderStyle(
                backgroundColor: Colors.grey[200], // Header color
                textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize:14,
                  fontFamily:'FontPoppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              selectionColor: AppColors.primaryColor,
              todayHighlightColor:AppColors.primaryColor,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is List<DateTime>) {
                  List<DateTime> selectedDatesNow = args.value;
                  setState(() {
                    for (var date in selectedDatesNow) {
                      _daySelections.putIfAbsent(date, () => 'Full Day');
                    }
                    _daySelections.removeWhere((key, value) => !selectedDatesNow.contains(key));
                    _selectedDates = selectedDatesNow;
                  });
                }
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Done",style:TextStyle(fontWeight:FontWeight.w500,
                  fontSize:15,fontFamily:'FontPoppins',color:Colors.black87),),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
  Widget _buildDayOption(DateTime date) {
    String selected = _daySelections[date] ?? 'Full Day';

    return Padding(padding: const EdgeInsets.all(5),child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
          style: const TextStyle(fontWeight: FontWeight.w600,
              fontSize:15,fontFamily:'FontPoppins',color:Colors.black),
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Full Day',
              groupValue: selected,
              onChanged: (value) {
                setState(() => _daySelections[date] = value!);
              },
              activeColor: Colors.orange,
            ),
            const Text('Full Day',style:TextStyle(fontWeight:FontWeight.w500,
                fontSize:11,fontFamily:'FontPoppins',color:Colors.black),),
            Radio<String>(
              value: 'First Half',
              groupValue: selected,
              onChanged: (value) {
                setState(() => _daySelections[date] = value!);
              },
              activeColor: Colors.orange,
            ),
            const Text('First Half',style:TextStyle(fontWeight:FontWeight.w500,
                fontSize:11,fontFamily:'FontPoppins',color:Colors.black),),
            Radio<String>(
              value: 'Second Half',
              groupValue: selected,
              onChanged: (value) {
                setState(() => _daySelections[date] = value!);
              },
              activeColor: Colors.orange,
            ),
            const Text('Second Half',style:TextStyle(fontWeight:FontWeight.w500,
                fontSize:11,fontFamily:'FontPoppins',color:Colors.black),),
          ],
        ),
         Divider(
          color:AppColors.primaryColor.withOpacity(0.8),
           thickness:0.5,
           height:15,
        ),
      ],
    ),
    );
  }


  @override
  Widget build(BuildContext context) {
    String dateString = _selectedDates.map((d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}').join(', ');

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
                const Text('Leave Type*',
                  style:TextStyle(fontWeight:FontWeight.w600,
                      fontFamily:'FontPoppins',fontSize:15,color:Colors.black),),
                const SizedBox(height:10,),
                GestureDetector(
                  onTap: _showTitlePickerDialog,
                  child: AbsorbPointer(
                    child: SizedBox(
                      height: 52,
                      child: DropdownButtonFormField<String>(
                        value: selectTitle,
                        decoration: InputDecoration(
                          hintText: 'Select Leave Type',
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
                            fontWeight: FontWeight.w500),
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
                const SizedBox(height:15),
              ],
             ),
            ),
               Column(crossAxisAlignment:CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Align(alignment: Alignment.centerLeft,
                    child: Text("Select Multiple Dates: *",style: TextStyle(fontSize:15,
                    fontWeight: FontWeight.w600,
                    fontFamily:'FontPoppins',color:Colors.black),)),
                const SizedBox(height:15),
                InkWell(
                  onTap: _showDatePickerDialog,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:AppColors.primaryColor.withOpacity(0.3),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(dateString.isEmpty ? "Select Dates" :
                        dateString,style: const TextStyle(fontWeight:FontWeight.w500,fontSize:14,
                            fontFamily:'FontPoppins',color:Colors.black),)),
                        const Icon(Icons.calendar_month,size:18,color:AppColors.primaryColor),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ..._selectedDates.map(_buildDayOption).toList(),
              ],
             ),
               const Text('Number of Leave days*',
              style:TextStyle(fontWeight:FontWeight.w600,
                  fontFamily:'FontPoppins',fontSize:15,color:Colors.black),),
               const SizedBox(height:15),
               Container(
                 height:55,
                 padding:const EdgeInsets.all(18),
                 width:MediaQuery.of(context).size.width,
                 decoration:BoxDecoration(
                   color:AppColors.primaryColor.withOpacity(0.3),
                   borderRadius:BorderRadius.circular(10)
                 ),
                 child:Text('${_selectedDates.length}',
                   style:const TextStyle(fontWeight:FontWeight.w500,
                       fontSize:15,fontFamily:'FontPoppins',color:Colors.black),),

               ),
            const SizedBox(height:15),
            const Text('Leave Reason*',
              style:TextStyle(fontWeight:FontWeight.w600,
                  fontFamily:'FontPoppins',fontSize:16,color:Colors.black87),),
            const SizedBox(height: 8),
            TextFormField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter your leave reason",
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
              height:45,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeaveApprovalScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.white, width: 0.1),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontFamily: 'FontPoppins',
                    fontSize: 18,
                    letterSpacing:0.3,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

