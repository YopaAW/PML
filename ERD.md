Tentu, dengan senang hati.

Berikut adalah Dokumen Entity-Relationship Diagram (ERD) untuk aplikasi "Ingat.in". Dokumen ini memvisualisasikan struktur database, entitas-entitas di dalamnya, atributnya, serta hubungan antar entitas tersebut.

Dokumen Entity-Relationship Diagram (ERD): Ingat.in
1. Pendahuluan

ERD ini menggambarkan skema database yang dirancang untuk mendukung semua fungsionalitas yang didefinisikan dalam MVP dan juga untuk mengakomodasi fitur-fitur di masa depan seperti kategori dan sub-tugas. Diagram ini menggunakan notasi Crow's Foot untuk merepresentasikan kardinalitas hubungan antar tabel.

2. Diagram ERD

Berikut adalah representasi visual dari skema database:

code
Mermaid
download
content_copy
expand_less

erDiagram
    CATEGORIES {
        int id PK "Kunci Unik Kategori"
        string name "Nama Kategori (Unik)"
        string color_hex "Kode Warna Hex"
        datetime created_at "Waktu Pembuatan"
    }

    REMINDERS {
        int id PK "Kunci Unik Pengingat"
        string title "Judul Pengingat"
        string description "Deskripsi (Opsional)"
        datetime event_date "Waktu Kegiatan"
        int notification_offset_in_minutes "Offset Notifikasi (dalam menit)"
        bool is_completed "Status Selesai"
        datetime created_at "Waktu Pembuatan"
        datetime updated_at "Waktu Perubahan"
        int category_id FK "Kunci Asing ke Kategori (Opsional)"
    }

    SUBTASKS {
        int id PK "Kunci Unik Sub-tugas"
        string title "Judul Sub-tugas"
        bool is_completed "Status Selesai"
        int reminder_id FK "Kunci Asing ke Pengingat"
    }

    CATEGORIES ||--o{ REMINDERS : "memiliki"
    REMINDERS ||--|{ SUBTASKS : "terdiri dari"
3. Deskripsi Entitas dan Atribut

1. Entitas CATEGORIES

Tujuan: Menyimpan daftar kategori yang bisa dibuat oleh pengguna untuk mengelompokkan pengingat. Fitur ini dirancang untuk masa depan.

Atribut:

id (PK): Kunci utama (Primary Key) yang unik untuk setiap kategori.

name: Nama kategori yang harus unik (contoh: "Pekerjaan", "Pribadi").

color_hex: Kode warna heksadesimal untuk representasi visual di UI.

created_at: Timestamp kapan kategori ini dibuat.

2. Entitas REMINDERS

Tujuan: Entitas inti dari aplikasi yang menyimpan semua informasi detail tentang sebuah pengingat.

Atribut:

id (PK): Kunci utama yang unik untuk setiap pengingat.

title: Judul pengingat yang wajib diisi.

description: Catatan tambahan yang bersifat opsional.

event_date: Tanggal dan waktu pasti dari kegiatan.

notification_offset_in_minutes: Menentukan berapa menit sebelum event_date notifikasi akan muncul.

is_completed: Status boolean (true/false) untuk menandai apakah pengingat sudah selesai.

created_at: Timestamp kapan pengingat ini dibuat.

updated_at: Timestamp kapan pengingat ini terakhir diubah.

category_id (FK): Kunci asing (Foreign Key) yang merujuk ke id di tabel CATEGORIES. Dibuat opsional (nullable) agar pengingat bisa dibuat tanpa kategori.

3. Entitas SUBTASKS

Tujuan: Menyimpan daftar checklist atau sub-tugas yang merupakan bagian dari sebuah pengingat utama. Fitur ini dirancang untuk masa depan.

Atribut:

id (PK): Kunci utama yang unik untuk setiap sub-tugas.

title: Deskripsi dari sub-tugas.

is_completed: Status boolean untuk menandai apakah sub-tugas ini sudah selesai.

reminder_id (FK): Kunci asing yang merujuk ke id di tabel REMINDERS. Atribut ini wajib diisi, karena sebuah sub-tugas tidak bisa eksis tanpa pengingat induknya.

4. Deskripsi Hubungan (Relationships)

CATEGORIES ke REMINDERS

Kardinalitas: Satu-ke-Banyak (One-to-Many).

Deskripsi:

Satu CATEGORIES dapat dimiliki oleh nol, satu, atau banyak REMINDERS.

Satu REMINDERS hanya dapat memiliki nol atau satu CATEGORIES.

Implementasi: Hubungan ini diimplementasikan melalui foreign key category_id di tabel REMINDERS.

REMINDERS ke SUBTASKS

Kardinalitas: Satu-ke-Banyak (One-to-Many).

Deskripsi:

Satu REMINDERS dapat memiliki nol, satu, atau banyak SUBTASKS.

Satu SUBTASKS harus dimiliki oleh tepat satu REMINDERS. Hubungan ini bersifat identifying, artinya SUBTASKS tidak bisa ada tanpa REMINDERS.

Implementasi: Hubungan ini diimplementasikan melalui foreign key reminder_id di tabel SUBTASKS. Disarankan untuk menerapkan aturan ON DELETE CASCADE pada foreign key ini, sehingga jika sebuah pengingat dihapus, semua sub-tugas yang terkait akan ikut terhapus secara otomatis.