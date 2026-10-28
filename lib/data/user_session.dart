class UserSession {
  // Singleton pattern
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String? _currentUser;
  String? _fullName;

  /// ID unik pengguna aktif (default ke NIM mahasiswa jika belum login)
  String get currentUserId => _currentUser ?? '2411521005';

  /// Dipanggil saat registrasi pengguna baru
  void registerUser({required String name, required String email}) {
    _fullName = name;
    _currentUser = email;
  }

  /// Dipanggil saat login dengan email/NIM
  void login(String identifier) {
    _currentUser = identifier;
    // Jika nama lengkap belum pernah diisi (misal langsung login), 
    // gunakan nama depan dari email/NIM sebagai nama lengkap default
    if (_fullName == null || _fullName!.isEmpty) {
      _fullName = displayName;
    }
  }

  /// Dipanggil saat logout
  void logout() {
    _currentUser = null;
    _fullName = null;
  }

  /// Getter untuk nama lengkap (memperbaiki error 'fullName')
  String get fullName {
    if (_fullName != null && _fullName!.isNotEmpty) {
      return _fullName!;
    }
    return displayName;
  }

  /// Mengambil nama tampilan secara otomatis dari email/NIM
  String get displayName {
    if (_currentUser == null || _currentUser!.isEmpty) {
      return 'Pengguna';
    }

    final input = _currentUser!.trim();

    // 1. Jika input berupa email (contoh: madani@gmail.com)
    if (input.contains('@')) {
      final namePart = input.split('@').first;
      if (namePart.isEmpty) return 'Pengguna';
      return namePart[0].toUpperCase() + namePart.substring(1);
    }

    // 2. Jika input berupa NIM/angka (contoh: 2411521005)
    final isNim = RegExp(r'^\d+$').hasMatch(input);
    if (isNim) {
      return 'Mahasiswa ($input)';
    }

    // 3. Jika input berupa teks nama biasa
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Mengambil inisial huruf depan untuk Avatar di AppBar
  String get displayInitial {
    final name = fullName;
    if (name.isEmpty) return 'U';
    return name[0].toUpperCase();
  }
}