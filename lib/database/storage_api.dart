import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class StorageService {
  static final _firebaseStorage = FirebaseStorage.instance;

  static Future<List<String>> uploadImages(List<File?> imageFiles, String path) async {
    var ref = _firebaseStorage.ref(path);
    return await Future.wait(imageFiles.where((file) => file != null).toList().map((imageFile) async {
      var uploadTask = ref.child(imageFile!.path).putFile(imageFile!);
      var snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    }));
  }

  static Future<void> deleteImage(String url) async {
    var ref = _firebaseStorage.refFromURL(url);
    await ref.delete();
  }
}