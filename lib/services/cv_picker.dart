import 'package:file_picker/file_picker.dart';

import '../models/cv_document.dart';

/// Membuka file chooser bawaan perangkat (Android / Windows / browser)
/// lalu mengubah berkas yang dipilih menjadi CvDocument.
class CvPicker {
  CvPicker._();

  /// Mengembalikan berkas yang dipilih, atau null jika pengguna membatalkan.
  static Future<CvDocument?> pickCv() async {
    // Semua tipe file boleh dipilih supaya validasi format (PDF/DOCX)
    // di LamaranValidators tetap bisa didemokan.
    final file = await FilePicker.pickFile();
    if (file == null) return null; // user menutup chooser

    final size = file.lengthSync() ?? await file.length() ?? 0;
    return CvDocument(name: file.name, sizeInBytes: size);
  }
}