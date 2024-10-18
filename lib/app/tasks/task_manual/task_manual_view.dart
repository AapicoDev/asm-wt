// import 'package:appwrite/models.dart';

import 'dart:ffi' as ui;

import 'package:asm_wt/app/tasks/task_manual/bottomsheet_view_clocking.dart';
import 'package:asm_wt/app/tasks/task_manual/bottomsheet_with_map.dart';
import 'package:asm_wt/app/tasks/task_manual/image_upload.dart';
import 'package:asm_wt/app/tasks/task_manual/task_manual_controller.dart';
import 'package:asm_wt/service/appwrite_service.dart';
import 'package:asm_wt/util/top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskManualView extends StatefulWidget {
  final String userId;

  const TaskManualView({Key? key, required this.userId}) : super(key: key);
  @override
  _TaskManualViewState createState() => _TaskManualViewState();
}

class _TaskManualViewState extends StateMVC<TaskManualView> {
  String _time = "00:00";
  String _date = "";
  List<dynamic> taskHistory = [];
  String? _clockInTime; // Store clock-in time
  bool _isHistoryVisible = true; // Added state to control visibility

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Fetch task data from Appwrite when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskManualProvider>(context, listen: false)
          .fetchTaskData(widget.userId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update the state when the widget is revisited
    updateState();
  }

  void updateState() async {
    // Logic to update the state
    print("State updated on revisit");
    var prevClockIn = await _getClockInTime();
    setState(() {
      // Update your state here
      _clockInTime = prevClockIn;
    });
  }

  void _showSuccessDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updateTime() {
    setState(() {
      _time = DateFormat('HH:mm').format(DateTime.now());
      _date = DateFormat('EEEE dd/MM/yyyy').format(DateTime.now());
    });
    Future.delayed(Duration(minutes: 1), _updateTime);
  }

  String formatTime(String? time) {
    if (time == null) return '--:--:--';
    final dateTime =
        DateTime.parse(time); // Ensure the time string is in a valid format
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  String formatDate(String? time) {
    if (time == null) return 'YYYY/MM/DD';
    final dateTime =
        DateTime.parse(time); // Ensure the time string is in a valid format
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  // Method to save clock-in time locally
  Future<void> _saveClockInTime(imagesList, position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedTime =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
    await prefs.setString('clockInTime', formattedTime);
    setState(() {
      _clockInTime = formattedTime; // Update local clock-in time
    });
    // save to server and save the id

    debugPrint('clockOutTime ------ ${formattedTime}${imagesList}${position}');
    final taskProvider =
        Provider.of<TaskManualProvider>(context, listen: false);
    var clockInID = await taskProvider.saveClockInData(widget.userId, {
      "clock_in": formattedTime,
      "clock_in_location": [position.latitude, position.longitude],
      "clock_in_image": imagesList
    });
    await prefs.setString('clockInId', clockInID);
    _showSuccessDialog(context, "Clock in save successfully");
  }

  // Method to get clock-in time from local storage
  Future<String?> _getClockInTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('clockInTime');
  }

  // Method to get clock-in time from local storage
  Future<String?> _getClockInId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('clockInId');
  }

