import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../widgets/neon.dart';
import 'quiz_screen.dart';

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
                          color: done ? Colors.greenAccent : (unlocked ? cyan : Colors.grey),
                          child: Row(children: [
                            Icon(unlocked ? (done ? Icons.verified : Icons.hub) : Icons.lock,
                                size: 36, color: done ? Colors.greenAccent : (unlocked ? cyan : Colors.grey)),
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
