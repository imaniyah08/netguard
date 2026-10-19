import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../widgets/neon.dart';
import 'map_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CyberBackground(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 24),
              const Text('NETGUARD',
                  style: TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: cyan, letterSpacing: 3, shadows: [Shadow(color: cyan, blurRadius: 20)])),
              const Text('Guardians Of The Cyber Network', style: TextStyle(fontSize: 14, letterSpacing: 1)),
              const Spacer(),
              // TODO: ganti dengan Image.asset karakter Guardian & Virax
              const Text('🧑‍🔬  ☁️', style: TextStyle(fontSize: 90)),
              const Spacer(),
              NeonButton('MULAI', icon: Icons.play_arrow, big: true, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
              }),
              const SizedBox(height: 12),
              NeonButton('PENGATURAN', icon: Icons.settings, onTap: () => _settings(context)),
              const SizedBox(height: 12),
              NeonButton('KELUAR', icon: Icons.exit_to_app, onTap: () => Navigator.of(context).maybePop()),
              const SizedBox(height: 12),
            ]),
          ),
        ),
      );

  void _settings(BuildContext context) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: deepBlue,
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
