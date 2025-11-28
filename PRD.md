# Product Requirements Document (PRD) - Ingat.in

## 1. Apa itu Ingat.in?

Ingat.in adalah aplikasi mobile yang dirancang untuk membantu pengguna mengelola pengingat harian mereka dengan mudah dan efisien. Aplikasi ini memungkinkan pengguna untuk membuat, mengatur, dan melacak tugas-tugas penting melalui antarmuka yang sederhana dan intuitif. Dengan fitur notifikasi yang andal, Ingat.in memastikan tidak ada lagi tenggat waktu atau acara penting yang terlewat.

## 2. Fitur Aplikasi

### 2.1 Fitur Gratis

- **Pengelolaan Pengingat:**
    - Membuat, mengedit, dan menghapus pengingat dengan judul, deskripsi, tanggal, dan waktu.
    - Menandai pengingat sebagai 'selesai'.
    - Melihat daftar semua pengingat.
    - Terbatas hingga 10 slot pengingat aktif.
- **Notifikasi:**
    - Menerima notifikasi real-time untuk setiap pengingat.
- **Kategori Dasar:**
    - Menggunakan kategori default (Pribadi, Kerja, Kesehatan, Belanja) untuk mengorganisir pengingat.
 **Tema Kustom:**
    - Mengubah tampilan aplikasi dengan berbagai pilihan tema eksklusif.
- **Filter Pengingat:**
    - Memfilter pengingat berdasarkan bulan dan kategori.
- **Donasi:**
    - Opsi untuk memberikan donasi sukarela kepada pengembang.

### 2.2 Fitur Premium (Berbayar)

- **Pengingat Berulang (Looping):**
    - Mengatur pengingat agar berulang secara harian, mingguan, bulanan, atau tahunan.
- **Manajemen Kategori Kustom:**
    - Membuat, mengedit, dan menghapus kategori sesuai kebutuhan pribadi.
- **Sinkronisasi Antar Perangkat:**
    - Menyinkronkan semua pengingat dan kategori di berbagai perangkat.
- **Backup & Restore Data:**
    - Mencadangkan dan memulihkan data pengingat dengan aman.

## 3. Siapa yang Akan Menggunakan?

- **Pelajar & Mahasiswa:** Untuk mencatat jadwal kelas, tugas, dan ujian.
- **Profesional:** Untuk mengelola tenggat waktu proyek, rapat, dan tugas pekerjaan.
- **Ibu Rumah Tangga:** Untuk mengatur jadwal belanja, pembayaran tagihan, dan acara keluarga.
- **Siapa Saja:** Yang membutuhkan alat bantu untuk mengingat aktivitas dan tugas sehari-hari.

## 4. Teknologi yang Digunakan

- **Framework:** Flutter
- **Bahasa Pemrograman:** Dart
- **Database Lokal:** Hive
- **Manajemen State:** Provider
- **Notifikasi:** `flutter_local_notifications`

## 5. Model Bisnis

- **Freemium:** Aplikasi dapat diunduh dan digunakan secara gratis dengan fitur-fitur dasar. Fitur-fitur canggih.

- **Pembelian In-App (Slot Tambahan):**
    - **5 Slot:** Rp 15.000
    - **10 Slot:** Rp 25.000
    - **25 Slot:** Rp 50.000
- **Donasi:** Pengguna dapat memberikan donasi sukarela sebagai bentuk dukungan kepada pengembang.

## 6. Tujuan Sukses

- **Jangka Pendek (3-6 bulan):**
    - Mencapai 1.000 unduhan di Google Play Store.
    - Mendapatkan rating rata-rata 3.0 atau lebih tinggi.
    - Mengonversi 1% pengguna gratis menjadi pengguna berbayar.
- **Jangka Menengah (1 tahun):**
    - Mencapai 5.000 unduhan.
    - Meluncurkan versi iOS.
    - Memperkenalkan fitur sinkronisasi cloud.
- **Jangka Panjang (2-3 tahun):**
    - Menjadi salah satu aplikasi pengingat teratas di pasar lokal.
    - Membangun komunitas pengguna yang aktif.
    - Mencapai 10.000 pengguna aktif bulanan.