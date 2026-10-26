import '../models/cv_document.dart';
import '../models/job.dart';
import '../models/lamaran.dart';

/// Exception khusus untuk kegagalan mengirim lamaran
/// (sama polanya dengan AuthException di modul).
class LamaranException implements Exception {
  final String message;
  const LamaranException(this.message);

  @override
  String toString() => message;
}

/// Data layer lamaran. Belum memakai server: data disimpan di memori
/// (hilang saat aplikasi ditutup) dan waktu tunggu server disimulasikan.
class LamaranRepository {
  // static -> daftar yang sama dipakai semua instance selama aplikasi hidup
  static final List<Lamaran> _tersimpan = [];

  /// Cari lamaran yang sudah pernah dikirim untuk lowongan tertentu.
  Lamaran? findByJobId(String jobId) {
    for (final l in _tersimpan) {
      if (l.jobId == jobId) return l;
    }
    return null;
  }

  /// FR-06 (Create): kirim lamaran baru.
  /// [simulateError] = true -> melempar exception untuk menguji error state.
  Future<Lamaran> submit({
    required Job job,
    required String namaPelamar,
    required String email,
    required String noHp,
    required String pesan,
    required CvDocument cv,
    CvDocument? dokumenTambahan,
    bool simulateError = false,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi request

    if (simulateError) {
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet.');
    }
    // aturan bisnis: satu lowongan hanya boleh dilamar sekali
    if (findByJobId(job.id) != null) {
      throw const LamaranException('Kamu sudah melamar lowongan ini.');
    }

    final now = DateTime.now();
    final lamaran = Lamaran(
      id: 'LMR-${now.millisecondsSinceEpoch}',
      jobId: job.id,
      jobTitle: job.title,
      company: job.company,
      jobType: job.type,
      jobLocation: job.location,
      namaPelamar: namaPelamar,
      email: email,
      noHp: noHp,
      pesan: pesan,
      cv: cv,
      dokumenTambahan: dokumenTambahan,
      status: LamaranStatus.diproses, // status awal selalu "diproses"
      tanggalPengajuan: now,
    );
    _tersimpan.add(lamaran);
    return lamaran;
  }

  /// FR-07 (Read): ambil SEMUA lamaran, yang terbaru di paling atas.
  /// Future + delay = simulasi request ke server (supaya state loading
  /// bisa terlihat di layar daftar).
  Future<List<Lamaran>> fetchAll({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 1));

    if (simulateError) {
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet.');
    }
    // .reversed = urutan dibalik (terbaru dulu); List.from = salinan baru,
    // jadi layar tidak bisa mengubah isi daftar asli secara tidak sengaja.
    return List<Lamaran>.from(_tersimpan.reversed);
  }

  /// FR-07 (Read): ambil 1 lamaran berdasarkan id (null jika tidak ada).
  Lamaran? findById(String id) {
    for (final l in _tersimpan) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// FR-08 (Update): ubah data lamaran yang masih "diproses".
  /// Yang boleh berubah: data pelamar, pesan, CV, dokumen tambahan.
  /// Yang TETAP: id, lowongan, status, tanggal pengajuan.
  Future<Lamaran> update({
    required String id,
    required String namaPelamar,
    required String email,
    required String noHp,
    required String pesan,
    required CvDocument cv,
    CvDocument? dokumenTambahan,
    bool simulateError = false,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi request

    if (simulateError) {
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet.');
    }
    final index = _tersimpan.indexWhere((l) => l.id == id);
    if (index == -1) {
      throw const LamaranException('Lamaran tidak ditemukan.');
    }
    final lama = _tersimpan[index];
    // aturan bisnis: hanya status "diproses" yang boleh diedit
    if (!lama.bisaDiubah) {
      throw LamaranException(
        'Lamaran berstatus ${lama.status.label} tidak dapat diedit.',
      );
    }

    // Model Lamaran bersifat final (tidak bisa diubah), jadi kita buat
    // objek BARU: data lama disalin, data hasil edit menggantikan yang lama.
    final baru = Lamaran(
      id: lama.id,
      jobId: lama.jobId,
      jobTitle: lama.jobTitle,
      company: lama.company,
      jobType: lama.jobType,
      jobLocation: lama.jobLocation,
      namaPelamar: namaPelamar,
      email: email,
      noHp: noHp,
      pesan: pesan,
      cv: cv,
      dokumenTambahan: dokumenTambahan,
      status: lama.status,
      tanggalPengajuan: lama.tanggalPengajuan,
    );
    _tersimpan[index] = baru; // timpa data lama di posisi yang sama
    return baru;
  }

  /// FR-09 (Delete): batalkan (hapus) lamaran yang masih "diproses".
  Future<void> delete(String id, {bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 1)); // simulasi request

    if (simulateError) {
      throw Exception('Gagal terhubung ke server. Periksa koneksi internet.');
    }
    final index = _tersimpan.indexWhere((l) => l.id == id);
    if (index == -1) {
      throw const LamaranException('Lamaran tidak ditemukan.');
    }
    final lama = _tersimpan[index];
    // aturan bisnis: hanya status "diproses" yang boleh dibatalkan
    if (!lama.bisaDiubah) {
      throw LamaranException(
        'Lamaran berstatus ${lama.status.label} tidak dapat dibatalkan.',
      );
    }
    _tersimpan.removeAt(index);
  }
}