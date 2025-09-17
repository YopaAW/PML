Tentu, dengan senang hati.

Software Requirements Specification (SRS) adalah dokumen yang lebih formal dan teknis dibandingkan PRD. Dokumen ini mendeskripsikan perilaku sistem yang akan dibangun secara lengkap. SRS berfungsi sebagai kontrak antara tim pengembang dan pemangku kepentingan produk, memastikan semua orang memiliki pemahaman yang sama tentang apa yang harus dibuat.

Berikut adalah draf SRS untuk aplikasi "Ingat.in".

Software Requirements Specification: Ingat.in
Versi	Tanggal	Penulis	Status
1.0	17 September 2025	Gemini & User	Draf Awal
1. Pendahuluan
1.1 Tujuan

Dokumen ini bertujuan untuk memberikan deskripsi yang detail dan komprehensif mengenai spesifikasi fungsional dan non-fungsional untuk aplikasi mobile Ingat.in versi 1.0 (Minimum Viable Product - MVP). Dokumen ini akan menjadi acuan utama bagi tim desainer, pengembang, dan penguji kualitas (QA) selama siklus hidup pengembangan produk.

1.2 Lingkup Produk

Ingat.in adalah aplikasi pengingat (reminder) yang beroperasi secara lokal (offline-first) untuk platform iOS dan Android. Lingkup produk untuk versi 1.0 mencakup kemampuan untuk membuat, melihat, mengedit, dan menghapus pengingat, serta menerima notifikasi yang andal. Aplikasi ini secara sengaja tidak akan mencakup fitur-fitur seperti sinkronisasi cloud, registrasi pengguna, atau fitur kolaborasi untuk menjaga kesederhanaan dan privasi.

1.3 Definisi, Akronim, dan Singkatan

SRS: Software Requirements Specification

MVP: Minimum Viable Product

UI: User Interface (Antarmuka Pengguna)

UX: User Experience (Pengalaman Pengguna)

CRUD: Create, Read, Update, Delete

Clean Architecture: Pola desain perangkat lunak yang memisahkan logika aplikasi ke dalam beberapa lapisan independen (Presentation, Domain, Data).

Offline-first: Prinsip di mana aplikasi dirancang untuk berfungsi sepenuhnya tanpa koneksi internet.

2. Deskripsi Keseluruhan
2.1 Perspektif Produk

Ingat.in adalah produk mandiri dan baru. Aplikasi ini tidak bergantung pada sistem eksternal manapun. Semua data dan logika bisnis dikelola di sisi klien (perangkat pengguna).

2.2 Fungsi Produk

Fungsi utama dari aplikasi Ingat.in adalah:

Manajemen Pengingat: Pengguna dapat melakukan operasi CRUD pada data pengingat.

Penjadwalan Notifikasi: Sistem secara otomatis menjadwalkan notifikasi lokal berdasarkan waktu yang ditentukan pengguna.

Manajemen Status: Pengguna dapat menandai pengingat yang telah selesai.

2.3 Karakteristik Pengguna

Target pengguna adalah individu yang membutuhkan alat pengingat yang cepat, efisien, dan privat, seperti:

Mahasiswa: Untuk mengingat jadwal kuliah, tugas, dan kegiatan sosial.

Profesional: Untuk mengelola janji temu, tenggat waktu, dan urusan pribadi di luar kalender kerja.

Pengguna Umum: Untuk kebutuhan sehari-hari seperti membayar tagihan, belanja, atau acara keluarga.

2.4 Batasan (Constraints)

Batasan Arsitektur: Aplikasi harus dikembangkan menggunakan arsitektur Clean Code.

Batasan Teknologi:

Framework: Flutter

State Management: Riverpod (dengan Riverpod Generator)

Database Lokal: Drift (SQLite)

Navigasi: Go_Router

Batasan Platform: Aplikasi harus kompatibel dengan Android (SDK 21 ke atas) dan iOS (versi 12.0 ke atas).

Batasan Privasi: Aplikasi tidak boleh mengumpulkan atau mengirimkan data pengguna apapun ke server eksternal. Tidak boleh ada sistem login atau registrasi.

2.5 Asumsi dan Ketergantungan

Pengguna memberikan izin yang diperlukan aplikasi untuk menampilkan notifikasi.

Sistem operasi perangkat pengguna dapat mengirimkan notifikasi lokal secara andal.

Perangkat pengguna memiliki ruang penyimpanan yang cukup untuk database lokal.

3. Persyaratan Spesifik
3.1 Persyaratan Fungsional

Modul 1: Manajemen Pengingat

