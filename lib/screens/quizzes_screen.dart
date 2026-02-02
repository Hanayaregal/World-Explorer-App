// lib/screens/quizzes_screen.dart
import 'package:flutter/material.dart';
import 'ethiopia_quiz_screen.dart';
import 'smart_quiz_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  List<dynamic> worldCountries = [];

  @override
  void initState() {
    super.initState();
    loadWorldCountries();
  }

  Future<void> loadWorldCountries() async {
    try {
      final resp = await http.get(Uri.parse(
          'https://restcountries.com/v3.1/all?fields=name,flags,capital,population'
      ));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          worldCountries = data;
        });
      }
    } catch (e) {}
  }

  void startWorldQuiz(String type) {
    if (worldCountries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Loading countries... please wait")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmartQuizScreen(countries: worldCountries, quizType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.purple[700]!, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple[200]!,
                  blurRadius: 20,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Center(
                  child: Text(
                    "Tap to select a quiz",
                    style: TextStyle(fontSize: 22, color: Colors.purple[700], fontWeight: FontWeight.bold),
                  ),
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.purple[700], size: 50),
                dropdownColor: Colors.white,
                style: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
                itemHeight: 80,
                menuMaxHeight: 400,
                items: [
                  DropdownMenuItem(value: "name", child: Center(child: Text("Guess Country Name from Flag", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[700])))),
                  DropdownMenuItem(value: "capital", child: Center(child: Text("Guess Capital from Flag", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[700])))),
                  DropdownMenuItem(value: "population", child: Center(child: Text("Guess Population Range from Flag", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple[700])))),
                  DropdownMenuItem(value: "ethiopia", child: Center(child: Text("Ethiopian Regions Quiz", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)))),
                ],
                onChanged: (value) {
                  if (value == "ethiopia") {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EthiopiaQuizScreen()));
                  } else if (value != null) {
                    startWorldQuiz(value);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 80),

          Icon(Icons.quiz, size: 120, color: Colors.purple[700]),
          const SizedBox(height: 20),
          Text("Test your world knowledge!", style: TextStyle(fontSize: 20, color: Colors.purple[600], fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}