  // Method to clear clock-in time from local storage
  Future<void> _clearClockInTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('clockInTime');
    await prefs.remove('clockInId');
    setState(() {
      _clockInTime = null;
    });
  }

  // Method to handle Clock-out action
  Future<void> _clockOut(imagesList, position) async {
    String? clockInId = await _getClockInId();
    String? clockInTime = await _getClockInTime();
    String clockOutTime =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

    debugPrint(
        'clockOutTime ------ ${clockInTime}${clockOutTime}${imagesList}${position}');
    // Save data to Appwrite using your TaskManualController
    final taskProvider =
        Provider.of<TaskManualProvider>(context, listen: false);
    await taskProvider.updateClockInData(clockInId!, {
      "clock_out": clockOutTime,
      "clock_out_image": imagesList,
      "clock_out_location": [position.latitude, position.longitude]
    });

    await taskProvider.fetchTaskData(widget.userId);
    taskHistory = taskProvider.taskData?.documents ?? [];

    _showSuccessDialog(context, "Clock out save successfully");
    // Clear local storage
    await _clearClockInTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TaskManualProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final taskData = taskProvider.taskData;
          if (taskData == null) {
            return Center(child: Text('No task data available.'));
          }

          return SingleChildScrollView(
            child: Stack(
              children: [
                // Background image with 30% height
                Container(
                  margin: EdgeInsets.all(15),
                  height: MediaQuery.of(context).size.height *
                      0.3, // Set height to 30%
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    image: DecorationImage(
                      image: AssetImage(
                        'lib/assets/images/bg.png',
                      ), // Replace with your image URL
                      fit: BoxFit.cover, // Adjust the image to cover the area
                    ),
                    color: Colors.blue,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          _buildClockDisplay(), // Use data from Appwrite
                          SizedBox(height: 5),
                          _buildClockButtons(context),
                          SizedBox(height: 20),
                          _buildTodayEntry(),
                          SizedBox(height: 20),
                          _buildAttendanceHistory(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClockDisplay() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          _time,
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildClockButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Clock-in button
        ElevatedButton(
          onPressed: () async {
            // Show bottom sheet confirmation with map before clock-in
            // bool? confirm =
            await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled:
                  true, // Allows flexible height for bottom sheet with map
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext context) {
                return ConfirmationSheetWithMap(
                  action: "confirm clock-in",
                  onConfirm: (Position? position,
                      List<ImageUploadModel>? images) async {
                    // Handle the data received from the confirmation sheet
                    var imagesList = [];
                    // Create an instance of the Appwrite service
                    final AppwriteService _appwriteService = AppwriteService();
                    for (var image in images!) {
                      String formattedTime =
                          DateFormat('yyyyMMddTHHmmss').format(DateTime.now());
                      final fileName =
                          'clock_in_${widget.userId}_${formattedTime}';
                      try {
                        // Upload the image using the Appwrite service, passing the file's path and name
                        final fileId = await _appwriteService.uploadImage(
                          image.imageFile!,
                          fileName,
                        );
                        imagesList.add(fileId);
                        // Log success or show a message
                        debugPrint('Image uploaded successfully: $fileId');
                      } catch (e) {
                        // Handle upload failure
                        debugPrint(
                            'Failed to upload image: ${fileName}, Error: $e');
                      }
                    }

                    await _saveClockInTime(
                        imagesList, position // Save clock-in time
                        );
                  },
                );
              },
            );
          },
          child: Text(
            translate('manual_clocking.clock_in'),
            style: TextStyle(fontFamily: "Kanit Light"),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[200],
            minimumSize: const Size(150, 50),
          ),
        ),

        // Clock-out button
        ElevatedButton(
          onPressed: _clockInTime == null
              ? () {
                  debugPrint('No clock in');
                }
              : () async {
                  // Show bottom sheet confirmation before clock-out
                  // bool? confirm =
                  await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled:
                        true, // Allows flexible height for bottom sheet with map
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (BuildContext context) {
                      return ConfirmationSheetWithMap(
                        action: "Clock-Out",
                        onConfirm: (Position? position,
                            List<ImageUploadModel>? images) async {
                          // Handle the data received from the confirmation sheet
                          var imagesList = [];
                          // Create an instance of the Appwrite service
                          final AppwriteService _appwriteService =
                              AppwriteService();
                          for (var image in images!) {
                            String formattedTime = DateFormat('yyyyMMddTHHmmss')
                                .format(DateTime.now());
                            final fileName =
                                'clock_in_${widget.userId}_${formattedTime}';
                            try {
                              // Upload the image using the Appwrite service, passing the file's path and name
                              final fileId = await _appwriteService.uploadImage(
                                image.imageFile!,
                                fileName,
                              );
                              imagesList.add(fileId);
                              // Log success or show a message
                              debugPrint(
                                  'Image uploaded successfully: $fileId');
                            } catch (e) {
                              // Handle upload failure
                              debugPrint(
                                  'Failed to upload image: ${fileName}, Error: $e');
                            }
                          }
                          await _clockOut(
                              imagesList, position); // Clock-out and save data
                        },
                      );
                    },
                  );
                },
          child: Text(
            translate('manual_clocking.clock_out'),
            style: TextStyle(fontFamily: "Kanit Light"),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _clockInTime != null
                ? Colors.green[200]
                : Colors.grey, // Disable if not clocked-in
            minimumSize: const Size(150, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayEntry() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(translate('manual_clocking.today'),
              style: TextStyle(color: Colors.blue)),
          Text(_date, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.grey),
              _clockInTime == null
                  ? Text('--:--:--')
                  : Text(formatTime(_clockInTime!)),
              SizedBox(width: 16),
              Icon(Icons.check_circle_outline, color: Colors.grey),
              Text('--:--:--'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryEntry(
    String date,
    String clockIn,
    String clockOut,
    List<double> clock_in_location,
    List<double> clock_out_location,
    List<String> clock_in_image,
    List<String> clock_out_image,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // SizedBox(height: 4), // Divider added after each item
          Row(
            children: [
              Text(
                date,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
              SizedBox(width: 10),
              Container(
                width: 170,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(clockIn),
                    SizedBox(width: 10),
                    Icon(Icons.check_circle, color: Colors.blue, size: 16),
                    SizedBox(width: 4),
                    Text(clockOut),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return Container(
                          height: 600,
                          padding: EdgeInsets.all(16),
                          child: ConfirmationSheetViewClocking(
                            clockIn,
                            clockOut,
                            clock_in_location,
                            clock_out_location,
                            clock_in_image,
                            clock_out_image,
                          ),
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.visibility,
                    color: Colors.green,
                  ))
            ],
          ),

          Divider(
            color: Colors.grey, // Customize divider color
            thickness: 1, // Customize divider thickness
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    final taskProvider =
        Provider.of<TaskManualProvider>(context, listen: false);
    final taskData = taskProvider.taskData?.documents ?? [];

    return Container(
      // constraints: BoxConstraints(
      //   maxHeight: MediaQuery.of(context).size.height * 0.45,
      // ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              translate("manual_clocking.attendance_history"),
              style: TextStyle(fontFamily: "Kanit Light"),
            ),
            trailing: IconButton(
              icon: Icon(
                _isHistoryVisible
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onPressed: () {
                setState(() {
                  _isHistoryVisible = !_isHistoryVisible;
                });
              },
            ),
          ),
          if (_isHistoryVisible)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: taskData.isEmpty
                  ? Center(
                      child: Text(
                          'No attendance history available.')) // Handle empty data
                  : ListView.builder(
                      shrinkWrap:
                          true, // List view takes only the required space
                      itemCount: taskData.length, // Number of history records
                      itemBuilder: (context, index) {
                        final task = taskData[index];
                        final clockInTime = task.data['clock_in'];
                        final clockOutTime = task.data['clock_out'];
                        // Safely convert the lists from dynamic to double
                        List<double> clockInLocation = List<double>.from(
                            (task.data["clock_in_location"] as List).map(
                                (item) => item is double
                                    ? item
                                    : (item as num).toDouble()));

                        List<double> clockOutLocation = List<double>.from(
                            (task.data["clock_out_location"] as List).map(
                                (item) => item is double
                                    ? item
                                    : (item as num).toDouble()));
                        final List<String> clockInImages = List<String>.from(
                            (task.data["clock_in_image"] as List)
                                .map((item) => item.toString()));
                        final List<String> clockOutImages = List<String>.from(
                            (task.data["clock_out_image"] as List)
                                .map((item) => item.toString()));
                        return _buildHistoryEntry(
                          formatDate(task.data['clock_in']),
                          formatTime(clockInTime),
                          formatTime(clockOutTime),
                          clockInLocation,
                          clockOutLocation,
                          clockInImages,
                          clockOutImages,
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
