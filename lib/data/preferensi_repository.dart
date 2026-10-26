import '../models/preferensi.dart';

/// Exception khusus untuk kegagalan pengelolaan preferensi pengguna.
class PreferensiException implements Exception {
  final String message;
  const PreferensiException(this.message);

  @override
  String toString() => message;
}

/// Data layer untuk Preferensi Pengguna (Modul 3).
/// Menyimpan preferensi di memori selama sesi aplikasi berjalan.
class PreferensiRepository {
  static final PreferensiRepository _instance =
      PreferensiRepository._internal();
  factory PreferensiRepository() => _instance;
  PreferensiRepository._internal();

  Preferensi? _preferensi;

  // Profil pengguna default sesuai desain UI Modul 3
  static const String defaultUserId = '2411521005';
  static const String defaultNama = 'Madani Fitri Nur Hidayati';
  static const String defaultProdi = 'Sistem Informasi';

  /// FR-12 (Read): ambil preferensi tersimpan
  Future<Preferensi?> getPreferensi({bool simulateDelay = false}) async {
    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return _preferensi;
  }

  /// Cek apakah sudah ada preferensi tersimpan
  bool get hasPreferensi => _preferensi != null && !_preferensi!.isEmpty;

  /// FR-11 (Create): Simpan preferensi pengguna untuk pertama kali
  Future<Preferensi> simpanPreferensi({
    required List<String> jenisPekerjaan,
    required List<String> bidangMinat,
    String userId = defaultUserId,
    String namaPengguna = defaultNama,
    String programStudi = defaultProdi,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (jenisPekerjaan.isEmpty) {
      throw const PreferensiException('Pilih minimal 1 jenis pekerjaan.');
    }
    if (bidangMinat.isEmpty) {
      throw const PreferensiException('Pilih minimal 1 bidang yang diminati.');
    }
    if (bidangMinat.length > 5) {
      throw const PreferensiException('Pilih maksimal 5 bidang minat.');
    }

    final data = Preferensi(
      userId: userId,
      namaPengguna: namaPengguna,
      programStudi: programStudi,
      jenisPekerjaan: List<String>.from(jenisPekerjaan),
      bidangMinat: List<String>.from(bidangMinat),
      updatedAt: DateTime.now(),
    );

    _preferensi = data;
    return data;
  }

  /// FR-13 (Update): Perbarui preferensi yang sudah ada
  Future<Preferensi> ubahPreferensi({
    required List<String> jenisPekerjaan,
    required List<String> bidangMinat,
  }) async {
    return simpanPreferensi(
      jenisPekerjaan: jenisPekerjaan,
      bidangMinat: bidangMinat,
    );
  }

  /// FR-14 (Delete): Hapus / reset preferensi tersimpan
  Future<void> hapusPreferensi() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _preferensi = null;
  }
}
