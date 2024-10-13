import 'package:appwrite/models.dart';
import 'package:asm_wt/app/tasks/task_manual/task_manual_controller.dart';
import 'package:flutter/material.dart';
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
  Future<void> _saveClockInTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedTime =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
    await prefs.setString('clockInTime', formattedTime);
    setState(() {
      _clockInTime = formattedTime; // Update local clock-in time
    });
    debugPrint('formattedTime ---- ${formattedTime}');
  }

  // Method to get clock-in time from local storage
  Future<String?> _getClockInTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('clockInTime');
  }

  // Method to clear clock-in time from local storage
  Future<void> _clearClockInTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('clockInTime');
    setState(() {
      _clockInTime = null;
    });
  }

  // Method to handle Clock-out action
  Future<void> _clockOut() async {
    String? clockInTime = await _getClockInTime();
    String clockOutTime =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

    debugPrint('clockOutTime ------ ${clockInTime}${clockOutTime}');
    // Save data to Appwrite using your TaskManualController
    final taskProvider =
        Provider.of<TaskManualProvider>(context, listen: false);
    await taskProvider.saveClockInData(widget.userId, {
      "clock_in": clockInTime,
      "clock_out": clockOutTime,
    });

    await taskProvider.fetchTaskData(widget.userId);
    taskHistory = taskProvider.taskData?.documents ?? [];

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
                      0.325, // Set height to 30%
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
                          SizedBox(height: 20),
                          _buildClockButtons(),
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

  Widget _buildClockButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            // Show bottom sheet confirmation before clock-in
            bool? confirm = await showModalBottomSheet<bool>(
              context: context,
              builder: (BuildContext context) {
                return _buildConfirmationSheet('Clock-in');
              },
            );

            if (confirm == true) {
              await _saveClockInTime(); // Save clock-in time
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Clock-in successful!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Text('Clock-in'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[200],
            minimumSize: Size(150, 50),
          ),
        ),
        ElevatedButton(
          onPressed: _clockInTime == null
              ? () {
                  debugPrint('No clock in');
                }
              : () async {
                  // Show bottom sheet confirmation before clock-out
                  bool? confirm = await showModalBottomSheet<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return _buildConfirmationSheet('Clock-out');
                    },
                  );

                  if (confirm == true) {
                    await _clockOut(); // Clock-out and save data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Clock-out successful!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
          child: Text('Clock-out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _clockInTime != null
                ? Colors.green[200]
                : Colors.grey, // Disable if not clocked-in
            minimumSize: Size(150, 50),
          ),
        ),
      ],
    );
  }

// Reusable confirmation bottom sheet widget
  Widget _buildConfirmationSheet(String action) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Confirm $action',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(),
          SizedBox(height: 10),
          Text('Are you sure you want to $action?'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Cancel action
                },
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirm action
                },
                child: Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[200],
                ),
              ),
            ],
          ),
        ],
      ),
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
          Text('Today', style: TextStyle(color: Colors.blue)),
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

  Widget _buildHistoryEntry(String date, String clockIn, String clockOut,
      {bool lateEntry = false, bool absent = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: absent ? Colors.red[50] : Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(lateEntry ? Icons.error : Icons.check_circle,
                  color: lateEntry ? Colors.orange : Colors.green, size: 16),
              SizedBox(width: 4),
              Text(clockIn),
              SizedBox(width: 16),
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text(clockOut),
            ],
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
            title: Text('Attendance History'),
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
              height: MediaQuery.of(context).size.height * 0.36,
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

                        return _buildHistoryEntry(
                          formatDate(task.data['clock_in']),
                          formatTime(clockInTime),
                          formatTime(clockOutTime),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
