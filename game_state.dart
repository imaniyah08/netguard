import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Question {
  final String text, tip;
  final List<String> options;
  final int answer; // index jawaban benar
  const Question(this.text, this.options, this.answer, this.tip);
}

class Sector {
  final int id;
  final String name;
  const Sector(this.id, this.name);
}

const sectors = [
  Sector(1, 'Pengenalan Jaringan'),
  Sector(2, 'Topologi & Perangkat'),
  Sector(3, 'Subnetting & Protokol'),
  Sector(4, 'Cybersecurity'),
  Sector(5, 'RPL & Pengembangan'),
];

/// Bank soal (contoh). Tambah/ubah soal di sini atau pindahkan ke SQLite/JSON.
const questionBank = <int, List<Question>>{
  1: [
    Question('Perangkat jaringan yang berfungsi menghubungkan beberapa komputer dalam satu jaringan LAN adalah...',
        ['Router', 'Switch', 'Modem', 'Access Point'], 1, 'Switch meneruskan data antarperangkat dalam LAN.'),
    Question('Singkatan LAN adalah...',
        ['Local Area Network', 'Long Area Network', 'Line Access Node', 'Local Access Net'], 0, 'LAN mencakup area kecil seperti ruang lab.'),
    Question('Perangkat yang menghubungkan jaringan lokal ke internet adalah...',
        ['Hub', 'Switch', 'Router', 'Repeater'], 2, 'Router menentukan jalur antarjaringan.'),
  ],
  2: [
    Question('Topologi yang semua perangkatnya terhubung ke satu titik pusat adalah...',
        ['Bus', 'Star', 'Ring', 'Mesh'], 1, 'Pusatnya biasanya switch/hub.'),
    Question('Kelemahan utama topologi bus adalah...',
        ['Boros kabel', 'Kabel utama putus, jaringan mati', 'Sangat mahal', 'Tidak bisa ditambah node'], 1, 'Satu kabel backbone jadi titik lemah.'),
    Question('Topologi yang setiap node terhubung ke banyak node lain disebut...',
        ['Star', 'Bus', 'Mesh', 'Tree'], 2, 'Redundansi tinggi, biaya tinggi.'),
  ],
  3: [
    Question('Subnet mask untuk CIDR /24 adalah...',
        ['255.0.0.0', '255.255.0.0', '255.255.255.0', '255.255.255.128'], 2, '24 bit pertama bernilai 1.'),
    Question('Protokol yang otomatis memberi alamat IP ke perangkat adalah...',
        ['DNS', 'DHCP', 'HTTP', 'FTP'], 1, 'DHCP = Dynamic Host Configuration Protocol.'),
    Question('Jumlah host yang bisa dipakai pada jaringan /24 adalah...',
        ['256', '255', '254', '252'], 2, '2^8 - 2 (network & broadcast).'),
  ],
  4: [
    Question('Sistem yang menyaring lalu lintas jaringan berdasarkan aturan disebut...',
        ['Firewall', 'Proxy DNS', 'Switch', 'Hub'], 0, 'Firewall = dinding pertahanan jaringan.'),
    Question('Serangan yang menipu korban lewat email/situs palsu adalah...',
        ['DDoS', 'Phishing', 'Sniffing', 'Brute force'], 1, 'Tujuannya mencuri kredensial.'),
    Question('Mengubah data menjadi bentuk tak terbaca agar aman disebut...',
        ['Kompresi', 'Enkripsi', 'Formatting', 'Caching'], 1, 'Hanya pemegang kunci yang bisa membaca.'),
  ],
  5: [
    Question('Struktur kontrol untuk mengulang perintah adalah...',
        ['if-else', 'switch', 'for / while', 'return'], 2, 'Perulangan = looping.'),
    Question('Tahap awal SDLC adalah...',
        ['Testing', 'Analisis kebutuhan', 'Maintenance', 'Deploy'], 1, 'Pahami kebutuhan sebelum membangun.'),
    Question('Bahasa query untuk mengelola basis data relasional adalah...',
        ['HTML', 'CSS', 'SQL', 'JSON'], 2, 'SQL = Structured Query Language.'),
  ],
};

class GameState extends ChangeNotifier {
  int stars = 0, coins = 0, exp = 0;
  Set<int> cleared = {};
  List<String> wrongLog = []; // riwayat jawaban salah (asesmen formatif)

  int get maxStars => sectors.length * 3;

  bool isUnlocked(int id) => id == 1 || cleared.contains(id - 1);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    stars = p.getInt('stars') ?? 0;
    coins = p.getInt('coins') ?? 0;
    exp = p.getInt('exp') ?? 0;
    cleared = (p.getStringList('cleared') ?? []).map(int.parse).toSet();
    wrongLog = p.getStringList('wrongLog') ?? [];
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('stars', stars);
    await p.setInt('coins', coins);
    await p.setInt('exp', exp);
    await p.setStringList('cleared', cleared.map((e) => '$e').toList());
    await p.setStringList('wrongLog', wrongLog);
  }

  void logWrong(int sectorId, String question) {
    wrongLog.add('S$sectorId|$question');
    _save();
  }

  /// Dipanggil saat sektor selesai (Node Perisai pulih).
  void completeSector(int id, {required int starsEarned}) {
    if (!cleared.contains(id)) stars += starsEarned; // bintang hanya dihitung sekali
    cleared.add(id);
    exp += 120;
    coins += 150;
    notifyListeners();
    _save();
  }

  Future<void> reset() async {
    stars = coins = exp = 0;
    cleared = {};
    wrongLog = [];
    notifyListeners();
    await _save();
  }
}

final game = GameState(); // instance global sederhana
