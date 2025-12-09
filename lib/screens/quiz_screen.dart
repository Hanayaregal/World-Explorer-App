// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> countries = [];
  dynamic currentCountry;
  int score = 0;
  int total = 0;

  final nameCtrl = TextEditingController();
  final capitalCtrl = TextEditingController();
  final popCtrl = TextEditingController();

  String result = "";
  bool answered = false;

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    final res = await http.get(Uri.parse(
        'https://restcountries.com/v3.1/all?fields=name,capital,population,flags'));
    if (res.statusCode == 200) {
      countries = json.decode(res.body);
      pickNewQuestion();
    }
  }

  void pickNewQuestion() {
    if (countries.isEmpty) return;
    currentCountry = countries[Random().nextInt(countries.length)];
    total++;

    nameCtrl.clear();
    capitalCtrl.clear();
    popCtrl.clear();
    result = "";
    answered = false;
    setState(() {});
  }

  void check() {
    if (answered) return;

    // ← NEW: Check if all fields are empty
    if (nameCtrl.text.trim().isEmpty &&
        capitalCtrl.text.trim().isEmpty &&
        popCtrl.text.trim().isEmpty) {
      result = "This field is mandatory. Please try again!";
      setState(() {});
      return;
    }

    answered = true;

    String correctName = currentCountry['name']['common'];
    String correctCapital = currentCountry['capital']?[0] ?? 'No capital';
    String correctPop = currentCountry['population'].toString();

    bool ok1 = nameCtrl.text.trim().toLowerCase() == correctName.toLowerCase();
    bool ok2 = capitalCtrl.text.trim().toLowerCase() == correctCapital.toLowerCase();
    bool ok3 = popCtrl.text.trim() == correctPop.replaceAll(',', '');

    if (ok1 && ok2 && ok3) {
      score++;
      result = "Perfect! All correct!";
    } else {
      result = "Wrong!\nCorrect answers:\n"
          "Country: $correctName\n"
          "Capital: $correctCapital\n"
          "Population: $correctPop";
    }
    setState(() {});
  }

  // BEAUTIFUL INPUT FIELD
  Widget myInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 17),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.green, width: 3),
        ),
      ),
    );
  }

  // BEAUTIFUL WORLD BUTTON
  Widget worldButton({
    required VoidCallback? onPressed,
    required String text,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[700]!, Colors.purple[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "World Country Quiz",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.purple[700],
        centerTitle: true,
        elevation: 8,
        shadowColor: Colors.black45,
      ),
      body: countries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Score: $score / $total", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            if (currentCountry['flags']['png'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  currentCountry['flags']['png'],
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.public, size: 100),
                ),
              ),
            const SizedBox(height: 30),

            myInputField(controller: nameCtrl, hint: "Country Name"),
            const SizedBox(height: 16),
            myInputField(controller: capitalCtrl, hint: "Capital City"),
            const SizedBox(height: 16),
            myInputField(controller: popCtrl, hint: "Population (numbers only)", keyboardType: TextInputType.number),
            const SizedBox(height: 40),

            // Submit Button
            Center(child: worldButton(onPressed: answered ? null : check, text: "Submit Answer")),

            const SizedBox(height: 20),

            // Result
            if (result.isNotEmpty)
              Card(
                color: result.contains("Perfect") ? Colors.green[100] : Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    result,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: result.contains("Perfect") ? Colors.green[800] : Colors.red[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // Next Question Button
            Center(child: worldButton(onPressed: answered ? pickNewQuestion : null, text: "Next Question")),
          ],
        ),
      ),
    );
  }
}