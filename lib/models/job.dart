class Benefit {
  final String title;
  final String description;
  const Benefit({required this.title, required this.description});
}

/// Model data lowongan JobConnect.
class Job {
  // ---- Field asli (dipakai Home) ----
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // Magang / Paruh Waktu / Freelance
  final String description;
  final String salary;
  final String postedAgo;
  final int match; // persen kecocokan dengan preferensi

  // ---- Field tambahan untuk Detail (opsional) ----
  final bool isVerified;
  final String? teamName;
  final String duration;
  final String deadline;
  final List<Benefit> benefits;
  final List<String> responsibilities;
  final List<String> requirements;
  final String? officeName;
  final String? fullAddress;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final double latitude;
  final double longitude;
  final DateTime? deadlineDate; // Tanggal batas akhir untuk evaluasi FR-05

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    required this.salary,
    required this.postedAgo,
    required this.match,
    this.isVerified = false,
    this.teamName,
    this.duration = '-',
    this.deadline = '-',
    this.benefits = const [],
    this.responsibilities = const [],
    this.requirements = const [],
    this.officeName,
    this.fullAddress,
    this.contactName = '-',
    this.contactEmail = '-',
    this.contactPhone = '-',
    this.latitude = -0.9471,
    this.longitude = 100.4172,
    this.deadlineDate,
  });

  String get subtitle => '$company • $location';

  // ---- Getter yang dipakai detail_screen.dart ----
  String get allowance => salary;
  String get workType => type;
  String get team => teamName ?? company;
  String get locationName => officeName ?? location;
  String get address => fullAddress ?? location;
  List<String> get tags => [type, location];

  // ---- FR-05 Helper Batas Akhir Lowongan ----

  /// Mengambil tanggal penutupan lowongan (dari deadlineDate atau parsing string deadline)
  DateTime? get closingDate {
    if (deadlineDate != null) return deadlineDate;
    return _parseDeadlineString(deadline);
  }

  /// Menghitung sisa durasi hingga lowongan ditutup (null jika batas akhir tidak valid)
  Duration? get timeRemaining {
    final close = closingDate;
    if (close == null) return null;
    return close.difference(DateTime.now());
  }

  /// Cek apakah lowongan akan ditutup dalam kurun waktu 24 jam ke depan (FR-05)
  bool get isClosingWithin24Hours {
    final diff = timeRemaining;
    if (diff == null) return false;
    return !diff.isNegative && diff <= const Duration(hours: 24);
  }

  /// Teks ringkas sisa waktu penutupan
  String get remainingTimeString {
    final diff = timeRemaining;
    if (diff == null) return deadline;
    if (diff.isNegative) return 'Sudah Ditutup';
    final hours = diff.inHours;
    if (hours < 1) {
      final mins = diff.inMinutes;
      return mins <= 1 ? '1 menit lagi' : '$mins menit lagi';
    }
    if (hours < 24) {
      return '$hours jam lagi';
    }
    final days = diff.inDays;
    return '$days hari lagi';
  }

  /// Helper untuk mem-parsing format tanggal bahasa Indonesia seperti '30 Nov 2026'
  static DateTime? _parseDeadlineString(String text) {
    try {
      final parts = text.trim().split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final day = int.tryParse(parts[0]);
        final monthStr = parts[1].toLowerCase();
        final year = int.tryParse(parts[2]);
        if (day != null && year != null) {
          final month = switch (monthStr) {
            'jan' || 'januari' => 1,
            'feb' || 'februari' => 2,
            'mar' || 'maret' => 3,
            'apr' || 'april' => 4,
            'mei' => 5,
            'jun' || 'juni' => 6,
            'jul' || 'juli' => 7,
            'agu' || 'agustus' => 8,
            'sep' || 'september' => 9,
            'okt' || 'oktober' => 10,
            'nov' || 'november' => 11,
            'des' || 'desember' => 12,
            _ => 0,
          };
          if (month > 0) {
            return DateTime(year, month, day, 23, 59, 59);
          }
        }
      }
      return DateTime.tryParse(text);
    } catch (_) {
      return null;
    }
  }
}