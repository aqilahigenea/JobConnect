import '../models/job.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti API/database.
class JobRepository {
  static const List<Job> _jobs = [
    Job(
      id: '1',
      title: 'UI/UX Designer Intern',
      company: 'Teknologi Ranah',
      location: 'Remote',
      type: 'Magang',
      description:
          'Membuat desain antarmuka aplikasi mobile bersama tim produk.',
      salary: 'Rp 2,5 - 3,5 jt / bulan',
      postedAgo: '1 hari lalu',
      match: 95,
      isVerified: true,
      teamName: 'Product Design Team',
      duration: '6 bulan',
      deadline: '30 Nov 2026',
      benefits: [
        Benefit(
          title: 'Uang saku bulanan',
          description: 'Dibayarkan setiap akhir bulan selama magang.',
        ),
        Benefit(
          title: 'Mentoring 1-on-1',
          description: 'Dibimbing langsung oleh senior designer.',
        ),
        Benefit(
          title: 'Sertifikat & konversi SKS',
          description: 'Sertifikat resmi dan dukungan konversi SKS.',
        ),
      ],
      responsibilities: [
        'Membuat wireframe dan prototype fitur baru aplikasi.',
        'Melakukan riset pengguna dan usability testing sederhana.',
        'Menjaga konsistensi desain sesuai design system.',
      ],
      requirements: [
        'Mahasiswa aktif jurusan SI, TI, DKV, atau terkait.',
        'Menguasai Figma dan dasar prinsip UI/UX.',
        'Memiliki portofolio desain (proyek kampus boleh).',
      ],
      officeName: 'Teknologi Ranah (Remote)',
      fullAddress: 'Pekerjaan dilakukan secara online dari mana saja.',
      contactName: 'Tim Rekrutmen Teknologi Ranah',
      contactEmail: 'karier@teknologiranah.id',
      contactPhone: '+62 812 1111 2222',
    ),
    Job(
      id: '2',
      title: 'Junior Frontend Developer',
      company: 'Nagari Digital',
      location: 'Padang',
      type: 'Freelance',
      description:
          'Membangun tampilan web responsif menggunakan HTML, CSS, dan JavaScript.',
      salary: 'Rp 4 - 6 jt / proyek',
      postedAgo: '2 hari lalu',
      match: 88,
      isVerified: true,
      teamName: 'Web Engineering Team',
      duration: '3 bulan',
      deadline: '15 Des 2026',
      benefits: [
        Benefit(
          title: 'Bayaran per proyek',
          description: 'Dibayar bertahap sesuai milestone.',
        ),
        Benefit(
          title: 'Jam kerja fleksibel',
          description: 'Atur jadwal sendiri selama target terpenuhi.',
        ),
      ],
      responsibilities: [
        'Mengubah desain menjadi halaman web responsif.',
        'Mengintegrasikan tampilan dengan REST API.',
        'Menulis kode yang rapi dan mudah dirawat.',
      ],
      requirements: [
        'Menguasai HTML, CSS, dan JavaScript.',
        'Memahami Git dan alur kerja branch.',
        'Memiliki minimal satu proyek web.',
      ],
      officeName: 'Kantor Nagari Digital',
      fullAddress: 'Jl. Contoh No. 10, Padang, Sumatera Barat',
      contactName: 'HRD Nagari Digital',
      contactEmail: 'hrd@nagaridigital.id',
      contactPhone: '+62 811 2222 3333',
    ),
    Job(
      id: '3',
      title: 'Barista Paruh Waktu',
      company: 'Fore Coffee',
      location: 'Padang',
      type: 'Paruh Waktu',
      description:
          'Menyiapkan minuman dan melayani pelanggan, jadwal fleksibel di luar jam kuliah.',
      salary: 'Rp 1,8 - 2,2 jt / bulan',
      postedAgo: '3 hari lalu',
      match: 82,
      isVerified: true,
      teamName: 'Store Operations',
      duration: '6 bulan',
      deadline: '10 Des 2026',
      benefits: [
        Benefit(
          title: 'Jadwal ramah kuliah',
          description: 'Maksimal 20 jam per minggu.',
        ),
        Benefit(
          title: 'Makan & minum gratis',
          description: 'Selama jam kerja.',
        ),
      ],
      responsibilities: [
        'Menyiapkan minuman sesuai standar resep.',
        'Melayani pelanggan dengan ramah.',
        'Menjaga kebersihan area bar.',
      ],
      requirements: [
        'Mahasiswa aktif atau lulusan SMA/SMK.',
        'Bersedia kerja shift, termasuk akhir pekan.',
        'Komunikatif dan teliti.',
      ],
      officeName: 'Fore Coffee Padang',
      fullAddress: 'Jl. Contoh No. 5, Padang, Sumatera Barat',
      contactName: 'Store Manager',
      contactEmail: 'padang@forecoffee.id',
      contactPhone: '+62 813 3333 4444',
    ),
    Job(
      id: '4',
      title: 'Asisten Kasir',
      company: 'Kopi Tuku',
      location: 'Padang',
      type: 'Paruh Waktu',
      description: 'Membantu transaksi kasir dan pencatatan penjualan harian.',
      salary: 'Rp 1,5 - 2 jt / bulan',
      postedAgo: '4 hari lalu',
      match: 76,
      teamName: 'Store Operations',
      duration: '4 bulan',
      deadline: '20 Des 2026',
      benefits: [
        Benefit(
          title: 'Gaji bulanan',
          description: 'Dibayar tepat waktu setiap tanggal 25.',
        ),
      ],
      responsibilities: [
        'Melayani transaksi pembayaran pelanggan.',
        'Mencatat penjualan harian.',
      ],
      requirements: [
        'Jujur dan teliti.',
        'Bisa mengoperasikan aplikasi kasir dasar.',
      ],
      officeName: 'Kopi Tuku Padang',
      fullAddress: 'Jl. Contoh No. 8, Padang, Sumatera Barat',
      contactName: 'Manajer Toko',
      contactEmail: 'padang@kopituku.id',
      contactPhone: '+62 814 4444 5555',
    ),
    Job(
      id: '5',
      title: 'Tutor Matematika Online',
      company: 'Ruangguru',
      location: 'Remote',
      type: 'Freelance',
      description:
          'Mengajar siswa SMA secara daring dengan jadwal yang bisa diatur.',
      salary: 'Rp 75 rb / sesi',
      postedAgo: '5 hari lalu',
      match: 71,
      isVerified: true,
      teamName: 'Tutor Community',
      duration: 'Fleksibel',
      deadline: '31 Des 2026',
      benefits: [
        Benefit(
          title: 'Bayaran per sesi',
          description: 'Pencairan setiap dua minggu.',
        ),
        Benefit(
          title: 'Jadwal fleksibel',
          description: 'Pilih sendiri sesi yang ingin diambil.',
        ),
      ],
      responsibilities: [
        'Mengajar materi matematika SMA melalui kelas online.',
        'Menyiapkan latihan soal untuk siswa.',
      ],
      requirements: [
        'Menguasai materi matematika SMA.',
        'Memiliki laptop dan koneksi internet stabil.',
      ],
      officeName: 'Kelas Online Ruangguru',
      fullAddress: 'Pekerjaan dilakukan secara online.',
      contactName: 'Tim Tutor Ruangguru',
      contactEmail: 'tutor@ruangguru.example',
      contactPhone: '+62 815 5555 6666',
    ),
    Job(
      id: '6',
      title: 'Beauty Advisor Magang',
      company: 'Sociolla',
      location: 'Padang',
      type: 'Magang',
      description:
          'Membantu pelanggan memilih produk dan menjaga tampilan display toko.',
      salary: 'Rp 2 jt / bulan',
      postedAgo: '1 minggu lalu',
      match: 64,
      isVerified: true,
      teamName: 'Retail Beauty Team',
      duration: '3 bulan',
      deadline: '5 Jan 2027',
      benefits: [
        Benefit(
          title: 'Uang saku bulanan',
          description: 'Dibayarkan setiap akhir bulan.',
        ),
        Benefit(
          title: 'Pelatihan produk',
          description: 'Belajar pengetahuan produk skincare dan makeup.',
        ),
      ],
      responsibilities: [
        'Membantu pelanggan memilih produk yang sesuai.',
        'Menata display produk di toko.',
      ],
      requirements: [
        'Mahasiswa aktif.',
        'Ramah dan tertarik pada dunia kecantikan.',
      ],
      officeName: 'Sociolla Padang',
      fullAddress: 'Jl. Contoh No. 12, Padang, Sumatera Barat',
      contactName: 'Store Supervisor',
      contactEmail: 'padang@sociolla.example',
      contactPhone: '+62 816 6666 7777',
    ),
  ];

  /// simulateError: true -> sengaja gagal untuk menguji error state.
  Future<List<Job>> fetchJobs({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _jobs;
  }
}