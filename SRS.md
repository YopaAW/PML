# Software Requirements Specification (SRS) - Ingat.in

## 1. Pendahuluan

-   **Tujuan:** Dokumen ini menjelaskan persyaratan fungsional dan non-fungsional untuk aplikasi Ingat.in.
-   **Lingkup:** Aplikasi mobile untuk manajemen pengingat pribadi.

## 2. Persyaratan Fungsional

### 2.1. Manajemen Pengingat

-   **FR1.1:** Pengguna harus dapat membuat pengingat baru dengan judul, deskripsi (opsional), tanggal, waktu, dan kategori.
-   **FR1.2:** Pengguna harus dapat melihat daftar semua pengingat yang ada.
-   **FR1.3:** Pengguna harus dapat menandai pengingat sebagai selesai.
-   **FR1.4:** Pengguna harus dapat mengedit detail pengingat yang sudah ada.
-   **FR1.5:** Pengguna harus dapat menghapus pengingat yang sudah ada.
-   **FR1.6:** Aplikasi harus menampilkan notifikasi pada perangkat pengguna saat tanggal dan waktu pengingat tercapai.

### 2.2. Manajemen Kategori

-   **FR2.1:** Aplikasi harus menyediakan kategori default yang dapat digunakan oleh semua pengguna.
-   **FR2.2 (Premium):** Pengguna premium harus dapat membuat kategori kustom baru.
-   **FR2.3 (Premium):** Pengguna premium harus dapat mengedit nama kategori kustom yang sudah ada.
-   **FR2.4 (Premium):** Pengguna premium harus dapat menghapus kategori kustom yang sudah ada.
-   **FR2.5:** Halaman "Kelola Kategori" harus menampilkan semua kategori (default dan kustom) untuk pengguna premium.
-   **FR2.6:** Halaman "Kelola Kategori" harus menampilkan pesan untuk berlangganan jika diakses oleh pengguna non-premium.

### 2.3. Filter Pengingat

-   **FR3.1:** Pengguna harus dapat memfilter pengingat berdasarkan bulan.
-   **FR3.2:** Pengguna harus dapat memfilter pengingat berdasarkan kategori.
-   **FR3.3:** Daftar kategori dalam filter harus diperbarui secara dinamis.

### 2.4. Fitur Berlangganan

-   **FR4.1:** Aplikasi harus menyediakan opsi berlangganan (Tahunan, 2 Tahun, Selamanya).
-   **FR4.2:** Pembelian langganan harus memperbarui status pengguna menjadi premium.
-   **FR4.3:** Jika pengguna membeli langganan non-lifetime saat aktif, durasi harus ditambahkan ke durasi yang sudah ada.
-   **FR4.4:** Pembelian langganan 'Selamanya' harus mengaktifkan langganan selamanya, menggantikan langganan aktif sebelumnya.
-   **FR4.5:** Aplikasi harus menampilkan sisa durasi langganan secara real-time di halaman terkait.

### 2.5. Fitur Donasi

-   **FR5.1:** Pengguna harus dapat memilih jumlah donasi yang telah ditentukan.
-   **FR5.2:** Aplikasi harus meminta konfirmasi sebelum memproses donasi.

### 2.6. Informasi Aplikasi

-   **FR6.1:** Aplikasi harus memiliki halaman "Tentang Aplikasi" yang menampilkan informasi dasar tentang aplikasi, versi, dan pengembang.

## 3. Persyaratan Non-Fungsional

### 3.1. Kinerja

-   **NFR1.1:** Aplikasi harus responsif dan memuat data dengan cepat.
-   **NFR1.2:** Notifikasi harus dikirimkan tepat waktu.

### 3.2. Keamanan

-   **NFR2.1:** Data pengguna (pengingat, kategori) harus disimpan secara lokal dengan aman.

### 3.3. Usability

-   **NFR3.1:** Antarmuka pengguna harus intuitif dan mudah digunakan.
-   **NFR3.2:** Aplikasi harus menyediakan umpan balik yang jelas kepada pengguna (misalnya, pesan konfirmasi).

### 3.4. Kompatibilitas

-   **NFR4.1:** Aplikasi harus berfungsi dengan baik di perangkat Android dan iOS.
