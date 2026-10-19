import 'dart:async';
import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../widgets/neon.dart';
import 'result_screen.dart';

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
    if (selected < 0 || answered) return;
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
    if (!mounted) return;
    if (hearts <= 0) return finish(false);
    if (index >= qs.length - 1) return finish(correct >= (qs.length * .6).ceil());
    setState(() {
      index++;
      selected = -1;
      answered = false;
    });
  }

  void finish(bool win) {
    timer?.cancel();
    if (win) game.completeSector(widget.sector.id, starsEarned: hearts.clamp(1, 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(win: win, sector: widget.sector, secondsLeft: seconds)),
    );
  }

  Color _optionColor(int i) {
    if (!answered) return i == selected ? cyan : Colors.white24;
    if (i == q.answer) return Colors.greenAccent;
    if (i == selected) return Colors.redAccent;
    return Colors.white24;
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
                  color: Colors.pinkAccent,
                  backgroundColor: Colors.white12,
                  minHeight: 8,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            const Text('🧑‍🔬  ☁️', style: TextStyle(fontSize: 64)),
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
            LinearProgressIndicator(value: (index + 1) / qs.length, color: cyan, backgroundColor: Colors.white12),
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
