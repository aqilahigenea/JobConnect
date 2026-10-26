/// Mengelola sesi pengguna yang sedang login (nama & email).
class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String? email;
  String? name;

  // Catatan user yang mendaftar di RegisterScreen: email -> nama lengkap
  final Map<String, String> _registeredUsers = {};

  void registerUser({required String name, required String email}) {
    _registeredUsers[email.trim().toLowerCase()] = name.trim();
  }

  void login(String inputEmail) {
    email = inputEmail.trim();
    final lower = email!.toLowerCase();
    if (_registeredUsers.containsKey(lower)) {
      name = _registeredUsers[lower];
    } else {
      // Ambil bagian sebelum @ sebagai nama
      final username = email!.split('@').first;
      final formatted = username
          .replaceAll(RegExp(r'[._\d]'), ' ')
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
          .join(' ');
      name = formatted.isNotEmpty ? formatted : 'Aqila';
    }
  }

  /// Nama panggilan singkat untuk sapaan "Halo, `displayName` 👋"
  String get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      final first = name!.trim().split(' ').first;
      return first.isNotEmpty ? first : name!;
    }
    return 'Aqila';
  }

  /// Nama lengkap untuk tampilan Profil
  String get fullName => (name != null && name!.isNotEmpty) ? name! : 'Madani Fitri Nur Hidayati';

  /// Inisial avatar (misal 'M' untuk Madani)
  String get displayInitial {
    final d = displayName;
    return d.isNotEmpty ? d[0].toUpperCase() : 'A';
  }

  void logout() {
    email = null;
    name = null;
  }
}
