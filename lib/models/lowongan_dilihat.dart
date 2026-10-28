/// Entitas data riwayat lowongan yang dilihat pengguna (FR-05).
/// Dicatat otomatis saat pengguna membuka detail lowongan, sebagai dasar
/// pengingat batas akhir lowongan.
/// Bukan fitur bookmark dan tidak ditampilkan sebagai daftar.
class LowonganDilihat {
  final String userId;
  final String jobId;
  final DateTime viewedAt;

  const LowonganDilihat({
    required this.userId,
    required this.jobId,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'jobId': jobId,
        'viewedAt': viewedAt.toIso8601String(),
      };

  factory LowonganDilihat.fromJson(Map<String, dynamic> json) => LowonganDilihat(
        userId: json['userId'] as String,
        jobId: json['jobId'] as String,
        viewedAt: DateTime.parse(json['viewedAt'] as String),
      );
}
