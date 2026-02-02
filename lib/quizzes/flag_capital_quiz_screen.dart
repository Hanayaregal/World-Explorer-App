import '../screens/world_quiz_screen.dart';
//import 'world_quiz_screen.dart';

final flagCapitalData = [
  {
    "name": "France",
    "capital": "Paris",
    "flag": "https://flagcdn.com/w320/fr.png"
  },
  {
    "name": "Germany",
    "capital": "Berlin",
    "flag": "https://flagcdn.com/w320/de.png"
  },
  {
    "name": "Japan",
    "capital": "Tokyo",
    "flag": "https://flagcdn.com/w320/jp.png"
  },
  {
    "name": "Brazil",
    "capital": "Brasília",
    "flag": "https://flagcdn.com/w320/br.png"
  },
];

class FlagCapitalQuizScreen extends WorldQuizScreen {
  FlagCapitalQuizScreen({super.key})
      : super(
    title: "Flag to Capital Quiz",
    quizType: "Flag → Capital",
    data: flagCapitalData,
    questionLabel: "capital",
  );
}
