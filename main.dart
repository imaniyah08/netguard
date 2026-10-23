// NETGUARD: Guardians of the Cyber Network - versi satu file (Flutter + Dart)
// Dependensi: shared_preferences (lihat pubspec.yaml)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// ===================== data/game_state.dart =====================
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

// ===================== widgets/neon.dart =====================
const cyan = Color(0xFF168BFA);
const deepBlue = Color(0xFF0D3156);
const ink = Color(0xFF123456);
const canvas = Color(0xFFF1F7FC);

/// Latar terang dengan aksen gradasi biru.
class CyberBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  const CyberBackground({super.key, required this.child, this.colors});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors ?? const [Color(0xFFEAF6FF), Color(0xFFF8FBFF), Color(0xFFE8F3FC)],
          ),
        ),
        child: SafeArea(child: child),
      );
}

/// Kartu putih dengan garis tipis dan bayangan lembut.
class NeonPanel extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  const NeonPanel({super.key, required this.child, this.color = const Color(0xFFD5E5F2), this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 1),
          boxShadow: const [BoxShadow(color: Color(0x140D3156), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: child,
      );
}

/// Tombol utama biru dengan bentuk membulat.
class NeonButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final bool big;
  const NeonButton(this.label, {super.key, this.icon, this.onTap, this.color = cyan, this.big = false});
  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: big ? 16 : 13, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: big ? 24 : 20), const SizedBox(width: 8)],
            Text(label, style: TextStyle(fontSize: big ? 19 : 15, fontWeight: FontWeight.w700, letterSpacing: .2)),
          ]),
        ),
      ),
    );
  }
}
// ===================== screens/menu_screen.dart =====================
class CyberHeroIllustration extends StatelessWidget {
  const CyberHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF123D69), Color(0xFF0877BD), Color(0xFF06365F)],
          ),
          boxShadow: const [BoxShadow(color: Color(0x332A83C9), blurRadius: 24, offset: Offset(0, 12))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(children: [
            Positioned(top: -54, right: -38, child: _glow(190, const Color(0xFF42C8FF).withOpacity(.14))),
            Positioned(bottom: -82, left: -52, child: _glow(210, const Color(0xFF29D3FF).withOpacity(.12))),
            Positioned(top: 24, left: 20, child: _statusChip(Icons.shield_outlined, 'SISTEM AKTIF', const Color(0xFF75F0D0))),
            Positioned(top: 26, right: 20, child: _statusChip(Icons.wifi_tethering, 'LIVE DEFENSE', Colors.white70)),
            Center(
              child: Container(
                width: 172,
                height: 172,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.08),
                  border: Border.all(color: Colors.white.withOpacity(.17), width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF48D9FF), Color(0xFF168BFA)]),
                      boxShadow: [BoxShadow(color: const Color(0xFF39BFFF).withOpacity(.45), blurRadius: 28)],
                    ),
                    child: const Icon(Icons.shield, size: 78, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 34,
              top: 94,
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7EA),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [BoxShadow(color: Color(0x55451C35), blurRadius: 16, offset: Offset(0, 5))],
                ),
                child: const Icon(Icons.coronavirus, color: Color(0xFFE64D68), size: 38),
              ),
            ),
            Positioned(right: 22, top: 166, child: _threatTag()),
            Positioned(left: 26, bottom: 75, child: _node(Icons.router, 'NETWORK')),
            Positioned(right: 26, bottom: 75, child: _node(Icons.lock, 'DATA SAFE')),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(.18)),
                ),
                child: const Row(children: [
                  Icon(Icons.radar, color: Color(0xFF71E9D0), size: 21),
                  SizedBox(width: 9),
                  Expanded(child: Text('Lindungi jaringan. Kalahkan ancaman.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                  Icon(Icons.arrow_forward, color: Colors.white70, size: 18),
                ]),
              ),
            ),
          ]),
        ),
      );

  Widget _glow(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Widget _statusChip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5)),
        ]),
      );

  Widget _node(IconData icon, String label) => Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white.withOpacity(.85), size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: .7)),
      ]);

  Widget _threatTag() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(color: const Color(0xFFE64D68), borderRadius: BorderRadius.circular(20)),
        child: const Text('VIRUS', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
      );
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CyberBackground(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
            child: Column(children: [
              const SizedBox(height: 8),
              const Text('NETGUARD',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: deepBlue, letterSpacing: 1.5)),
              const SizedBox(height: 3),
              const Text('Guardians Of The Cyber Network', style: TextStyle(fontSize: 13, color: Color(0xFF52708D), letterSpacing: .4)),
              const SizedBox(height: 20),
              const Expanded(child: CyberHeroIllustration()),
              const SizedBox(height: 20),
              NeonButton('MULAI', icon: Icons.play_arrow, big: true, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
              }),
              const SizedBox(height: 10),
              NeonButton('PENGATURAN', icon: Icons.settings, onTap: () => _settings(context)),
              const SizedBox(height: 10),
              NeonButton('KELUAR', icon: Icons.exit_to_app, color: const Color(0xFF5C7892), onTap: () => Navigator.of(context).maybePop()),
            ]),
          ),
        ),
      );
  void _settings(BuildContext context) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Pengaturan'),
          content: const Text('Reset seluruh progress permainan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            TextButton(
                onPressed: () {
                  game.reset();
                  Navigator.pop(context);
                },
                child: const Text('Reset')),
          ],
        ),
      );
}

