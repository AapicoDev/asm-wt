import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';

class AppwriteService {
  late Client _client;
  late Databases _databases;

  AppwriteService() {
    _client = Client()
        .setEndpoint(
            'https://baas.powermap.live/v1') // Replace with your Appwrite endpoint
        .setProject('65670e27c14fdec05c4c'); // Replace with your project ID

    _databases = Databases(_client);
  }

  Future<DocumentList> getTaskData(String userId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: '65670ea113c13e0c876d', // Replace with your database ID
        collectionId: '670bdb1400031a7afc84', // Replace with your collection ID
        queries: [
          Query.equal("emp_id", userId),
          Query.orderDesc('\$createdAt'),
        ], // Assuming `userId` is the document ID
      );
      return result;
    } catch (e) {
      throw Exception('Failed to get task data: $e');
    }
  }

  Future<Document> saveClockIn(data) async {
    debugPrint('data ${data}');
    try {
      final result = await _databases.createDocument(
        databaseId: '65670ea113c13e0c876d', // Replace with your database ID
        collectionId: '670bdb1400031a7afc84', // Replace with your collection ID
        documentId: 'unique()',
        data: data,
      );
      return result;
    } catch (e) {
      throw Exception('Failed to get task data: $e');
    }
  }
}
