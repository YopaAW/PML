Tentu, ini adalah breakdown rencana kerja dalam format checklist per sprint untuk pengembangan MVP "Ingat.in" selama 14 minggu. Rencana ini mengasumsikan model kerja Agile dengan durasi satu sprint = 2 minggu.

Roadmap Pengembangan MVP "Ingat.in" (Total: 14 Minggu / 7 Sprint)
Sprint 0: Persiapan (Dilakukan sebelum sprint pertama dimulai)

Finalisasi Desain UI/UX (Figma, Sketch, atau sketsa tangan).

Inisialisasi repositori Git (GitHub, GitLab, dll.).

Siapkan project board (Trello, Jira, Asana) dengan backlog dari daftar di bawah.

Pastikan lingkungan pengembangan semua anggota tim sudah siap.

Sprint 1 (Minggu 1-2): Fondasi Arsitektur & Proyek

Tujuan Sprint: Proyek Flutter berhasil dibuat dengan semua dependensi dan struktur folder Clean Architecture yang benar. Entitas inti dan kontrak repository sudah didefinisikan.

[ ] Setup Proyek:

Buat proyek Flutter baru.

Tambahkan dependensi di pubspec.yaml: riverpod_generator, freezed, go_router, fpdart, logger, drift, flutter_local_notifications.

Konfigurasi build_runner untuk code generation.

[ ] Arsitektur:

Buat struktur direktori untuk Clean Architecture (lib/src, features, core, dll.).

Buat layer domain, application, data, dan presentation.

[ ] Domain Layer:

Buat Reminder entity menggunakan Freezed.

Buat IReminderRepository (kontrak/interface) yang mendefinisikan metode CRUD (misal: addReminder, watchReminders, dll.).

[ ] Dokumentasi:

Inisialisasi README.md dengan deskripsi proyek dan instruksi setup.

Sprint 2 (Minggu 3-4): Lapisan Data & Logika Inti

Tujuan Sprint: Aplikasi mampu menyimpan dan mengambil data pengingat dari database lokal. Semua logika bisnis inti sudah bisa diuji tanpa UI.

[ ] Data Layer:

Konfigurasi Drift: Buat file database dan definisikan tabel reminders.

Jalankan build_runner untuk men-generate kode database Drift.

Buat ReminderRepositoryImpl yang mengimplementasikan IReminderRepository.

Implementasikan logika untuk addReminder, updateReminder, dan watchAllReminders menggunakan Drift.

[ ] Application Layer:

Buat AddReminderUseCase.

Buat GetUpcomingRemindersUseCase.

[ ] Pengujian:

Tulis Unit Test untuk Use Cases.

Tulis Integration Test untuk ReminderRepositoryImpl menggunakan database Drift in-memory untuk memastikan logika CRUD berfungsi.

Sprint 3 (Minggu 5-6): Implementasi UI Utama (Read & Create)

Tujuan Sprint: Pengguna dapat melihat daftar pengingat yang ada dan berhasil membuat pengingat baru melalui antarmuka pengguna.

[ ] Presentation Layer (UI):

Buat UI untuk Layar Utama (HomePage) yang akan menampilkan daftar pengingat.

Buat UI untuk Halaman Tambah/Edit Pengingat (AddEditPage) dengan semua form input yang diperlukan (judul, tanggal, waktu).

[ ] State Management (Riverpod):

Buat reminderListProvider untuk menghubungkan GetUpcomingRemindersUseCase ke HomePage.

Buat addReminderController (Notifier/AsyncNotifier) untuk menangani logika dan state saat menyimpan pengingat baru.

[ ] Navigasi:

Konfigurasi Go_Router untuk navigasi antara HomePage dan AddEditPage.

Implementasikan navigasi saat tombol + ditekan dan setelah pengingat berhasil disimpan.

Sprint 4 (Minggu 7-8): Fungsionalitas Notifikasi

Tujuan Sprint: Aplikasi mampu menjadwalkan dan membatalkan notifikasi lokal secara andal. Ini adalah fitur inti yang paling krusial.

[ ] Infrastructure Layer:

Integrasikan package flutter_local_notifications.

Buat NotificationService untuk abstraksi logika notifikasi.

Implementasikan fungsi untuk meminta izin notifikasi di Android & iOS.

[ ] Application Layer:

Buat ScheduleNotificationUseCase.

Buat CancelNotificationUseCase.

[ ] Integrasi Fitur:

Panggil ScheduleNotificationUseCase setelah pengingat berhasil dibuat/diubah.

Implementasikan pilihan waktu notifikasi di UI (AddEditPage).

Panggil CancelNotificationUseCase saat pengingat dihapus.

[ ] Pengujian:

Uji secara manual di perangkat fisik untuk memastikan notifikasi muncul saat aplikasi ditutup atau di background.

Sprint 5 (Minggu 9-10): Penyelesaian Fitur & Poles UI/UX

Tujuan Sprint: Semua fungsionalitas MVP lengkap dan aplikasi terasa nyaman digunakan dengan visual yang rapi.

[ ] Fungsionalitas CRUD (Update & Delete):

Implementasikan alur untuk mengedit pengingat yang sudah ada.

Implementasikan fitur hapus pengingat (misalnya dengan gestur swipe-to-delete).

Implementasikan fitur "Tandai Selesai" dengan checkbox atau gestur.

[ ] UI/UX Polish:

Implementasikan Tema Terang & Gelap (Light/Dark Mode).

Tambahkan empty state di HomePage (ketika belum ada pengingat).

Tambahkan feedback untuk pengguna (misalnya SnackBar saat berhasil menyimpan).

Rapikan layout, ikon, dan tipografi.

Sprint 6 (Minggu 11-12): Pengujian Menyeluruh & Perbaikan Bug

Tujuan Sprint: Aplikasi dalam kondisi "feature-freeze". Fokus penuh pada identifikasi dan perbaikan bug untuk mencapai stabilitas rilis.

[ ] Pengujian Kualitas (QA):

Lakukan pengujian manual end-to-end untuk semua alur pengguna di berbagai perangkat (fisik dan emulator).

Uji di berbagai versi OS Android dan iOS.

Uji kasus-kasus khusus (edge cases): tidak ada koneksi internet, input yang aneh, izin ditolak, dll.

[ ] Manajemen Bug:

Dokumentasikan semua bug yang ditemukan di project board.

Prioritaskan perbaikan bug (kritis > mayor > minor).

Alokasikan seluruh waktu sprint untuk perbaikan bug.

[ ] Pengujian Otomatis:

Tambahkan Widget Tests untuk memastikan komponen UI penting berfungsi seperti yang diharapkan.

Sprint 7 (Minggu 13-14): Persiapan Rilis & Buffer

Tujuan Sprint: Aplikasi siap untuk diunggah ke Google Play Store . Semua aset dan metadata rilis sudah lengkap.

[ ] Aset Rilis:

Buat ikon aplikasi final (dengan berbagai ukuran yang dibutuhkan).

Buat splash screen.

Ambil screenshots aplikasi untuk halaman listing di store.

[ ] Persiapan Teknis:

Lakukan konfigurasi rilis di Flutter (version code, version name, signing).

Buat build rilis final (.aab untuk Google Play).

Lakukan smoke testing terakhir pada build rilis.

[ ] Publikasi:

Siapkan halaman listing di Google Play Console .

Tulis deskripsi aplikasi, kebijakan privasi, dan isi semua metadata yang diperlukan.

Unggah build dan kirim untuk ditinjau.

[ ] Buffer:

Alokasikan sisa waktu untuk menangani masalah tak terduga, seperti penolakan dari Apple atau bug kritis yang baru ditemukan.