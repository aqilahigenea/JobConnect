import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_connect/data/job_repository.dart';
import 'package:job_connect/models/job.dart';
import 'package:job_connect/screens/detail_screen.dart';

void main() {
  group('FR-04 Lokasi & Koordinat Lowongan (Job Model)', () {
    test('Job memiliki koordinat latitude dan longitude default', () {
      const job = Job(
        id: 'test',
        title: 'Tester',
        company: 'Company',
        location: 'Padang',
        type: 'Magang',
        description: 'Testing',
        salary: '1 jt',
        postedAgo: 'Hari ini',
        match: 90,
      );

      expect(job.latitude, -0.9471);
      expect(job.longitude, 100.4172);
    });

    test('Data dummy di JobRepository memiliki koordinat lokasi yang valid',
        () async {
      final repo = JobRepository();
      final jobs = await repo.fetchJobs();

      expect(jobs.isNotEmpty, isTrue);
      for (final job in jobs) {
        expect(job.latitude, isNotNull);
        expect(job.longitude, isNotNull);
        // Koordinat area Sumatera Barat / Padang
        expect(job.latitude, lessThan(0.0));
        expect(job.longitude, greaterThan(100.0));
      }
    });
  });

  group('FR-04 UI Peta Interaktif di DetailScreen', () {
    const sampleJob = Job(
      id: '1',
      title: 'UI/UX Designer Intern',
      company: 'Teknologi Ranah',
      location: 'Remote',
      type: 'Magang',
      description: 'Desain UI/UX',
      salary: 'Rp 2,5 jt',
      postedAgo: '1 hari lalu',
      match: 95,
      officeName: 'Teknologi Ranah (Remote)',
      fullAddress: 'Pekerjaan dilakukan secara online dari mana saja.',
      latitude: -0.9165,
      longitude: 100.4572,
    );

    testWidgets('DetailScreen menampilkan peta interaktif FlutterMap & pin',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: DetailScreen(item: sampleJob),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi section Lokasi Tempat Kerja
      expect(find.text('Lokasi Tempat Kerja'), findsOneWidget);
      expect(find.text('Teknologi Ranah (Remote)'), findsWidgets);

      // Verifikasi widget FlutterMap interaktif tampil
      expect(find.byType(FlutterMap), findsOneWidget);

      // Verifikasi tombol kontrol peta (Zoom & Recenter)
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);

      // Verifikasi indikator jarak dari Kampus Unand
      expect(find.textContaining('dari Kampus Unand'), findsOneWidget);

      // Verifikasi tombol Buka di Google Maps
      expect(find.text('Buka di Google Maps'), findsOneWidget);
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    });

    testWidgets('Ketuk pin lokasi menampilkan/menyembunyikan tooltip info',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: DetailScreen(item: sampleJob),
        ),
      );

      await tester.pumpAndSettle();

      // Pin lokasi awal menampilkan tooltip nama perusahaan
      expect(find.text('Teknologi Ranah'), findsWidgets);

      // Cari ikon pin lokasi
      final pinIcon = find.byIcon(Icons.location_on);
      expect(pinIcon, findsWidgets);

      // Ketuk pin untuk toggle tooltip
      await tester.tap(pinIcon.first);
      await tester.pumpAndSettle();
    });
  });
}
