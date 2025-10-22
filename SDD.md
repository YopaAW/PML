Sangat baik. Setelah mendefinisikan apa yang akan dibuat (PRD & SRS), Software Design Document (SDD) akan menjelaskan bagaimana sistem tersebut akan dibangun.

Dokumen ini bersifat sangat teknis dan ditujukan untuk tim pengembang. SDD akan menguraikan arsitektur perangkat lunak, komponen-komponennya, antarmuka, dan data yang akan digunakan untuk mengimplementasikan solusi.

Software Design Document: Ingat.in
Versi	        Tanggal	Penulis	        Status
1.0	17 September 2025	Yopa & Sidra	Draf Awal
1. Pendahuluan
1.1 Tujuan

Tujuan dari dokumen ini adalah untuk menyediakan desain teknis tingkat tinggi dan tingkat rendah untuk aplikasi mobile Ingat.in. Dokumen ini akan menjadi panduan bagi tim pengembang dalam mengimplementasikan fungsionalitas yang telah dijabarkan dalam Software Requirements Specification (SRS) versi 1.0, dengan berpegang pada arsitektur dan teknologi yang telah ditentukan.

1.2 Lingkup Desain

Dokumen ini mencakup desain untuk seluruh fungsionalitas MVP, termasuk:

Arsitektur sistem secara keseluruhan.

Desain detail untuk setiap lapisan arsitektur (Presentation, Application, Domain, Data).

Desain skema database.

Strategi penanganan error dan logging.

Desain antarmuka antar komponen.

2. Tinjauan Sistem

Aplikasi Ingat.in akan dibangun sebagai aplikasi mobile mandiri menggunakan Flutter. Aplikasi ini akan mengikuti prinsip offline-first dan arsitektur Clean Architecture untuk memastikan pemisahan tanggung jawab (separation of concerns), skalabilitas, dan kemudahan pengujian.

Diagram Arsitektur Tingkat Tinggi
code
Code
download
content_copy
expand_less

+------------------------------------------------------------------+
|                        Presentation Layer                        |
|   (Flutter Widgets, UI Logic, State Management with Riverpod)    |
|                                                                  |
|       [HomePage]   [AddEditPage]   [SettingsPage (Future)]       |
+------------------------------------------------------------------+
                             Λ
                             | (Calls Use Cases)
                             V
+------------------------------------------------------------------+
|                        Application Layer                         |
|      (Use Cases / Interactors, Application-specific Logic)       |
|                                                                  |
|   [GetReminders] [AddReminder] [DeleteReminder] [UpdateReminder] |
+------------------------------------------------------------------+
                             Λ
                             | (Depends on Abstractions)
                             V
+------------------------------------------------------------------+
|                           Domain Layer                           |
|      (Core Business Logic, Entities, Repository Interfaces)      |
|                                                                  |
|      [Reminder Entity] [Category Entity] [IReminderRepository]   |
+------------------------------------------------------------------+
                             Λ
                             | (Implementations)
                             V
+------------------------------------------------------------------+
|                     Data / Infrastructure Layer                  |
|   (Database Implementation, External Services, Device APIs)      |
|                                                                  |
| [DriftDatabase] [ReminderRepositoryImpl] [NotificationServiceImpl] |
+------------------------------------------------------------------+

Aturan Ketergantungan (Dependency Rule): Panah menunjukkan arah ketergantungan. Lapisan luar (misal: Presentation) bergantung pada lapisan dalam (misal: Application), tetapi lapisan dalam tidak boleh mengetahui apapun tentang lapisan luar.

3. Desain Arsitektur
3.1 Domain Layer

Ini adalah inti dari aplikasi, tidak bergantung pada lapisan lainnya.

Entities:

Reminder: Sebuah plain class (dibuat dengan Freezed) yang merepresentasikan objek pengingat. Berisi properti seperti id, title, description, eventDate, isCompleted, dll. Kelas ini tidak berisi logika pengambilan data.

Repository Interfaces (Abstract Contracts):

IReminderRepository: Sebuah abstract class yang mendefinisikan metode-metode yang harus diimplementasikan oleh lapisan Data. Contoh:

Stream<List<Reminder>> watchAllReminders()

Future<Either<Failure, Unit>> addReminder(Reminder reminder)

Future<Either<Failure, Unit>> updateReminder(Reminder reminder)

Future<Either<Failure, Unit>> deleteReminder(int id)

3.2 Application Layer

Lapisan ini berisi logika spesifik aplikasi dan mengorkestrasi alur data antara Presentation dan Domain.

Use Cases (Interactors): Setiap kelas akan memiliki satu tanggung jawab publik.

AddReminderUseCase: Mengambil Reminder dari Presentation Layer, melakukan validasi bisnis, dan memanggil metode addReminder pada IReminderRepository.

GetUpcomingRemindersUseCase: Memanggil watchAllReminders dari repository dan mengembalikan Stream yang akan dikonsumsi oleh Presentation Layer.

