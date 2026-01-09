# Persiapan Firebase untuk Ingat.in

Dokumen ini menjelaskan langkah-langkah yang perlu dilakukan untuk menghubungkan aplikasi Ingat.in dengan Firebase sebagai pengganti database lokal Hive.

## 1. Membuat Proyek Firebase

1.  Buka [Firebase Console](https://console.firebase.google.com/).
2.  Klik **Add project** (Tambah proyek).
3.  Beri nama proyek (misalnya: `ingatin-app`) dan ikuti langkah-langkahnya (Anda bisa menonaktifkan Google Analytics untuk saat ini).
4.  Klik **Create project**.

## 2. Menyiapkan Firestore Database

1.  Di sidebar kiri dashboard Firebase, pilih **Build** > **Firestore Database**.
2.  Klik **Create database**.
3.  Pilih lokasi server (misalnya: `asia-southeast2` untuk Jakarta, atau biarkan default `us-central1`).
4.  Pilih **Start in Test Mode** (Mulai dalam mode pengujian) untuk pengembangan awal. Ini memungkinkan baca/tulis tanpa autentikasi selama 30 hari.
    *   *Catatan: Nanti aturan keamanan (Security Rules) perlu diperbarui sebelum rilis.*
5.  Klik **Create**.

## 3. Menambahkan Aplikasi ke Proyek Firebase

### Untuk Android
1.  Klik ikon **Android** di halaman Overview proyek.
2.  Masukkan **Android package name**. Nama paket bisa dilihat di file `android/app/build.gradle` (biasanya `com.example.ingatin` atau sesuai yang Anda set).
    *   Cek file: `android/app/build.gradle` -> `applicationId`
3.  (Opsional) Masukkan nama aplikasi (misal: `Ingatin Android`).
4.  Klik **Register app**.
5.  **PENTING**: Download file `google-services.json`.
6.  Pindahkan file `google-services.json` ke dalam folder `android/app/` di proyek Flutter Anda.
7.  Ikuti petunjuk di layar untuk menambahkan SDK Firebase (biasanya sudah ditangani oleh FlutterFire CLI atau kita sesuaikan manual di `build.gradle`), lalu klik **Next** dan **Continue to console**.

### Untuk iOS (Jika mengembangkan di Mac)
1.  Klik **Add app** > **iOS**.
2.  Masukkan **iOS bundle ID**. Bisa dilihat di Xcode atau file `ios/Runner.xcodeproj/project.pbxproj` (cari `PRODUCT_BUNDLE_IDENTIFIER`).
3.  Download `GoogleService-Info.plist`.
4.  Pindahkan file tersebut ke folder `ios/Runner` menggunakan Xcode.

## 4. Konfigurasi Tambahan di Proyek Flutter

Kode aplikasi telah diperbarui untuk menggunakan Firebase. Pastikan dependensi berikut ada di `pubspec.yaml` (ini sudah dilakukan oleh asisten):

- `firebase_core`
- `cloud_firestore`

## 5. Menjalankan Aplikasi

Setelah file konfigurasi (`google-services.json`) ditambahkan:

1.  Jalankan `flutter clean`.
2.  Jalankan `flutter pub get`.
3.  Jalankan aplikasi: `flutter run`.

## Struktur Data Firestore (Referensi)

Aplikasi akan otomatis membuat koleksi dan dokumen saat dijalankan, namun berikut adalah strukturnya:

- **users/{deviceId}/categories/{categoryId}**: Menyimpan kategori.
- **users/{deviceId}/reminders/{reminderId}**: Menyimpan pengingat.

*Catatan: Karena belum ada sistem login, kita bisa menggunakan ID perangkat atau ID unik sementara untuk memisahkan data pengguna jika diperlukan, atau simpan di root collection jika hanya untuk satu pengguna (personal).*