// ===================== screens/map_screen.dart =====================
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CyberBackground(
          child: ListenableBuilder(
            listenable: game,
            builder: (context, _) => Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                  const Expanded(child: Text('Peta Dunia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  NeonPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${game.stars}/${game.maxStars}'),
                    ]),
                  ),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sectors.length,
                  itemBuilder: (context, i) {
                    final s = sectors[i];
                    final unlocked = game.isUnlocked(s.id);
                    final done = game.cleared.contains(s.id);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16, left: i.isEven ? 0 : 40, right: i.isEven ? 40 : 0),
                      child: GestureDetector(
                        onTap: unlocked
                            ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(sector: s)))
                            : null,
                        child: NeonPanel(
                          color: done ? const Color(0xFF15966B) : (unlocked ? cyan : Colors.grey),
                          child: Row(children: [
                            Icon(unlocked ? (done ? Icons.verified : Icons.hub) : Icons.lock,
                                size: 36, color: done ? const Color(0xFF15966B) : (unlocked ? cyan : Colors.grey)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Sektor ${s.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(s.name, style: const TextStyle(fontSize: 12)),
                              ]),
                            ),
                            Icon(done ? Icons.star : Icons.star_border, color: Colors.amber),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      );
}

// ===================== screens/quiz_screen.dart =====================
class QuizScreen extends StatefulWidget {
  final Sector sector;
  const QuizScreen({super.key, required this.sector});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const totalSeconds = 60;
  late final List<Question> qs = questionBank[widget.sector.id]!;
  int index = 0, hearts = 3, correct = 0, selected = -1, seconds = totalSeconds;
  bool _finished = false;
  bool answered = false;
  Timer? timer;

