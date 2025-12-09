// lib/screens/ethiopia_quiz_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';

enum AppLanguage { english, amharic }
enum QuizMode { typing, multipleChoice }

class EthiopiaQuizScreen extends StatefulWidget {
  const EthiopiaQuizScreen({super.key});
  @override
  State<EthiopiaQuizScreen> createState() => _EthiopiaQuizScreenState();
}

class _EthiopiaQuizScreenState extends State<EthiopiaQuizScreen> {
  AppLanguage language = AppLanguage.english;
  QuizMode mode = QuizMode.typing;

  final Map<String, String> regionsEn = {
    "Addis Ababa": "Addis Ababa",
    "Afar": "Semera",
    "Amhara": "Bahir Dar",
    "Benishangul-Gumuz": "Asosa",
    "Dire Dawa": "Dire Dawa",
    "Gambela": "Gambela",
    "Harari": "Harar",
    "Oromia": "Finfinne",
    "Sidama": "Hawassa",
    "Somali": "Jijiga",
    "South West Ethiopia": "Bonga",
    "Central Ethiopia": "Shashemene",
    "South Ethiopia": "Wolaita Sodo",
  };

  final Map<String, String> regionsAm = {
    "አዲስ አበባ": "አዲስ አበባ",
    "አፋር": "ሴመራ",
    "አማራ": "ባህር ዳር",
    "ቤኒሻንጉል-ጉሙዝ": "አሶሳ",
    "ድሬዳዋ": "ድሬዳዋ",
    "ጋምቤላ": "ጋምቤላ",
    "ሀረሪ": "ሀረር",
    "ኦሮሚያ": "ፊንፊኔ",
    "ሲዳማ": "ሀዋሳ",
    "ሶማሌ": "ጅጅጋ",
    "ደቡብ ምዕራብ ኢትዮጵያ": "ቦንጋ",
    "መካከለኛ ኢትዮጵያ": "ሻሸመኔ",
    "ደቡብ ኢትዮጵያ": "ወላይታ ሶዶ",
  };

  late Map<String, String> regions;
  late List<String> remainingRegions;

  String currentRegion = "";
  String correctAnswer = "";
  List<String> options = [];
  int score = 0;
  int total = 0;
  bool answered = false;
  String result = "";

  final TextEditingController answerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateLanguage();
  }

  void _updateLanguage() {
    regions = language == AppLanguage.english ? regionsEn : regionsAm;
    remainingRegions = regions.keys.toList()..shuffle();
    pickNewQuestion();
  }

  void pickNewQuestion() {
    if (remainingRegions.isEmpty) {
      result = language == AppLanguage.english
          ? "Congratulations! You completed all regions!\nScore: $score/13"
          : "እንኳን ደስ አለዎት! ሁሉንም ክልሎች ጨርሰዋል!\nውጤት: $score/13";
      setState(() {});
      return;
    }

    currentRegion = remainingRegions.removeLast();
    correctAnswer = regions[currentRegion]!;

    options = [correctAnswer];
    while (options.length < 4) {
      String wrong = regions.values.elementAt(Random().nextInt(regions.length));
      if (!options.contains(wrong)) options.add(wrong);
    }
    options.shuffle();

    total++;
    answerCtrl.clear();
    answered = false;
    result = "";
    setState(() {});
  }

  void submitTyping() {
    if (answered) return;

    String userAnswer = answerCtrl.text.trim();

    // ← NEW: Check if empty!
    if (userAnswer.isEmpty) {
      result = language == AppLanguage.english
          ? "This field is mandatory. Please try again!"
          : "ይህ ቦታ መሞላት አለበት። እባክዎ እንደገና ይሞክሩ!";
      setState(() {});
      return;
    }

    answered = true;
    bool isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
    if (isCorrect) score++;

    result = isCorrect
        ? (language == AppLanguage.english
        ? "Correct! $correctAnswer is the capital of $currentRegion!"
        : "ትክክል! $correctAnswer የ$currentRegion ዋና ከተማ ናት!")
        : (language == AppLanguage.english
        ? "Wrong!\nThe capital of $currentRegion is:\n**$correctAnswer**"
        : "ይቅርታ!\nየ$currentRegion ዋና ከተማ:\n**$correctAnswer** ናት");
    setState(() {});
  }

  void selectOption(String selected) {
    if (answered) return;
    answered = true;

    bool isCorrect = selected == correctAnswer;
    if (isCorrect) score++;

    result = isCorrect
        ? (language == AppLanguage.english
        ? "Correct! $correctAnswer is the capital of $currentRegion!"
        : "ትክክል! $correctAnswer የ$currentRegion ዋና ከተማ ናት!")
        : (language == AppLanguage.english
        ? "Wrong!\nThe capital of $currentRegion is:\n**$correctAnswer**"
        : "ይቅርታ!\nየ$currentRegion ዋና ከተማ:\n**$correctAnswer** ናት");
    setState(() {});
  }

  void nextQuestion() {
    pickNewQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == AppLanguage.english ? "Ethiopian Regions Quiz" : "የኢትዮጵያ ክልሎች ፈተና",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        actions: [
          DropdownButton<AppLanguage>(
            value: language,
            icon: const Icon(Icons.language, color: Colors.white),
            dropdownColor: Colors.green[700],
            items: const [
              DropdownMenuItem(value: AppLanguage.english, child: Text("EN", style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: AppLanguage.amharic, child: Text("አማ", style: TextStyle(color: Colors.white))),
            ],
            onChanged: (val) {
              setState(() => language = val!);
              _updateLanguage();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  language == AppLanguage.english ? "Score: $score / $total" : "ውጤት: $score / $total",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green[800]),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => mode = QuizMode.typing),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mode == QuizMode.typing ? Colors.green[800] : Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(language == AppLanguage.english ? "Type" : "መጻፍ"),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => setState(() => mode = QuizMode.multipleChoice),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mode == QuizMode.multipleChoice ? Colors.green[800] : Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(language == AppLanguage.english ? "Choice" : "ምርጫ"),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network("https://flagcdn.com/w320/et.png", height: 100, width: 200, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 4,
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  language == AppLanguage.english
                      ? "What is the capital of\n$currentRegion?"
                      : "የ$currentRegion ዋና ከተማ ማን ትባላለች?",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),

            if (mode == QuizMode.typing)
              TextField(
                controller: answerCtrl,
                decoration: InputDecoration(
                  hintText: language == AppLanguage.english ? "Type city name..." : "የከተማ ስም ይጻፉ...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),

            if (mode == QuizMode.multipleChoice)
              Column(
                children: options.map((opt) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: answered ? null : () => selectOption(opt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: answered
                            ? (opt == correctAnswer ? Colors.green[600] : Colors.red[300])
                            : Colors.green[100],
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: Text(opt, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                )).toList(),
              ),

            const SizedBox(height: 35),

            if (mode == QuizMode.typing)
              Center(
                child: ElevatedButton(
                  onPressed: answered ? null : submitTyping,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                  ),
                  child: Text(
                    language == AppLanguage.english ? "Submit" : "ይላኩ",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            if (result.isNotEmpty)
              Card(
                color: result.contains("Correct") || result.contains("ትክክል") ? Colors.green[100] : Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(result,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                          color: result.contains("Correct") || result.contains("ትክክል") ? Colors.green[800] : Colors.red[800])),
                ),
              ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: answered ? nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                ),
                child: Text(
                  remainingRegions.isEmpty
                      ? (language == AppLanguage.english ? "Play Again" : "እንደገና ይጫወቱ")
                      : (language == AppLanguage.english ? "Next Question" : "የሚቀጥለው ጥያቄ"),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}