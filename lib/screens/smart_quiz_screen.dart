// lib/screens/smart_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

enum AppLanguage { english, amharic }
enum QuizMode { typing, multipleChoice }

class SmartQuizScreen extends StatefulWidget {
  final List<dynamic> countries;
  final String quizType; // "name" | "capital" | "population"

  const SmartQuizScreen({
    super.key,
    required this.countries,
    required this.quizType,
  });

  @override
  State<SmartQuizScreen> createState() => _SmartQuizScreenState();
}

class _SmartQuizScreenState extends State<SmartQuizScreen> {
  AppLanguage language = AppLanguage.english;
  QuizMode mode = QuizMode.typing;

  late List<dynamic> remainingCountries;
  dynamic currentCountry;
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
    remainingCountries = List.from(widget.countries)..shuffle();
    pickNewQuestion();
  }

  void pickNewQuestion() {
    if (remainingCountries.isEmpty) {
      endQuiz();
      return;
    }

    setState(() {
      currentCountry = remainingCountries.removeLast();
      total++;
      answered = false;
      result = "";
      answerCtrl.clear();

      // Determine correct answer based on quizType
      if (widget.quizType == "name") {
        correctAnswer = currentCountry['name']['common'] ?? "Unknown";
      } else if (widget.quizType == "capital") {
        correctAnswer = currentCountry['capital']?[0] ?? "No capital";
      } else {
        correctAnswer = (currentCountry['population'] ?? 0).toString();
      }

      options = [correctAnswer];
      while (options.length < 4) {
        final randomCountry = widget.countries[Random().nextInt(widget.countries.length)];
        String value;

        if (widget.quizType == "name") {
          value = randomCountry['name']['common'] ?? "Unknown";
        } else if (widget.quizType == "capital") {
          value = randomCountry['capital']?[0] ?? "No capital";
        } else {
          value = (randomCountry['population'] ?? 0).toString();
        }

        if (!options.contains(value)) options.add(value);
      }
      options.shuffle();
    });
  }

  void submitTyping() {
    if (answered) return;

    String userAnswer = answerCtrl.text.trim();
    if (userAnswer.isEmpty) {
      setState(() {
        result = language == AppLanguage.english
            ? "Please type an answer!"
            : "እባክዎ መልስ ይጻፉ!";
      });
      return;
    }

    setState(() {
      answered = true;
      bool isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
      if (isCorrect) score++;
      result = isCorrect
          ? (language == AppLanguage.english ? "Correct!" : "ትክክል!")
          : (language == AppLanguage.english
          ? "Wrong! It's $correctAnswer"
          : "ስህተት! መልሱ $correctAnswer ነው");
    });
  }

  void selectOption(String selected) {
    if (answered) return;

    setState(() {
      answered = true;
      bool isCorrect = selected == correctAnswer;
      if (isCorrect) score++;
      result = isCorrect
          ? (language == AppLanguage.english ? "Correct!" : "ትክክል!")
          : (language == AppLanguage.english
          ? "Wrong! It's $correctAnswer"
          : "ስህተት! መልሱ $correctAnswer ነው");
    });
  }

  Future<void> saveHighScore(String playerName, int score) async {
    if (playerName.isEmpty) playerName = "Anonymous";

    try {
      await FirebaseFirestore.instance
          .collection('leaderboard')
          .doc(playerName)
          .set({
        'name': playerName,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
        'quizType': widget.quizType,
      }, SetOptions(merge: true));
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> endQuiz() async {
    String playerName = "";
    final TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            language == AppLanguage.english ? "Quiz Complete!" : "ፈተና ጨርሰዋል!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language == AppLanguage.english
                  ? "Final Score: $score / $total"
                  : "የመጨረሻ ውጤት: $score / $total",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              language == AppLanguage.english
                  ? "Enter your name for Global Leaderboard:"
                  : "ለዓለም አቀፍ ደረጃ ስምዎን ያስገቡ:",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.purple),
              ),
              child: TextField(
                controller: nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: language == AppLanguage.english ? "Your name" : "ስምዎ",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                playerName = nameController.text.trim();
                if (playerName.isEmpty) playerName = "Anonymous";
                Navigator.pop(context);
              },
              child: Text(
                language == AppLanguage.english ? "Save Score" : "ውጤት ያስቀምጡ",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );

    await saveHighScore(playerName, score);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            language == AppLanguage.english
                ? "Score saved! Check Analytics → Global Rank "
                : "ውጤት ተቀምጧል! ወደ ትንታኔ → ዓለም አቀፍ ደረጃ ይመልከቱ ",
          ),
          backgroundColor: Colors.purple,
        ),
      );
    }

    setState(() {
      remainingCountries = List.from(widget.countries)..shuffle();
      score = 0;
      total = 0;
      pickNewQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic question text based on quizType
    String questionText;
    if (widget.quizType == "name") {
      questionText = language == AppLanguage.english
          ? "What is the name of this country?"
          : "ይህ የቱ ሀገር ነው?";
    } else if (widget.quizType == "capital") {
      questionText = language == AppLanguage.english
          ? "What is the capital city?"
          : "ዋና ከተማው ምንድን ነው?";
    } else {
      questionText = language == AppLanguage.english
          ? "What is the approximate population?"
          : "የህዝብ ብዛት ምን ያህል ነው?";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == AppLanguage.english ? "World Quiz" : "ስማርት ፈተና",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          DropdownButton<AppLanguage>(
            value: language,
            icon: const Icon(Icons.language, color: Colors.white),
            dropdownColor: Colors.purple[700],
            items: const [
              DropdownMenuItem(value: AppLanguage.english, child: Text("EN", style: TextStyle(color: Colors.white))),
              DropdownMenuItem(value: AppLanguage.amharic, child: Text("አማ", style: TextStyle(color: Colors.white))),
            ],
            onChanged: (val) => setState(() => language = val!),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Score Card
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    language == AppLanguage.english ? "Score: $score / $total" : "ውጤት: $score / $total",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mode Toggle Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => mode = QuizMode.typing),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mode == QuizMode.typing ? Colors.purple[800] : Colors.grey[400],
                      foregroundColor: Colors.white,
                    ),
                    child: Text(language == AppLanguage.english ? "Type" : "መጻፍ"),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () => setState(() => mode = QuizMode.multipleChoice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mode == QuizMode.multipleChoice ? Colors.purple[800] : Colors.grey[400],
                      foregroundColor: Colors.white,
                    ),
                    child: Text(language == AppLanguage.english ? "Choice" : "ምርጫ"),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Flag / Image (added for visual appeal, like Ethiopia quiz could have)
              if (currentCountry != null && currentCountry['flags'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    currentCountry['flags']['png'] ?? '',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.flag, size: 80, color: Colors.grey)),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              Text(
                questionText,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Typing Mode
              if (mode == QuizMode.typing)
                TextField(
                  controller: answerCtrl,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 18),
                  keyboardType: widget.quizType == "population" ? TextInputType.number : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: language == AppLanguage.english ? "Type your answer..." : "መልስዎን ይጻፉ...",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.purple, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                ),

              // Multiple Choice Mode
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
                              : Colors.purple[100],
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(opt, style: const TextStyle(fontSize: 18, color: Colors.black)),
                      ),
                    ),
                  )).toList(),
                ),

              const SizedBox(height: 35),

              // Submit Button (Typing mode)
              if (mode == QuizMode.typing)
                Center(
                  child: ElevatedButton(
                    onPressed: answered ? null : submitTyping,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    ),
                    child: Text(
                      language == AppLanguage.english ? "Submit" : "ይላኩ",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // Result Feedback
              if (result.isNotEmpty)
                Card(
                  color: result.contains("Correct") || result.contains("ትክክል") ? Colors.green[100] : Colors.red[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      result,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: result.contains("Correct") || result.contains("ትክክል") ? Colors.green[800] : Colors.red[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 25),

              // Next / Play Again Button
              Center(
                child: ElevatedButton(
                  onPressed: answered ? pickNewQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                  ),
                  child: Text(
                    remainingCountries.isEmpty
                        ? (language == AppLanguage.english ? "Play Again" : "እንደገና ይጫወቱ")
                        : (language == AppLanguage.english ? "Next" : "ቀጣይ"),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    answerCtrl.dispose();
    super.dispose();
  }
}