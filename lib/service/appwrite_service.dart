import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppwriteService {
  late Client _client;
  late Databases _databases;
  late Storage _storage;

  AppwriteService() {
    _client = Client()
        .setEndpoint(
            'https://baas.powermap.live/v1') // Replace with your Appwrite endpoint
        .setProject('65670e27c14fdec05c4c'); // Replace with your project ID

    _databases = Databases(_client);
    _storage = Storage(_client);
  }

  Future<models.DocumentList> getTaskData(String userId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: '65670ea113c13e0c876d', // Replace with your database ID
        collectionId: '670bdb1400031a7afc84', // Replace with your collection ID
        queries: [
          Query.equal("emp_id", userId),
          Query.orderDesc('\$createdAt'),
          Query.isNotNull('clock_out'),
        ], // Assuming `userId` is the document ID
      );
      return result;
    } catch (e) {
      throw Exception('Failed to get task data: $e');
    }
  }

  Future<models.Document> saveClockIn(data) async {
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

  Future<models.Document> updateClockIn(id, data) async {
    debugPrint('data ${data}');
    try {
      final result = await _databases.updateDocument(
        databaseId: '65670ea113c13e0c876d', // Replace with your database ID
        collectionId: '670bdb1400031a7afc84', // Replace with your collection ID
        documentId: id,
        data: data,
      );
      return result;
    } catch (e) {
      throw Exception('Failed to get task data: $e');
    }
  }

  // Upload image file
  Future<String> uploadImage(File imageFile, String filename) async {
    try {
      final result = await _storage.createFile(
        bucketId: '670decdd0001995ed51a', // Replace with your storage bucket ID
        fileId: 'unique()',
        file: InputFile.fromPath(
          path: imageFile.path,
          filename: filename, // Use the provided filename
        ),
      );

      String fileUrl =
          'https://baas.powermap.live/v1/storage/buckets/670decdd0001995ed51a/files/${result.$id}/view?project=65670e27c14fdec05c4c';
      return fileUrl; // Returns the URL to access the file
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
