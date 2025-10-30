# Minimum Viable Product (MVP) - Ingat.in

## Ringkasan

Ingat.in adalah aplikasi pengingat sederhana yang memungkinkan pengguna untuk mencatat dan mengelola pengingat kegiatan mereka. MVP ini berfokus pada fungsionalitas inti untuk memastikan pengguna dapat membuat, melihat, mengedit, menghapus, dan menerima notifikasi untuk pengingat mereka.

## Fitur Inti

### 1. Manajemen Pengingat Dasar

-   **Setup Database (Hive):** Inisialisasi database lokal menggunakan Hive untuk penyimpanan data yang efisien.
-   **Data Models:** Definisi model data untuk `Reminder` dan `Category`.
-   **State Management (Provider):** Implementasi Provider untuk manajemen state aplikasi yang reaktif.
-   **Halaman Utama (Home Page):**
    -   Menampilkan daftar pengingat yang sudah ada.
    -   Tombol untuk menambah pengingat baru.
    -   Aksi untuk mengedit atau menghapus pengingat.
-   **Halaman Tambah/Edit Pengingat (Add/Edit Page):**
    -   Form untuk menambah atau mengedit pengingat.
    -   Input untuk judul, deskripsi, tanggal, waktu, dan kategori.

### 2. Notifikasi

-   **Notifikasi Pengingat:** Aplikasi akan menampilkan notifikasi saat tanggal dan jam pengingat tercapai.
