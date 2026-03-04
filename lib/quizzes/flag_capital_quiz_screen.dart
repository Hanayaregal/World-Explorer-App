import 'package:flutter/material.dart';
import '../screens/smart_quiz_screen.dart';

final flagCapitalData = [
  {
    "name": "France",
    "capital": "Paris",
    "flags": {"png": "https://flagcdn.com/w320/fr.png"},
  },
  {
    "name": "Germany",
    "capital": "Berlin",
    "flags": {"png": "https://flagcdn.com/w320/de.png"},
  },
  {
    "name": "Japan",
    "capital": "Tokyo",
    "flags": {"png": "https://flagcdn.com/w320/jp.png"},
  },
  {
    "name": "Brazil",
    "capital": "Brasília",
    "flags": {"png": "https://flagcdn.com/w320/br.png"},
  },
];

class FlagCapitalQuizScreen extends StatelessWidget {
  const FlagCapitalQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartQuizScreen(
      countries: flagCapitalData,
      quizType: "capital", // The quiz will ask for capitals from flags
    );
  }
}
