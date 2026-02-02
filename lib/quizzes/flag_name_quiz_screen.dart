import '../screens/world_quiz_screen.dart';
//import 'world_quiz_screen.dart';

final flagNameData = [
  {
    "name": "France",
    "flag": "https://flagcdn.com/w320/fr.png"
  },
  {
    "name": "Germany",
    "flag": "https://flagcdn.com/w320/de.png"
  },
  {
    "name": "Japan",
    "flag": "https://flagcdn.com/w320/jp.png"
  },
  {
    "name": "Brazil",
    "flag": "https://flagcdn.com/w320/br.png"
  },
];

class FlagNameQuizScreen extends WorldQuizScreen {
  FlagNameQuizScreen({super.key})
      : super(
    title: "Flag to Country Quiz",
    quizType: "Flag → Country",
    data: flagNameData,
    questionLabel: "name",
  );
}
