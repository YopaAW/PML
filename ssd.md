# Software System Design (SSD) - Ingat.in

## 1. Arsitektur Sistem

-   **Arsitektur:** Clean Architecture / MVVM (Model-View-ViewModel) dengan Riverpod untuk manajemen state.
-   **Platform:** Flutter (Android, iOS, Web).
-   **Database Lokal:** Hive untuk penyimpanan data pengingat dan kategori secara offline.

## 2. Komponen Utama

### 2.1. Lapisan Data

-   **Model:**
    -   `Reminder`: Merepresentasikan pengingat dengan properti seperti ID, judul, deskripsi, tanggal/waktu acara, status selesai, dan ID kategori.
    -   `Category`: Merepresentasikan kategori dengan properti seperti ID, nama, status kustom, dan status premium.
-   **Database Service (`DatabaseService`):**
    -   Mengelola operasi CRUD (Create, Read, Update, Delete) untuk `Reminder` dan `Category` menggunakan Hive.
    -   Menyediakan Stream untuk memantau perubahan data secara real-time.
-   **Adapters:** Hive TypeAdapters untuk serialisasi/deserialisasi model `Reminder` dan `Category`.

### 2.2. Lapisan Domain (Providers)

-   **`ReminderListNotifier`:** Mengelola daftar pengingat, termasuk penambahan, pembaruan, penghapusan, dan perubahan status selesai. Berinteraksi dengan `DatabaseService`.
-   **`CategoryNotifier`:** Mengelola daftar kategori, termasuk penambahan, pembaruan, dan penghapusan. Berinteraksi dengan `DatabaseService`.
-   **`isSubscribedProvider`:** Menyediakan status langganan pengguna (premium/gratis).
-   **`subscriptionEndDateProvider`:** Menyimpan tanggal berakhirnya langganan pengguna.
-   **`selectedMonthProvider`:** Menyimpan bulan yang dipilih untuk filter pengingat.
-   **`selectedCategoryProvider`:** Menyimpan kategori yang dipilih untuk filter pengingat.

### 2.3. Lapisan Presentasi (UI)

-   **Halaman (`pages/`):**
    -   `HomePage`: Menampilkan daftar pengingat, filter, dan navigasi drawer.
    -   `AddEditPage`: Form untuk menambah atau mengedit pengingat.
    -   `AboutPage`: Menampilkan informasi aplikasi.
    -   `ManageCategoriesPage`: Mengelola kategori (premium).
    -   `SubscriptionPage`: Menampilkan opsi berlangganan.
    -   `DonationPage`: Menampilkan opsi donasi.
-   **Routing:** `go_router` untuk navigasi antar halaman.

### 2.4. Layanan (Services)

-   **`NotificationService`:**
    -   Menginisialisasi plugin `flutter_local_notifications`.
    -   Menjadwalkan dan membatalkan notifikasi pengingat.
    -   Meminta izin notifikasi.

### 3. Alur Data (Contoh: Menambah Pengingat)

1.  Pengguna mengisi form di `AddEditPage` dan menekan tombol simpan.
2.  `_saveReminder` di `AddEditPage` memanggil `addReminder` di `ReminderListNotifier`.
3.  `addReminder` memanggil `insertReminder` di `DatabaseService`.
4.  `DatabaseService` menyimpan pengingat baru ke Hive dan mengembalikan objek `Reminder` yang sudah diperbarui dengan ID.
5.  `addReminder` mengembalikan `Reminder` ke `AddEditPage`.
6.  `AddEditPage` menggunakan `NotificationService` untuk menjadwalkan notifikasi berdasarkan detail pengingat.
7.  `ReminderListNotifier` memperbarui state-nya, yang memicu `HomePage` untuk memperbarui daftar pengingat.
