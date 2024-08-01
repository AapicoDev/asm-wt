const baseURL = "https://api.powermap.live/api/";
const baseFirebaseAdminURL = "https://asm-wt.powermap.live/api/";
const bastOTPURL = "https://otp.thaibulksms.com/v2/otp/";

class BaseService {
  String status;
  String message;
  Object? data;

  BaseService(this.status, this.message, this.data);
}

class TableName {
  static const dbTasksTable = "tasks";
  static const dbEmployeeTable = "employees";
  static const dbDepartmentTable = "departments";
  static const dbNewFeedsTable = "newFeeds";
  static const dbSettingsTable = "settings";
  static const dbAllDevicesTable = "allDevices";
  static const dbTaskStatusReportTable = "yearlyTaskStatusReport";

  static const dbVehicleTable = "vehicles";
  static const dbCheckInTable = "checklists";
  static const dbMaintenanceTable = "maintenances";
  static const dbNotificationsTable = "notifications";
  static const dbCheckListScheduleTable = "vehicleCheckSchedule";
  static const dbTasksDestinationTable = "tasksDestination";
}

class AccountRole {
  static const controllerRole = "controller";
  static const driverRole = "driver";
  static const userRole = "user";
}
