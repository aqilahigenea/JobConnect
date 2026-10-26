/// Model dokumen CV yang dipilih pelamar (FR-06: upload CV/dokumen).
class CvDocument {
  final String name;
  final int sizeInBytes;

  const CvDocument({required this.name, required this.sizeInBytes});

  /// Ekstensi file dalam huruf kecil: "CV_Aqila.pdf" -> "pdf"
  String get extension {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  /// Format ukuran: 1258291 -> "1,2 MB", 512000 -> "500 KB"
  String get sizeLabel {
    if (sizeInBytes >= 1024 * 1024) {
      final mb = sizeInBytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1).replaceAll('.', ',')} MB';
    }
    return '${(sizeInBytes / 1024).round()} KB';
  }
}
