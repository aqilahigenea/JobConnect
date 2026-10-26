import 'cv_document.dart';

/// Status lamaran sesuai PRD: diproses / diterima / ditolak.
enum LamaranStatus {
  diproses('Diproses'),
  diterima('Diterima'),
  ditolak('Ditolak');

  final String label;
  const LamaranStatus(this.label);
}

/// Model data lamaran (entity "Lamaran" di PRD bagian 2.5):
/// data pelamar, lowongan yang dilamar, dokumen/CV, status, tanggal pengajuan.
class Lamaran {
  final String id;

  // lowongan yang dilamar
  final String jobId;
  final String jobTitle;
  final String company;
  final String jobType; // Magang / Paruh Waktu / Freelance
  final String jobLocation;

  // data pelamar
  final String namaPelamar;
  final String email;
  final String noHp;
  final String pesan; // pesan untuk recruiter (opsional, boleh kosong)

  // dokumen + status + tanggal
  final CvDocument cv;
  final CvDocument? dokumenTambahan; // opsional
  final LamaranStatus status;
  final DateTime tanggalPengajuan;

  const Lamaran({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.jobType,
    required this.jobLocation,
    required this.namaPelamar,
    required this.email,
    required this.noHp,
    required this.pesan,
    required this.cv,
    this.dokumenTambahan,
    required this.status,
    required this.tanggalPengajuan,
  });

  /// Aturan bisnis PRD (FR-08 & FR-09): lamaran hanya boleh diedit atau
  /// dibatalkan selama statusnya masih "diproses".
  bool get bisaDiubah => status == LamaranStatus.diproses;

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// 5 Okt 2026
  String get tanggalLabel {
    final t = tanggalPengajuan;
    return '${t.day} ${_bulan[t.month - 1]} ${t.year}';
  }
}