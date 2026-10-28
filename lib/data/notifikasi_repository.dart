import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/job.dart';
import '../models/notifikasi.dart';
import 'lowongan_dilihat_repository.dart';

/// Data & service layer untuk sistem Notifikasi JobConnect (FR-05, FR-10, FR-15).
/// Mencatat notifikasi yang telah dikirim agar tidak terkirim ganda,
/// serta menentukan halaman tujuan saat notifikasi diketuk.
class NotifikasiRepository {
  static final NotifikasiRepository _instance =
      NotifikasiRepository._internal();
  factory NotifikasiRepository() => _instance;
  NotifikasiRepository._internal();

  final List<NotifikasiItem> _items = [];

  /// Notifier untuk UI reaktif (badge jumlah belum dibaca, daftar notifikasi, dll)
  final ValueNotifier<List<NotifikasiItem>> notifikasiNotifier =
      ValueNotifier<List<NotifikasiItem>>([]);

  /// Stream broadcast untuk memunculkan in-app banner saat ada notifikasi baru
  final StreamController<NotifikasiItem> _newNotifController =
      StreamController<NotifikasiItem>.broadcast();

  Stream<NotifikasiItem> get onNotifikasiBaru => _newNotifController.stream;

  void _notify() {
    notifikasiNotifier.value = List.unmodifiable(_items);
  }

  /// Cek apakah notifikasi untuk entitas tujuan dan jenis tertentu sudah pernah terkirim.
  /// Memenuhi PRD: "Mencatat notifikasi yang telah dikirim agar tidak terkirim ganda".
  bool sudahTerkirim({
    required String userId,
    required String idTujuan,
    required JenisNotifikasi jenis,
  }) {
    return _items.any(
      (n) => n.userId == userId && n.idTujuan == idTujuan && n.jenis == jenis,
    );
  }

  /// FR-05: Pengecekan otomatis pengingat batas akhir lowongan.
  /// Sistem mengirim pengingat kepada pengguna saat lowongan yang pernah
  /// dilihat detailnya akan ditutup dalam 24 jam, berisi judul lowongan.
  List<NotifikasiItem> periksaPengingatBatasAkhir({
    required String userId,
    required List<Job> semuaLowongan,
    DateTime? waktuSekarang,
  }) {
    final now = waktuSekarang ?? DateTime.now();
    final viewedJobIds =
        LowonganDilihatRepository().getJobIdsDilihat(userId);
    final List<NotifikasiItem> generated = [];

    for (final job in semuaLowongan) {
      // 1. Hanya periksa lowongan yang PERNAH DILIHAT detailnya oleh pengguna (PRD FR-05)
      if (!viewedJobIds.contains(job.id)) continue;

      // 2. Hindari pengiriman ganda untuk lowongan yang sama
      if (sudahTerkirim(
        userId: userId,
        idTujuan: job.id,
        jenis: JenisNotifikasi.pengingatBatasAkhir,
      )) {
        continue;
      }

      final closing = job.closingDate;
      if (closing == null) continue;

      final diff = closing.difference(now);

      // 3. Syarat: akan ditutup dalam kurun waktu 24 jam (dan belum kadaluarsa)
      if (!diff.isNegative && diff <= const Duration(hours: 24)) {
        final hours = diff.inHours;
        final sisaWaktu = hours < 1
            ? 'kurang dari 1 jam'
            : '$hours jam';

        final item = NotifikasiItem(
          id: 'NTF-DL-${job.id}-${now.millisecondsSinceEpoch}',
          userId: userId,
          jenis: JenisNotifikasi.pengingatBatasAkhir,
          judul: 'Pengingat Batas Akhir Lowongan',
          pesan:
              'Lowongan "${job.title}" di ${job.company} akan segera ditutup dalam $sisaWaktu! Segera lengkapi dan kirim lamaranmu.',
          waktu: now,
          idTujuan: job.id,
          extraData: job.company,
        );

        _items.insert(0, item);
        generated.add(item);
        _newNotifController.add(item);
      }
    }

    if (generated.isNotEmpty) {
      _notify();
    }

    return generated;
  }

  /// Simulasi manual untuk pengujian / demonstrasi demo FR-05
  NotifikasiItem simulasiPengingatBatasAkhir({
    required String userId,
    required Job job,
    int sisaJam = 18,
  }) {
    // Catat bahwa lowongan pernah dilihat
    LowonganDilihatRepository().catatDilihat(
      userId: userId,
      jobId: job.id,
    );

    final item = NotifikasiItem(
      id: 'NTF-SIM-${job.id}-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      jenis: JenisNotifikasi.pengingatBatasAkhir,
      judul: 'Pengingat Batas Akhir Lowongan',
      pesan:
          'Lowongan "${job.title}" di ${job.company} akan segera ditutup dalam $sisaJam jam! Segera lengkapi dan kirim lamaranmu.',
      waktu: DateTime.now(),
      idTujuan: job.id,
      extraData: job.company,
    );

    _items.insert(0, item);
    _notify();
    _newNotifController.add(item);
    return item;
  }

  /// Ambil seluruh notifikasi untuk pengguna tertentu
  List<NotifikasiItem> getNotifikasi(String userId) {
    return _items.where((n) => n.userId == userId).toList();
  }

  /// Ambil jumlah notifikasi yang belum dibaca
  int getUnreadCount(String userId) {
    return _items.where((n) => n.userId == userId && !n.isRead).length;
  }

  /// Tandai notifikasi tertentu sebagai telah dibaca
  void tandaiDibaca(String notifikasiId) {
    final index = _items.indexWhere((n) => n.id == notifikasiId);
    if (index >= 0 && !_items[index].isRead) {
      _items[index] = _items[index].copyWith(isRead: true);
      _notify();
    }
  }

  /// Tandai semua notifikasi pengguna sebagai telah dibaca
  void tandaiSemuaDibaca(String userId) {
    bool changed = false;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].userId == userId && !_items[i].isRead) {
        _items[i] = _items[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      _notify();
    }
  }

  /// Hapus satu notifikasi
  void hapusNotifikasi(String notifikasiId) {
    _items.removeWhere((n) => n.id == notifikasiId);
    _notify();
  }

  /// Reset semua notifikasi (untuk testing)
  void reset() {
    _items.clear();
    _notify();
  }
}
