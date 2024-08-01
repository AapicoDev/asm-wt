// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/settings_model.dart';
import 'package:asm_wt/service/base_service.dart';

class SettingsService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  // final CollectionReference _settingsRef =
  //     FirebaseFirestore.instance.collection(TableName.dbSettingsTable);

  Future<SettingsModel?> getSettingsDataByorgId(String orgId) async {
    return await _firestoreService
        .getDocumentById(TableName.dbSettingsTable, orgId)
        .then((result) => SettingsModel.fromDocumentSnapshot(result));
  }
}
