import 'package:flutter/material.dart';
import '../screens/smart_quiz_screen.dart';

final flagPopulationData = [
  {
    "name": "China",
    "population": "1.4B",
    "flags": {"png": "https://flagcdn.com/w320/cn.png"}
  },
  {
    "name": "India",
    "population": "1.4B",
    "flags": {"png": "https://flagcdn.com/w320/in.png"}
  },
  {
    "name": "United States",
    "population": "331M",
    "flags": {"png": "https://flagcdn.com/w320/us.png"}
  },
  {
    "name": "Indonesia",
    "population": "275M",
    "flags": {"png": "https://flagcdn.com/w320/id.png"}
  },
  {
    "name": "Brazil",
    "population": "214M",
    "flags": {"png": "https://flagcdn.com/w320/br.png"}
  },
];

class FlagPopulationQuizScreen extends StatelessWidget {
  const FlagPopulationQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartQuizScreen(
      countries: flagPopulationData,
      quizType: "population", // Quiz asks for population
    );
  }
}
