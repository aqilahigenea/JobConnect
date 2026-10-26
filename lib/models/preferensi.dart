/// Model data untuk Preferensi Pengguna (Modul 3 FR-11 s/d FR-15).
class Preferensi {
  final String userId;
  final String namaPengguna;
  final String programStudi;
  final List<String> jenisPekerjaan;
  final List<String> bidangMinat;
  final DateTime updatedAt;

  const Preferensi({
    required this.userId,
    required this.namaPengguna,
    required this.programStudi,
    required this.jenisPekerjaan,
    required this.bidangMinat,
    required this.updatedAt,
  });

  bool get isEmpty => jenisPekerjaan.isEmpty && bidangMinat.isEmpty;

  Preferensi copyWith({
    String? userId,
    String? namaPengguna,
    String? programStudi,
    List<String>? jenisPekerjaan,
    List<String>? bidangMinat,
    DateTime? updatedAt,
  }) {
    return Preferensi(
      userId: userId ?? this.userId,
      namaPengguna: namaPengguna ?? this.namaPengguna,
      programStudi: programStudi ?? this.programStudi,
      jenisPekerjaan: jenisPekerjaan ?? this.jenisPekerjaan,
      bidangMinat: bidangMinat ?? this.bidangMinat,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
