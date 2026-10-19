# NETGUARD (Flutter MVP)

## Cara menjalankan
1. Install Flutter SDK, lalu di folder kosong: `flutter create netguard`
2. Salin `pubspec.yaml` dan folder `lib/` dari proyek ini ke dalam proyek tersebut (timpa).
3. `flutter pub get` lalu `flutter run` (emulator/HP Android).

## Struktur
- lib/main.dart            : entry point & tema
- lib/data/game_state.dart : model soal, bank soal, skor, progress, unlock sektor, penyimpanan lokal
- lib/widgets/neon.dart    : komponen UI neon (tombol, panel, background)
- lib/screens/             : menu, peta (Cyber Grid), quiz (timer, nyawa, HP Virax), hasil (Victory/Defeat)

## Pengembangan lanjutan
- Ganti emoji placeholder dengan sprite karakter di assets/images.
- Mode eksplorasi 2D (Corrupted Unit, Ruang Inti) -> aktifkan Flame di pubspec.yaml.
- Leaderboard / akun -> Firebase (P2 di proposal). Bank soal besar -> SQLite (sqflite).