Setiap use case akan mengembalikan Future<Either<Failure, SuccessType>> menggunakan package fpdart untuk menangani error secara fungsional tanpa try-catch.

3.3 Data / Infrastructure Layer

Lapisan ini adalah implementasi konkret dari kontrak yang didefinisikan di Domain Layer.

Repository Implementation:

ReminderRepositoryImpl: Kelas yang mengimplementasikan IReminderRepository. Kelas ini akan berinteraksi langsung dengan data source.

Data Sources:

LocalDataSource (Drift): Kelas yang bertanggung jawab untuk berkomunikasi dengan database SQLite melalui Drift. Ini akan berisi logika query seperti SELECT, INSERT, UPDATE, DELETE. ReminderRepositoryImpl akan memanggil kelas ini.

Services:

NotificationServiceImpl: Implementasi dari interface INotificationService. Akan menggunakan package flutter_local_notifications untuk menjadwalkan, menampilkan, dan membatalkan notifikasi di level OS.

3.4 Presentation Layer

Lapisan yang dilihat dan diinteraksikan oleh pengguna.

UI (Widgets):

HomePage: Menampilkan daftar pengingat. Akan "mendengarkan" state dari Provider Riverpod.

AddEditPage: Formulir untuk membuat atau mengubah pengingat.

State Management (Riverpod):

reminderListProvider: Sebuah StreamProvider atau AsyncNotifierProvider yang akan mengekspos Stream<List<Reminder>> dari GetUpcomingRemindersUseCase ke UI. UI akan secara otomatis rebuild saat data di database berubah.

addReminderController: Sebuah Notifier atau AsyncNotifier yang akan menangani state dari proses penambahan pengingat (misalnya, loading, error, success).

Navigasi (Go_Router):

Rute akan didefinisikan secara deklaratif.

/: Mengarah ke HomePage.

/add: Mengarah ke AddEditPage dalam mode "tambah baru".

/edit/:id: Mengarah ke AddEditPage dalam mode "edit", dengan id pengingat sebagai parameter.

4. Desain Database

Database akan menggunakan SQLite, diakses melalui ORM Drift. Skema database akan sesuai dengan dokumen desain database yang telah dibuat sebelumnya.

Tabel reminders: Kolom utama id, title, event_date, notification_offset_in_minutes, is_completed.

Migrasi: Drift akan mengelola migrasi skema. Setiap perubahan pada struktur tabel akan memerlukan penambahan versi skema dan implementasi migrasi.

5. Desain Komponen Detail
5.1 Alur Pembuatan Pengingat

UI (AddEditPage): Pengguna menekan tombol "Simpan".

UI Logic: Memvalidasi input form. Jika valid, panggil method pada addReminderController.

Riverpod Controller: Memanggil AddReminderUseCase dengan data dari UI yang telah dikonversi menjadi Reminder entity.

Use Case (AddReminderUseCase): Memanggil reminderRepository.addReminder(reminder).

Repository (ReminderRepositoryImpl): Memanggil localDataSource.insertReminder(reminder).

Data Source (Drift): Mengeksekusi perintah INSERT ke tabel reminders di SQLite.

Sukses/Gagal: Hasil operasi (berupa Either dari fpdart) akan dikembalikan melalui rantai panggilan hingga ke UI untuk menampilkan notifikasi sukses atau pesan error.

Notifikasi: Jika sukses, AddReminderUseCase juga akan memanggil ScheduleNotificationUseCase untuk menjadwalkan notifikasi.

5.2 Penanganan Error

Kesalahan akan direpresentasikan sebagai sealed class Failure (misal: DatabaseFailure, ValidationFailure).

Use cases dan repositories akan mengembalikan Either<Failure, T>.

Layer Presentation bertanggung jawab untuk "membuka" Either ini dan menampilkan pesan yang sesuai kepada pengguna (misalnya, melalui SnackBar).

5.3 Logging

Package Logger akan digunakan selama pengembangan.

Log akan dicetak untuk:

Panggilan ke Use Case dan hasilnya.

Interaksi dengan database.

Error yang tidak tertangani.

Level log (debug, info, warning, error) akan digunakan untuk memfilter output.

6. Strategi Pengujian (Testing Strategy)

Unit Tests:

Domain & Application Layers: Semua Use Cases dan logika bisnis di dalam Entity akan diuji secara unit. Repository interfaces akan di-mock.

Widget Tests:

Presentation Layer: Setiap layar dan widget kustom akan diuji secara terisolasi untuk memverifikasi UI dan interaksi dasar. Providers Riverpod akan di-override untuk menyediakan data palsu.

Integration Tests:

Akan dibuat skenario pengujian end-to-end untuk alur utama, seperti "membuat pengingat dan memverifikasi bahwa pengingat tersebut muncul di daftar utama". Pengujian ini akan berinteraksi dengan database Drift yang berjalan di memori (in-memory).