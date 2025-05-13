import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:saaolhrmapp/constant/database/text_string.dart';
import 'constant/app_colors.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {

  List<String> leavesTypesArray = ["All","Casual","Emergency","Long Term","Week off"];
  int? selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Leave Approval",
          style: TextStyle(
            fontFamily: 'FontPoppins',
            fontSize:14,
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
      ),
      backgroundColor:Colors.grey[200],
      body:Padding(padding: const EdgeInsets.only(top:15,left:10,right:10),
        child:Container(
          height:MediaQuery.of(context).size.height,
          width:MediaQuery.of(context).size.width,
          color:Colors.grey[200],
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:40,
                child:ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: leavesTypesArray.length,
                  itemBuilder: (context, index) {
                    final item = leavesTypesArray[index];
                    final isSelected = selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });

                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical:10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: AppColors.primaryColor
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                                : [
                              BoxShadow(
                                color:
                                Colors.grey.withOpacity(0.15),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize:12,
                                fontFamily: 'FontPoppins',
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height:15,),
              Expanded(child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: leavesTypesArray.length,
                shrinkWrap: true,
                physics:const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical:8,horizontal:6),
                    child: InkWell(
                      onTap: () {

                      },
                      child: Container(
                        padding:EdgeInsets.all(10),
                        width:MediaQuery.of(context).size.width,
                        decoration:BoxDecoration(
                          color:Colors.white,
                          borderRadius:BorderRadius.circular(10),
                        ),
                        child:Column(crossAxisAlignment:CrossAxisAlignment.start,
                          children: [
                            Row(crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                const Text('Dates:',style:TextStyle(fontWeight:FontWeight.w500,
                                    fontSize:14,fontFamily:'FontPoppins',color:Colors.black87),),
                                Expanded(child: Container()),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2), // Light green background
                                    borderRadius: BorderRadius.circular(8), // Rounded corners
                                  ),
                                  child: const Text(
                                    'Approved',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      fontFamily: 'FontPoppins',
                                      color: Colors.green, // Text color
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  '05-04-2025: ',
                                  style: TextStyle(
                                    fontSize:13,
                                    fontWeight:FontWeight.w600,
                                    fontFamily: 'FontPoppins',
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Full day',
                                    style: TextStyle(
                                      fontSize:12,
                                      fontFamily: 'FontPoppins',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  _showTrackStatusPopup(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal:7, vertical:7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
                                        blurRadius:5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child:  const Text(
                                    'Track Status',
                                    style: TextStyle(
                                      fontFamily: 'FontPoppins',
                                      fontSize:11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Divider(
                              thickness:0.5,
                              color:Colors.grey.withOpacity(0.5),
                              height:30,
                            ),
                            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(crossAxisAlignment:CrossAxisAlignment.center,
                                  children: [
                                    Text('Leave Type',style:TextStyle(fontWeight:FontWeight.w600,
                                        fontSize:12,fontFamily:'FontPoppins',color:Colors.black),),
                                    Text('Emergency Leave',style:TextStyle(fontWeight:FontWeight.w500,
                                        fontSize:10,fontFamily:'FontPoppins',color:Colors.black87),),

                                  ],
                                ),
                                Container(
                                  height:40, // height of the vertical line
                                  width: 1,   // width of the divider
                                  color: Colors.grey[400], // color of the divider
                                ),
                                const Column(crossAxisAlignment:CrossAxisAlignment.center,
                                  children: [
                                    Text('Applied Days',style:TextStyle(fontWeight:FontWeight.w600,
                                        fontSize:12,fontFamily:'FontPoppins',
                                        color:Colors.black),),
                                    Text('0.5',style:TextStyle(fontWeight:FontWeight.w500,
                                        fontSize:10,fontFamily:'FontPoppins',color:Colors.black87),),

                                  ],
                                ),
                                Container(
                                  height:40, // height of the vertical line
                                  width: 1,   // width of the divider
                                  color: Colors.grey[400], // color of the divider
                                ),
                                const Column(crossAxisAlignment:CrossAxisAlignment.center,
                                  children: [
                                    Text('Approval Needed',style:TextStyle(fontWeight:FontWeight.w600,
                                        fontSize:12,fontFamily:'FontPoppins',color:Colors.black),),
                                    Text('one Approval',style:TextStyle(fontWeight:FontWeight.w500,fontSize:10,
                                        fontFamily:'FontPoppins',color:Colors.black87),),

                                  ],
                                )
                              ],
                            ),
                            Divider(
                              thickness:0.5,
                              color:Colors.grey.withOpacity(0.5),
                              height:30,
                            ),
                            const Text('Reason',
                              style:TextStyle(fontWeight:FontWeight.w600,
                                  fontSize:14,fontFamily:'FontPoppins',
                                  color:Colors.black),),
                            const SizedBox(height:5,),
                            const ReadMoreText(reasonTxt,
                              trimLines: 2,
                              colorClickableText: AppColors.primaryColor,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'Read More',
                              trimExpandedText: 'Read Less',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'FontPoppins',
                                fontWeight: FontWeight.w500,
                                color: Colors
                                    .black87, // Text style for the main text
                              ),
                              moreStyle: TextStyle(
                                fontSize: 13,
                                fontFamily: 'FontPoppins',
                                fontWeight: FontWeight.w600,
                                color: AppColors
                                    .primaryColor, // Style for the 'Read More/Read Less' text
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildExpandedStatus(String number, String title, Color numberColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: 'FontPoppins',
              color: numberColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontFamily: 'FontPoppins',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  void _showTrackStatusPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            height:230,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Approval Timeline',
                          style: TextStyle(
                            fontSize:14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FontPoppins',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color:AppColors.primaryColor, // Light background
                          shape: BoxShape.circle, // Circular background
                        ),
                        child: const Icon(Icons.close, size:18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height:15,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Line
                    const Row(crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATUS: ',
                          style: TextStyle(
                            fontSize:12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FontPoppins',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Approved',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FontPoppins',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height:25),
                    // Timeline
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Colors.orange,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, color: Colors.white, size:15),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Colors.orange,
                          ),
                        ),
                        Container(
                          width:30,
                          height: 30,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/300'), // Replace with your user's image
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Requested on',
                                style: TextStyle(
                                  fontSize:11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'FontPoppins',
                                  color:Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                 Icon(Icons.calendar_month, size: 15, color:AppColors.primaryColor),
                                SizedBox(width: 5),
                                Text(
                                  '11-04-2025',
                                  style: TextStyle(
                                    fontSize:10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'FontPoppins',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(width:15,),
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal:8, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Approved',
                                style: TextStyle(
                                  fontSize:11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'FontPoppins',
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                 Icon(Icons.calendar_month, size: 15, color:AppColors.primaryColor),
                                SizedBox(width: 5),
                                Text(
                                  '11-04-2025',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'FontPoppins',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
