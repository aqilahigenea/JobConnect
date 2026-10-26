import '../models/cv_document.dart';
import 'validators.dart';

/// Validator khusus form lamaran (FR-06).
/// Dibuat di file terpisah supaya tidak mengubah validators.dart milik tim
/// (menghindari konflik saat merge di Git).
class LamaranValidators {
  LamaranValidators._();

  static const int maxCvBytes = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedCvExtensions = ['pdf', 'docx'];

  /// Nama lengkap: wajib, minimal 3 karakter.
  static String? nama(String? value) =>
      Validators.minLength(value, 3, fieldName: 'Nama lengkap');

  /// Nomor HP Indonesia: 08xx..., 628xx..., atau +628xx... (10-13 digit).
  static String? noHp(String? value) {
    final requiredError = Validators.requiredField(value, fieldName: 'No. HP');
    if (requiredError != null) return requiredError;
    final cleaned = value!.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(\+62|62|0)8\d{8,11}$').hasMatch(cleaned)) {
      return 'Format No. HP tidak valid (contoh: 081234567890)';
    }
    return null;
  }

  /// Pesan untuk recruiter: OPSIONAL, tetapi jika diisi minimal 10 karakter.
  static String? pesan(String? value) {
    if (value == null || value.trim().isEmpty) return null; // boleh kosong
    return Validators.minLength(value, 10, fieldName: 'Pesan');
  }

  /// CV: wajib dilampirkan, format PDF/DOCX, maksimal 5 MB.
  static String? cv(CvDocument? doc) {
    if (doc == null) return 'CV wajib dilampirkan';
    return _checkFile(doc, 'CV');
  }

  /// Dokumen tambahan: OPSIONAL, tetapi jika ada aturan formatnya sama.
  static String? dokumenTambahan(CvDocument? doc) {
    if (doc == null) return null;
    return _checkFile(doc, 'Dokumen tambahan');
  }

  static String? _checkFile(CvDocument doc, String label) {
    if (!allowedCvExtensions.contains(doc.extension)) {
      return 'Format $label harus PDF atau DOCX';
    }
    if (doc.sizeInBytes > maxCvBytes) {
      return 'Ukuran $label maksimal 5 MB';
    }
    return null;
  }

  /// Pernyataan data benar: wajib dicentang.
  static String? setuju(bool? value) =>
      value == true ? null : 'Centang pernyataan ini untuk melanjutkan';
}