ID	Deskripsi Persyaratan
REQ-FUNC-001	Membuat Pengingat: Sistem harus menyediakan formulir untuk membuat pengingat baru dengan input berikut: <br> a. Judul (Teks, Wajib Diisi) <br> b. Deskripsi (Teks, Opsional) <br> c. Tanggal Kegiatan (Pemilih Tanggal, Wajib Diisi) <br> d. Waktu Kegiatan (Pemilih Waktu, Wajib Diisi)
REQ-FUNC-002	Validasi Input: Sistem harus menolak pembuatan pengingat jika judul kosong atau jika kombinasi tanggal dan waktu berada di masa lalu.
REQ-FUNC-003	Melihat Daftar Pengingat: Sistem harus menampilkan semua pengingat yang belum selesai di layar utama, diurutkan secara kronologis (waktu terdekat di atas).
REQ-FUNC-004	Mengubah Pengingat: Pengguna harus dapat memilih pengingat yang ada dan mengubah semua detailnya melalui formulir yang sama dengan REQ-FUNC-001.
REQ-FUNC-005	Menghapus Pengingat: Pengguna harus dapat menghapus pengingat. Setelah dihapus, pengingat tersebut harus hilang dari daftar dan notifikasi yang terjadwal harus dibatalkan.
REQ-FUNC-006	Menandai Selesai: Pengguna harus dapat menandai pengingat sebagai "selesai". Pengingat yang selesai harus dibedakan secara visual (misalnya, dicoret) atau disembunyikan dari tampilan utama.

Modul 2: Sistem Notifikasi

ID	Deskripsi Persyaratan
REQ-FUNC-007	Konfigurasi Waktu Notifikasi: Saat membuat atau mengubah pengingat, pengguna harus dapat memilih kapan notifikasi akan muncul dari opsi berikut: <br> a. Tepat Waktu <br> b. 15 Menit Sebelumnya <br> c. 30 Menit Sebelumnya <br> d. 1 Jam Sebelumnya
REQ-FUNC-008	Penjadwalan Otomatis: Sistem harus secara otomatis menjadwalkan notifikasi lokal setiap kali pengingat berhasil dibuat atau diubah.
REQ-FUNC-009	Pembatalan Notifikasi: Sistem harus secara otomatis membatalkan notifikasi yang terjadwal jika pengingat terkait dihapus.
REQ-FUNC-010	Permintaan Izin: Saat pertama kali aplikasi mencoba menjadwalkan notifikasi, sistem harus meminta izin notifikasi kepada pengguna jika belum diberikan.
3.2 Persyaratan Non-Fungsional
ID	Kategori	Deskripsi Persyaratan
REQ-NFR-001	Performa	Waktu cold start aplikasi harus kurang dari 2 detik. Semua transisi UI dan animasi harus berjalan lancar (mendekati 60 FPS) tanpa lag.
REQ-NFR-002	Keandalan	Aplikasi tidak boleh crash selama menjalankan alur fungsi utama. Notifikasi harus terkirim sesuai jadwal dengan tingkat keandalan >99% (tergantung batasan OS).
REQ-NFR-003	Keamanan	Semua data pengguna (pengingat, deskripsi) harus disimpan secara eksklusif di penyimpanan lokal perangkat. Aplikasi tidak boleh membuat koneksi jaringan untuk mentransfer data pengguna.
REQ-NFR-004	Kegunaan	Alur untuk membuat pengingat baru harus dapat diselesaikan dalam kurang dari 4 kali tap/interaksi dari layar utama. Antarmuka harus intuitif dan tidak memerlukan tutorial.
REQ-NFR-005	Pemeliharaan	Kode sumber harus mengikuti prinsip Clean Architecture, terdokumentasi dengan baik, dan memiliki pemisahan yang jelas antara lapisan-lapisan aplikasi.
3.3 Persyaratan Antarmuka (Interface Requirements)

Antarmuka Pengguna (UI):

Desain harus minimalis, bersih, dan fokus pada konten.

Aplikasi harus mendukung Tema Terang (Light Mode) dan Tema Gelap (Dark Mode), dan dapat beradaptasi dengan pengaturan sistem.

Desain harus mengikuti pedoman Human Interface Guidelines dari Apple untuk platform iOS dan Material Design 3 untuk platform Android.

3.4 Persyaratan Database

Sistem akan menggunakan database SQLite yang dikelola oleh library Drift. Skema database harus mencakup tabel-tabel berikut untuk MVP dan pengembangan di masa depan:

Tabel reminders: Untuk menyimpan detail setiap pengingat (id, judul, deskripsi, tanggal, offset notifikasi, status selesai, dll.).

Tabel categories: (Disiapkan untuk masa depan) Untuk menyimpan kategori yang bisa dibuat pengguna (id, nama, warna).

Tabel subtasks: (Disiapkan untuk masa depan) Untuk menyimpan item checklist yang terkait dengan sebuah pengingat.

Catatan: Detail lengkap skema database mengacu pada dokumen Desain Skema Database yang telah dibuat sebelumnya.