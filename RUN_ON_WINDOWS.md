# Cara Menjalankan Aplikasi di Windows

Berikut adalah langkah-langkah untuk menjalankan aplikasi **Ingat.in** di lingkungan Windows:

## 1. Pastikan Flutter SDK Terinstal

Pastikan Anda sudah menginstal Flutter SDK di komputer Anda. Jika belum, Anda bisa mengunduhnya dari [situs resmi Flutter](https://flutter.dev/docs/get-started/install/windows).

## 2. Konfigurasi Environment Variables

Tambahkan path ke folder `bin` di dalam direktori instalasi Flutter Anda ke dalam **Environment Variables** sistem. Contoh: `C:\flutter\bin`.

## 3. Buka Proyek

Buka direktori proyek **Ingat.in** menggunakan terminal atau command prompt.

## 4. Dapatkan Dependensi

Jalankan perintah berikut untuk mengunduh semua dependensi yang dibutuhkan oleh proyek:

```bash
flutter pub get
```

## 5. Jalankan Aplikasi

Setelah semua dependensi terunduh, jalankan aplikasi dengan perintah berikut:

```bash
flutter run -d windows
```

Aplikasi akan dicompile dan dijalankan di jendela Windows.

---

*Jika Anda mengalami masalah, pastikan semua konfigurasi Flutter dan Visual Studio (untuk pengembangan Windows) sudah benar.*
