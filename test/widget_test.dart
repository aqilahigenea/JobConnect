import 'package:flutter_test/flutter_test.dart';
import 'package:job_connect/data/lamaran_repository.dart';
import 'package:job_connect/models/cv_document.dart';
import 'package:job_connect/models/job.dart';
import 'package:job_connect/models/lamaran.dart';
import 'package:job_connect/utils/lamaran_validators.dart';

void main() {
  test('No. HP: valid dan tidak valid', () {
    expect(LamaranValidators.noHp('081234567890'), isNull);
    expect(LamaranValidators.noHp('12345'), isNotNull);
  });

  test('Pesan opsional, tapi kalau diisi minimal 10 karakter', () {
    expect(LamaranValidators.pesan(''), isNull);
    expect(LamaranValidators.pesan('pendek'), isNotNull);
  });

  test('FR-08: lamaran berstatus diproses dapat diubah', () async {
    final repo = LamaranRepository();
    const job = Job(
      id: 'TEST-FR08',
      title: 'Tester',
      company: 'PT Uji',
      location: 'Padang',
      type: 'Magang',
      description: '-',
      salary: '-',
      postedAgo: '-',
      match: 0,
    );
    const cv = CvDocument(name: 'CV.pdf', sizeInBytes: 1000);

    final dikirim = await repo.submit(
      job: job,
      namaPelamar: 'Budi',
      email: 'budi@mail.com',
      noHp: '081234567890',
      pesan: '',
      cv: cv,
    );
    final diubah = await repo.update(
      id: dikirim.id,
      namaPelamar: 'Budi Santoso',
      email: dikirim.email,
      noHp: dikirim.noHp,
      pesan: dikirim.pesan,
      cv: dikirim.cv,
    );

    // yang diedit berubah, yang tidak boleh berubah tetap sama
    expect(diubah.namaPelamar, 'Budi Santoso');
    expect(diubah.status, LamaranStatus.diproses);
    expect(diubah.tanggalPengajuan, dikirim.tanggalPengajuan);
    expect(repo.findById(dikirim.id)?.namaPelamar, 'Budi Santoso');
  });

  test('FR-08: id tidak ditemukan -> LamaranException', () async {
    final repo = LamaranRepository();
    const cv = CvDocument(name: 'CV.pdf', sizeInBytes: 1000);
    expect(
      () => repo.update(
        id: 'TIDAK-ADA',
        namaPelamar: 'Budi',
        email: 'b@mail.com',
        noHp: '081234567890',
        pesan: '',
        cv: cv,
      ),
      throwsA(isA<LamaranException>()),
    );
  });
}