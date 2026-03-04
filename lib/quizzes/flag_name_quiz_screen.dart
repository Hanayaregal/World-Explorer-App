import 'package:flutter/material.dart';
import '../screens/smart_quiz_screen.dart';

final flagNameData = [
  {
    "name": "France",
    "flags": {"png": "https://flagcdn.com/w320/fr.png"}
  },
  {
    "name": "Germany",
    "flags": {"png": "https://flagcdn.com/w320/de.png"}
  },
  {
    "name": "Japan",
    "flags": {"png": "https://flagcdn.com/w320/jp.png"}
  },
  {
    "name": "Brazil",
    "flags": {"png": "https://flagcdn.com/w320/br.png"}
  },
];

class FlagNameQuizScreen extends StatelessWidget {
  const FlagNameQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartQuizScreen(
      countries: flagNameData,
      quizType: "name", // Quiz asks for country name from flag
    );
  }
}
