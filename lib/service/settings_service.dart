import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/settings_model.dart';
import 'package:asm_wt/service/base_service.dart';

class SettingsService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();

  Future<SettingsModel?> getSettingsDataByOrgId(String? orgId) async {
    if (orgId == null || orgId.isEmpty) {
      print('Invalid organization ID');
      return null;
    }

    try {
      final result = await _firestoreService.getDocumentById(
          TableName.dbSettingsTable, orgId);
      return result.exists ? SettingsModel.fromDocumentSnapshot(result) : null;
    } catch (e) {
      print('Error fetching settings data: $e');
      return null;
    }
  }
}
