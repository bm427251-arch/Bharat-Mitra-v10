import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<String> uploadImage(
    File file,
    String folder, {
    Function(double progress)? onProgress,
  }) async {
    // Step 1 Compress to 70% quality max width 1080
    final dir = await getTemporaryDirectory();
    final targetPath = "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
    );
    final uploadFile = compressed != null ? File(compressed.path) : file;

    // Step 2 Upload to Firebase asia-south1 Mumbai bucket
    final ref = FirebaseStorage.instance.ref().child("$folder/${DateTime.now().millisecondsSinceEpoch}.jpg");
    final uploadTask = ref.putFile(uploadFile, SettableMetadata(contentType: "image/jpeg"));

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });
    }

    final taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }
}
