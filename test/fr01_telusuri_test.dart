import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_connect/data/job_repository.dart';
import 'package:job_connect/screens/home_screen.dart';

void main() {
  group('FR-01 Telusuri / Browse Lowongan (JobRepository)', () {
    final repo = JobRepository();

    test('Memuat semua data lowongan dummy', () async {
      final jobs = await repo.fetchJobs();
      expect(jobs.length, 6);
    });

    test('Filter berdasarkan jenis pekerjaan (FR-02 & FR-01)', () async {
      final jobs = await repo.fetchJobs();

      final magang = repo.filterJobs(source: jobs, typeFilter: 'Magang');
      expect(magang.every((j) => j.type == 'Magang'), isTrue);
      expect(magang.length, 2);

      final paruhWaktu =
          repo.filterJobs(source: jobs, typeFilter: 'Paruh Waktu');
      expect(paruhWaktu.every((j) => j.type == 'Paruh Waktu'), isTrue);
      expect(paruhWaktu.length, 2);

      final freelance = repo.filterJobs(source: jobs, typeFilter: 'Freelance');
      expect(freelance.every((j) => j.type == 'Freelance'), isTrue);
      expect(freelance.length, 2);
    });

    test('Telusuri berdasarkan judul lowongan', () async {
      final jobs = await repo.fetchJobs();

      final barista = repo.filterJobs(source: jobs, query: 'barista');
      expect(barista.length, 1);
      expect(barista.first.title, contains('Barista'));

      final designer = repo.filterJobs(source: jobs, query: 'designer');
      expect(designer.length, 1);
      expect(designer.first.title, contains('UI/UX Designer'));
    });

    test('Telusuri berdasarkan nama perusahaan', () async {
      final jobs = await repo.fetchJobs();

      final fore = repo.filterJobs(source: jobs, query: 'fore');
      expect(fore.length, 1);
      expect(fore.first.company, 'Fore Coffee');

      final ruangguru = repo.filterJobs(source: jobs, query: 'ruangguru');
      expect(ruangguru.length, 1);
      expect(ruangguru.first.company, 'Ruangguru');
    });

    test('Telusuri berdasarkan lokasi pekerjaan', () async {
      final jobs = await repo.fetchJobs();

      final remote = repo.filterJobs(source: jobs, query: 'remote');
      expect(remote.length, 2);
      expect(remote.every((j) => j.location == 'Remote'), isTrue);
    });

    test('Telusuri dengan kata kunci yang tidak ada menghasilkan list kosong',
        () async {
      final jobs = await repo.fetchJobs();

      final none = repo.filterJobs(source: jobs, query: 'astronaut');
      expect(none.isEmpty, isTrue);
    });
  });

  group('FR-01 UI HomeScreen Search & Browse Widget Test', () {
    testWidgets('Tampilan HomeScreen memuat TextField pencarian & chip filter',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Loading state
      expect(find.text('Memuat lowongan...'), findsOneWidget);

      // Selesaikan delay 2 detik dari repository dummy
      await tester.pump(const Duration(seconds: 3));

      // Verifikasi komponen pencarian & telusuri tampil
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cari lowongan kerja...'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Magang'), findsWidgets);
      expect(find.text('Paruh Waktu'), findsWidgets);
      expect(find.text('Freelance'), findsWidgets);
    });

    testWidgets('Mengetik kata kunci di bar pencarian memfilter hasil lowongan',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump(const Duration(seconds: 3));

      // Sebelum pencarian: ada lowongan terbaru & sesuai preferensi
      expect(find.text('Lowongan Terbaru'), findsOneWidget);

      // Ketik 'barista'
      await tester.enterText(find.byType(TextField), 'barista');
      await tester.pump();

      // Menampilkan header Hasil Telusuri
      expect(find.text('Hasil Telusuri'), findsOneWidget);
      expect(find.text('Barista Paruh Waktu'), findsOneWidget);
      expect(find.text('1 Ditemukan'), findsOneWidget);

      // Hapus pencarian via ikon silang
      final clearButton = find.byTooltip('Hapus pencarian');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      // Kembali ke tampilan normal
      expect(find.text('Lowongan Terbaru'), findsOneWidget);
      expect(find.text('Sesuai Preferensi'), findsOneWidget);
    });

    testWidgets('Pencarian tanpa hasil menampilkan empty state & tombol reset',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump(const Duration(seconds: 3));

      // Ketik kata kunci yang tidak ada
      await tester.enterText(find.byType(TextField), 'pilot pesawat');
      await tester.pump();

      expect(find.text('Tidak ada lowongan ditemukan'), findsOneWidget);
      expect(find.text('Reset Pencarian'), findsOneWidget);

      // Tekan tombol Reset Pencarian
      await tester.tap(find.text('Reset Pencarian'));
      await tester.pump();

      // Kembali ke tampilan normal
      expect(find.text('Lowongan Terbaru'), findsOneWidget);
    });
  });
}
