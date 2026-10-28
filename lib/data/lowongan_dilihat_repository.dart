import '../models/lowongan_dilihat.dart';

/// Repository untuk mencatat riwayat lowongan yang dilihat pengguna (FR-05).
/// Data disimpan secara in-memory selama aplikasi aktif, dan digunakan sebagai
/// dasar evaluasi pengingat batas akhir lowongan dalam 24 jam.
class LowonganDilihatRepository {
  static final LowonganDilihatRepository _instance =
      LowonganDilihatRepository._internal();
  factory LowonganDilihatRepository() => _instance;
  LowonganDilihatRepository._internal();

  final List<LowonganDilihat> _items = [];

  /// Mencatat bahwa pengguna telah membuka detail lowongan tertentu (FR-05).
  void catatDilihat({
    required String userId,
    required String jobId,
    DateTime? waktuDilihat,
  }) {
    final now = waktuDilihat ?? DateTime.now();
    final index = _items.indexWhere(
      (item) => item.userId == userId && item.jobId == jobId,
    );

    if (index >= 0) {
      _items[index] = LowonganDilihat(
        userId: userId,
        jobId: jobId,
        viewedAt: now,
      );
    } else {
      _items.add(LowonganDilihat(
        userId: userId,
        jobId: jobId,
        viewedAt: now,
      ));
    }
  }

  /// Cek apakah lowongan pernah dibuka detailnya oleh pengguna.
  bool pernahDilihat({required String userId, required String jobId}) {
    return _items.any((item) => item.userId == userId && item.jobId == jobId);
  }

  /// Mengambil daftar semua ID lowongan yang pernah dilihat pengguna.
  List<String> getJobIdsDilihat(String userId) {
    return _items
        .where((item) => item.userId == userId)
        .map((item) => item.jobId)
        .toList();
  }

  /// Mengambil daftar objek LowonganDilihat untuk pengguna tertentu.
  List<LowonganDilihat> getRiwayatDilihat(String userId) {
    return _items.where((item) => item.userId == userId).toList();
  }

  /// Reset data riwayat (digunakan saat logout atau unit testing).
  void reset() {
    _items.clear();
  }
}
