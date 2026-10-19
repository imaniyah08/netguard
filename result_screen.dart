import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../widgets/neon.dart';
import 'map_screen.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final bool win;
  final Sector sector;
  final int secondsLeft;
  const ResultScreen({super.key, required this.win, required this.sector, required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final color = win ? cyan : Colors.pinkAccent;
    return Scaffold(
      body: CyberBackground(
        colors: win
            ? const [Color(0xFF0B1450), Color(0xFF050B2E)]
            : const [Color(0xFF3A0B2E), Color(0xFF12061F)],
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(win ? 'VICTORY!' : 'DEFEAT',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: color, letterSpacing: 3, shadows: [Shadow(color: color, blurRadius: 20)])),
            const SizedBox(height: 16),
            Text(win ? '🧑‍🔬⚔️  😵‍💫' : '😵  ☁️', style: const TextStyle(fontSize: 70)),
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
                    Text('⚡ +120'), Text('🪙 +150'), Text('🎴 +1'),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: 24),
            win
                ? NeonButton('LANJUT', icon: Icons.fast_forward, onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MapScreen()), (r) => r.isFirst))
                : NeonButton('COBA LAGI', color: Colors.purpleAccent, onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(sector: sector)));
                  }),
          ]),
        ),
      ),
    );
  }
}
