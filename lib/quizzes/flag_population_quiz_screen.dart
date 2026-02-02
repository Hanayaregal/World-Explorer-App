import '../screens/world_quiz_screen.dart';

final flagPopulationData = [
  {
    "name": "China",
    "population": "1.4B",
    "flag": "https://flagcdn.com/w320/cn.png"
  },
  {
    "name": "India",
    "population": "1.4B",
    "flag": "https://flagcdn.com/w320/in.png"
  },
  {
    "name": "United States",
    "population": "331M",
    "flag": "https://flagcdn.com/w320/us.png"
  },
  {
    "name": "Indonesia",
    "population": "275M",
    "flag": "https://flagcdn.com/w320/id.png"
  },
  {
    "name": "Brazil",
    "population": "214M",
    "flag": "https://flagcdn.com/w320/br.png"
  },
];

class FlagPopulationQuizScreen extends WorldQuizScreen {
  FlagPopulationQuizScreen({super.key})
      : super(
    title: "Flag to Population Quiz",
    quizType: "Flag → Population",
    data: flagPopulationData,
    questionLabel: "population",
  );
}