  Question get q => qs[index];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds <= 1) {
        finish(false); // waktu habis = Defeat
      } else {
        setState(() => seconds--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void submit() {
    if (selected < 0 || answered || _finished) return;
    final ok = selected == q.answer;
    setState(() {
      answered = true;
      if (ok) {
        correct++;
      } else {
        hearts--;
        game.logWrong(widget.sector.id, q.text);
      }
    });
    Future.delayed(const Duration(milliseconds: 900), next);
  }

  void next() {
    if (!mounted || _finished) return;
    if (hearts <= 0) return finish(false);
    if (index >= qs.length - 1) return finish(correct >= (qs.length * .6).ceil());
    setState(() {
      index++;
      selected = -1;
      answered = false;
    });
  }

  void finish(bool win) {
    if (_finished || !mounted) return;
    _finished = true;
    timer?.cancel();
    if (win) game.completeSector(widget.sector.id, starsEarned: hearts.clamp(1, 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(win: win, sector: widget.sector, secondsLeft: seconds)),
    );
  }

  Color _optionColor(int i) {
    if (!answered) return i == selected ? cyan : const Color(0xFFD5E5F2);
    if (i == q.answer) return const Color(0xFF15966B);
    if (i == selected) return const Color(0xFFCE4561);
    return const Color(0xFFD5E5F2);
  }

  @override
  Widget build(BuildContext context) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      body: CyberBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { timer?.cancel(); Navigator.pop(context); }),
              Expanded(child: Text('Sektor ${widget.sector.id} - ${widget.sector.name}', style: const TextStyle(fontWeight: FontWeight.bold))),
              const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
              Text(' x$hearts   '),
              const Icon(Icons.timer, color: cyan, size: 18),
              Text(' $mm:$ss'),
            ]),
            const SizedBox(height: 8),
            // HP Virax turun setiap jawaban benar
            Row(children: [
              const Text('Virax '),
              Expanded(
                child: LinearProgressIndicator(
                  value: 1 - correct / qs.length,
                  color: const Color(0xFFCE4561),
                  backgroundColor: const Color(0xFFD5E5F2),
                  minHeight: 8,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            const Icon(Icons.security, size: 64, color: cyan),
            const SizedBox(height: 12),
            NeonPanel(child: Text(q.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            for (int i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: answered ? null : () => setState(() => selected = i),
                  child: NeonPanel(
                    color: _optionColor(i),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(children: [
                      Text('${String.fromCharCode(65 + i)}   ', style: const TextStyle(fontWeight: FontWeight.bold, color: cyan)),
                      Expanded(child: Text(q.options[i])),
                    ]),
                  ),
                ),
              ),
            const Spacer(),
            LinearProgressIndicator(value: (index + 1) / qs.length, color: cyan, backgroundColor: const Color(0xFFD5E5F2)),
            Align(alignment: Alignment.centerRight, child: Text('${index + 1}/${qs.length}')),
            NeonPanel(child: Row(children: [
              const Icon(Icons.menu_book, color: cyan),
              const SizedBox(width: 8),
              Expanded(child: Text('Tip: ${q.tip}', style: const TextStyle(fontSize: 12))),
            ])),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(flex: 3, child: NeonButton('JAWAB', icon: Icons.send, onTap: (selected < 0 || answered) ? null : submit)),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: NeonButton('Lewati', color: Colors.blueGrey, onTap: answered ? null : () { setState(() => answered = true); next(); })),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ===================== screens/result_screen.dart =====================
class ResultScreen extends StatelessWidget {
  final bool win;
  final Sector sector;
  final int secondsLeft;
  const ResultScreen({super.key, required this.win, required this.sector, required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final color = win ? cyan : const Color(0xFFCE4561);
    return Scaffold(
      body: CyberBackground(
        colors: win
            ? const [Color(0xFFEAF6FF), Color(0xFFF8FBFF)]
            : const [Color(0xFFFFF0F2), Color(0xFFFFF8F8)],
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(win ? 'VICTORY!' : 'DEFEAT',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: color, letterSpacing: 3, shadows: [Shadow(color: color, blurRadius: 20)])),
            const SizedBox(height: 16),
            Icon(win ? Icons.emoji_events : Icons.refresh, size: 72, color: color),
            const SizedBox(height: 20),
            NeonPanel(
              color: color,
              child: Column(children: [
                Text(win ? 'Kamu berhasil mengalahkan Virax!' : 'Kamu kalah...\nCoba pelajari lagi materinya dan tingkatkan strateginya!',
                    textAlign: TextAlign.center),
                if (win) ...[
                  const SizedBox(height: 12),
                  const Text('Hadiah', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Text('EXP +120'), Text('Koin +150'), Text('Bintang +1'),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: 24),
            win
                ? NeonButton('LANJUT', icon: Icons.fast_forward, onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MapScreen()), (r) => r.isFirst))
                : NeonButton('COBA LAGI', color: const Color(0xFF6256C9), onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(sector: sector)));
                  }),
          ]),
        ),
      ),
    );
  }
}

// ===================== main.dart =====================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await game.load(); // muat progress dari penyimpanan lokal
  runApp(const NetguardApp());
}

class NetguardApp extends StatelessWidget {
  const NetguardApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NETGUARD',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: cyan, brightness: Brightness.light)).copyWith(
          scaffoldBackgroundColor: canvas,
          textTheme: ThemeData.light().textTheme.apply(bodyColor: ink, displayColor: ink),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, foregroundColor: ink, elevation: 0),
        ),
        home: const MenuScreen(),
      );
}

