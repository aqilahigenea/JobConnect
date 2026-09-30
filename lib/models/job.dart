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
  });

  String get subtitle => '$company • $location';

  // ---- Getter yang dipakai detail_screen.dart ----
  String get allowance => salary;
  String get workType => type;
  String get team => teamName ?? company;
  String get locationName => officeName ?? location;
  String get address => fullAddress ?? location;
  List<String> get tags => [type, location];
}