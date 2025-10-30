# Product Requirements Document (PRD) - Ingat.in

## 1. Pengelolaan Pengingat

-   **Fungsionalitas Dasar:**
    -   Pengguna dapat membuat pengingat baru dengan judul, deskripsi opsional, tanggal, waktu, dan kategori.
    -   Pengguna dapat melihat daftar semua pengingat yang telah dibuat di halaman utama.
    -   Pengguna dapat menandai pengingat sebagai 'selesai' melalui checkbox.
    -   Pengguna dapat mengedit detail pengingat yang sudah ada.
    -   Pengguna dapat menghapus pengingat yang sudah ada.

-   **Notifikasi Pengingat:**
    -   Aplikasi akan menampilkan notifikasi pada perangkat pengguna saat tanggal dan waktu pengingat yang ditentukan tercapai.

## 2. Pengelolaan Kategori

-   **Kategori Default:** Aplikasi menyediakan kategori-kategori default (Pribadi, Kerja, Kesehatan, Belanja) yang dapat digunakan oleh semua pengguna.
-   **Manajemen Kategori Kustom (Fitur Premium):**
    -   Pengguna premium dapat membuat, mengedit, dan menghapus kategori kustom mereka sendiri.
    -   Pengguna dapat mengelola kategori dari halaman 'Kelola Kategori'.
    -   Perubahan pada kategori (tambah/edit/hapus) akan secara otomatis diperbarui di seluruh aplikasi.

## 3. Filter Pengingat

-   **Filter Berdasarkan Bulan:** Pengguna dapat memfilter daftar pengingat berdasarkan bulan tertentu.
-   **Filter Berdasarkan Kategori:** Pengguna dapat memfilter daftar pengingat berdasarkan kategori yang dipilih.
-   **Pembaruan Otomatis Filter:** Menu filter kategori akan diperbarui secara otomatis, mencerminkan kategori yang tersedia (termasuk kustom).

## 4. Fitur Akun dan Monetisasi

-   **Fitur Premium (Berlangganan):**
    -   Pengguna dapat berlangganan untuk membuka fitur premium seperti pengelolaan kategori kustom.
    -   Tersedia opsi langganan:
        -   Tahunan: Rp 15.000
        -   2 Tahun: Rp 25.000
        -   Selamanya: Rp 50.000
    -   Jika pengguna memiliki langganan aktif dan membeli paket lain (non-lifetime), durasi baru akan ditambahkan ke durasi yang sudah ada.
    -   Pembelian langganan 'Selamanya' akan langsung mengaktifkan langganan selamanya, menggantikan langganan aktif sebelumnya.
    -   Sisa durasi langganan akan ditampilkan secara real-time di halaman terkait.
-   **Fitur Donasi:**
    -   Pengguna dapat memberikan donasi kepada pengembang sebagai bentuk dukungan.
    -   Opsi nominal donasi dari Rp 1.000 hingga Rp 50.000.
    -   Setiap aksi donasi memerlukan konfirmasi pengguna.

## 5. Informasi Aplikasi

-   **Halaman Tentang (About Page):** Halaman statis yang berisi informasi dasar tentang aplikasi, versi, dan pengembang. (sudah ada nama Anda)
