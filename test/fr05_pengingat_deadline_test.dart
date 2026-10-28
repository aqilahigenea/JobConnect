import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_connect/data/job_repository.dart';
import 'package:job_connect/data/lowongan_dilihat_repository.dart';
import 'package:job_connect/data/notifikasi_repository.dart';
import 'package:job_connect/data/user_session.dart';
import 'package:job_connect/models/job.dart';
import 'package:job_connect/models/notifikasi.dart';
import 'package:job_connect/routes/app_routes.dart';
import 'package:job_connect/screens/detail_screen.dart';
import 'package:job_connect/screens/home_screen.dart';

void main() {
  setUp(() {
    LowonganDilihatRepository().reset();
    NotifikasiRepository().reset();
    UserSession().login('2411521005');
  });

  group('FR-05 Entity & Repository: Lowongan Dilihat', () {
    test('Mencatat lowongan yang dilihat pengguna secara otomatis', () {
      final repo = LowonganDilihatRepository();
      const userId = '2411521005';
      const jobId = '1';

      expect(repo.pernahDilihat(userId: userId, jobId: jobId), isFalse);

      repo.catatDilihat(userId: userId, jobId: jobId);

      expect(repo.pernahDilihat(userId: userId, jobId: jobId), isTrue);
      expect(repo.getJobIdsDilihat(userId), contains(jobId));
    });

    test('Tidak mencatat duplikat ID lowongan dilihat', () {
      final repo = LowonganDilihatRepository();
      const userId = '2411521005';
      const jobId = '1';

      repo.catatDilihat(userId: userId, jobId: jobId);
      repo.catatDilihat(userId: userId, jobId: jobId);

      expect(repo.getJobIdsDilihat(userId).length, 1);
    });
  });

  group('FR-05 Notifikasi Pengingat Batas Akhir (< 24 Jam)', () {
    final now = DateTime(2026, 10, 28, 12, 0);

    final jobClosingSoon = Job(
      id: 'job-18h',
      title: 'Barista Paruh Waktu',
      company: 'Fore Coffee',
      location: 'Padang',
      type: 'Paruh Waktu',
      description: 'Menyiapkan minuman',
      salary: '2 jt',
      postedAgo: '1 hari lalu',
      match: 85,
      deadline: 'Besok, 06:00',
      deadlineDate: now.add(const Duration(hours: 18)), // 18 jam (< 24 jam)
    );

    final jobClosingFar = Job(
      id: 'job-5d',
      title: 'Frontend Developer',
      company: 'Nagari Digital',
      location: 'Padang',
      type: 'Freelance',
      description: 'Web dev',
      salary: '4 jt',
      postedAgo: '2 hari lalu',
      match: 90,
      deadline: '5 hari lagi',
      deadlineDate: now.add(const Duration(days: 5)), // > 24 jam
    );

    test('Tidak mengirim pengingat jika lowongan BELUM PERNAH dilihat', () {
      final notifRepo = NotifikasiRepository();
      const userId = '2411521005';

      final generated = notifRepo.periksaPengingatBatasAkhir(
        userId: userId,
        semuaLowongan: [jobClosingSoon],
        waktuSekarang: now,
      );

      expect(generated, isEmpty);
      expect(notifRepo.getNotifikasi(userId), isEmpty);
    });

    test(
        'Mengirim pengingat jika lowongan PERNAH DILIHAT dan akan tutup dalam 24 jam',
        () {
      final notifRepo = NotifikasiRepository();
      const userId = '2411521005';

      // Pengguna pernah membuka detail lowongan
      LowonganDilihatRepository().catatDilihat(userId: userId, jobId: jobClosingSoon.id);

      final generated = notifRepo.periksaPengingatBatasAkhir(
        userId: userId,
        semuaLowongan: [jobClosingSoon, jobClosingFar],
        waktuSekarang: now,
      );

      // Hanya jobClosingSoon yang memicu pengingat
      expect(generated.length, 1);
      final notif = generated.first;
      expect(notif.jenis, JenisNotifikasi.pengingatBatasAkhir);
      expect(notif.idTujuan, jobClosingSoon.id);
      expect(notif.pesan, contains(jobClosingSoon.title)); // PRD: berisi judul lowongan
      expect(notif.isRead, isFalse);
    });

    test('Mencegah pengiriman pengingat ganda untuk lowongan yang sama', () {
      final notifRepo = NotifikasiRepository();
      const userId = '2411521005';

      LowonganDilihatRepository().catatDilihat(userId: userId, jobId: jobClosingSoon.id);

      // Pengecekan pertama -> menghasilkan 1 notifikasi
      final firstRun = notifRepo.periksaPengingatBatasAkhir(
        userId: userId,
        semuaLowongan: [jobClosingSoon],
        waktuSekarang: now,
      );
      expect(firstRun.length, 1);

      // Pengecekan kedua (berkala) -> tidak mengirim ulang (anti duplikasi)
      final secondRun = notifRepo.periksaPengingatBatasAkhir(
        userId: userId,
        semuaLowongan: [jobClosingSoon],
        waktuSekarang: now.add(const Duration(minutes: 5)),
      );
      expect(secondRun, isEmpty);
      expect(notifRepo.getNotifikasi(userId).length, 1);
    });

    test('Menandai notifikasi sebagai telah dibaca', () {
      final notifRepo = NotifikasiRepository();
      const userId = '2411521005';

      LowonganDilihatRepository().catatDilihat(userId: userId, jobId: jobClosingSoon.id);
      notifRepo.periksaPengingatBatasAkhir(
        userId: userId,
        semuaLowongan: [jobClosingSoon],
        waktuSekarang: now,
      );

      expect(notifRepo.getUnreadCount(userId), 1);

      final notif = notifRepo.getNotifikasi(userId).first;
      notifRepo.tandaiDibaca(notif.id);

      expect(notifRepo.getUnreadCount(userId), 0);
      expect(notifRepo.getNotifikasi(userId).first.isRead, isTrue);
    });
  });

  group('FR-05 UI DetailScreen Tracking & Deadline Alert', () {
    testWidgets(
        'Membuka DetailScreen mencatat riwayat dilihat otomatis & menampilkan banner < 24 jam',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final closingSoonJob = Job(
        id: '99',
        title: 'Desain Grafis Magang',
        company: 'Kreatif Media',
        location: 'Padang',
        type: 'Magang',
        description: 'Desain visual',
        salary: '1,5 jt',
        postedAgo: 'Hari ini',
        match: 92,
        deadline: 'Besok, 12:00',
        deadlineDate: DateTime.now().add(const Duration(hours: 12)),
      );

      expect(
        LowonganDilihatRepository()
            .pernahDilihat(userId: '2411521005', jobId: '99'),
        isFalse,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DetailScreen(item: closingSoonJob),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi lowongan otomatis tercatat sebagai "dilihat"
      expect(
        LowonganDilihatRepository()
            .pernahDilihat(userId: '2411521005', jobId: '99'),
        isTrue,
      );

      // Verifikasi banner peringatan batas akhir tampil
      expect(find.text('Batas Lamaran Segera Berakhir!'), findsOneWidget);
      expect(find.byIcon(Icons.alarm), findsOneWidget);
    });
  });

  group('FR-05 UI HomeScreen Notifikasi & Navigasi ke Detail', () {
    testWidgets(
        'Mengetuk notifikasi di HomeScreen membuka halaman detail lowongan tersebut',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final targetJob = JobRepository().findById('4')!;

      // Buat notifikasi pengingat batas akhir untuk job 4
      NotifikasiRepository().simulasiPengingatBatasAkhir(
        userId: '2411521005',
        job: targetJob,
        sisaJam: 18,
      );

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pump(const Duration(seconds: 3));

      // Verifikasi icon bell memiliki badge notifikasi 1
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      expect(find.text('1'), findsWidgets);

      // Buka Notification Sheet via bell icon
      await tester.tap(find.byIcon(Icons.notifications_active));
      await tester.pumpAndSettle();

      // Verifikasi isi notifikasi berisi judul lowongan
      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.textContaining(targetJob.title), findsWidgets);

      // PRD: "mengetuk notifikasi membuka halaman detail lowongan tersebut"
      await tester.tap(find.text('Buka detail lowongan →').first);
      await tester.pumpAndSettle();

      // Verifikasi halaman Detail lowongan terbuka
      expect(find.text('Detail'), findsOneWidget);
      expect(find.text(targetJob.title), findsWidgets);
      expect(find.text(targetJob.company), findsWidgets);
    });
  });
}
