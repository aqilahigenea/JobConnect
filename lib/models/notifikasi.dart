/// Jenis notifikasi dalam sistem JobConnect sesuai PRD.
enum JenisNotifikasi {
  /// FR-05: Pengingat batas akhir lowongan yang pernah dilihat (< 24 jam)
  pengingatBatasAkhir,

  /// FR-10: Perubahan status lamaran (diproses/diterima/ditolak)
  statusLamaran,

  /// FR-15: Lowongan baru yang sesuai preferensi pengguna
  lowonganPreferensi,
}

/// Model entitas Notifikasi sesuai PRD Bagian 2.5.
/// Berfungsi mencatat notifikasi yang telah dikirim agar tidak terkirim ganda,
/// serta menentukan halaman tujuan saat notifikasi diketuk.
class NotifikasiItem {
  final String id;
  final String userId;
  final JenisNotifikasi jenis;
  final String judul;
  final String pesan;
  final DateTime waktu;
  final String idTujuan; // ID lowongan atau ID lamaran
  final bool isRead;
  final String? extraData; // Info tambahan seperti nama perusahaan

  const NotifikasiItem({
    required this.id,
    required this.userId,
    required this.jenis,
    required this.judul,
    required this.pesan,
    required this.waktu,
    required this.idTujuan,
    this.isRead = false,
    this.extraData,
  });

  NotifikasiItem copyWith({
    String? id,
    String? userId,
    JenisNotifikasi? jenis,
    String? judul,
    String? pesan,
    DateTime? waktu,
    String? idTujuan,
    bool? isRead,
    String? extraData,
  }) {
    return NotifikasiItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jenis: jenis ?? this.jenis,
      judul: judul ?? this.judul,
      pesan: pesan ?? this.pesan,
      waktu: waktu ?? this.waktu,
      idTujuan: idTujuan ?? this.idTujuan,
      isRead: isRead ?? this.isRead,
      extraData: extraData ?? this.extraData,
    );
  }
}
