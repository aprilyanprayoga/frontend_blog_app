# Frontend Blog App (Mobile)

Aplikasi mobile blog dibuat menggunakan Flutter, mengonsumsi REST API dari [backend_blog_app](https://github.com/aprilyanprayoga/backend_blog_app).

Project ini dibuat untuk keperluan Uji Level Kompetensi Keahlian (ATS) RPL dan Ujian Kompetensi Keahlian Pemrograman Mobile.

## Tech Stack

- **Framework**: Flutter
- **Bahasa**: Dart
- **State Management**: setState + FutureBuilder
- **HTTP Client**: package `http`
- **Image Picker**: package `image_picker`
- **Bottom Navigation**: package `google_nav_bar`

## Struktur Folder

```
lib/
├── models/       # class data (Post, Category)
├── services/     # fungsi konsumsi REST API
├── pages/        # halaman-halaman aplikasi
└── main.dart     # entry point
```

## Fitur

- Menampilkan daftar artikel dari API
- Melihat detail artikel
- Menambah artikel baru (dengan upload gambar ke Cloudinary lewat backend)
- Mengedit artikel
- Menghapus artikel
- Menampilkan & menambah kategori
- Melihat artikel berdasarkan kategori
- Navigasi 3 tab: Home, Kategori, Tentang

## Instalasi

1. Clone repository ini
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Pastikan [backend_blog_app](https://github.com/aprilyanprayoga/backend_blog_app) sudah berjalan di `http://localhost:3000`
4. Sesuaikan `baseUrl` di `lib/services/post_service.dart` dan `lib/services/category_service.dart`:
   - Jalankan di Chrome/web → gunakan `http://localhost:3000/api`
   - Jalankan di Android Emulator → gunakan `http://10.0.2.2:3000/api`
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Branching

Repository ini menggunakan strategi branching:
- `master` — versi stabil awal
- `develop` — kumpulan seluruh fitur yang sudah selesai
- `feature/*` — pengembangan tiap fitur secara terpisah
