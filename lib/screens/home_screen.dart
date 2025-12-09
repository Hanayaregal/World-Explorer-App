// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../widgets/country_card.dart';
import '../widgets/detail_dialogs.dart';
import '../data/mock_data.dart';
import '../data/regions_data.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';
import 'ethiopia_quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> displayCountries = [];
  bool isLoading = false;
  bool showDefaultCountries = true;
  int? hoveredIndex;

  // LEADERBOARD & PLAYER NAME
  List<Map<String, dynamic>> leaderboard = [];
  String playerName = "Ethiopian Student";

  // AFRICA SUBREGIONS
  final Map<String, String> africaSubregions = {
    "Eastern Africa": "Eastern Africa",
    "Western Africa": "Western Africa",
    "Northern Africa": "Northern Africa",
    "Central Africa": "Central Africa",
    "Southern Africa": "Southern Africa",
  };

  final List<Map<String, dynamic>> favorites = [
    {"name": "Ethiopia", "flag": "https://flagcdn.com/w320/et.png", "type": "country"},
    {"name": "Japan", "flag": "https://flagcdn.com/w320/jp.png", "type": "country"},
    {"name": "Brazil", "flag": "https://flagcdn.com/w320/br.png", "type": "country"},
    {"name": "Germany", "flag": "https://flagcdn.com/w320/de.png", "type": "country"},
    {"name": "Africa", "flag": "globe", "type": "continent"},
    {"name": "Asia", "flag": "globe", "type": "continent"},
    {"name": "Europe", "flag": "globe", "type": "continent"},
    {"name": "America", "flag": "globe", "type": "continent"},
  ];

  String? selectedFavorite;

  @override
  void initState() {
    super.initState();
    _loadPlayerName();
    _loadLeaderboard();
    _loadDefaultCountries();
  }

  // PLAYER NAME
  Future<void> _loadPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      playerName = prefs.getString('player_name') ?? "Ethiopian Student";
    });
  }

  Future<void> _savePlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', name);
    setState(() => playerName = name);
  }

  // LEADERBOARD
  Future<void> _loadLeaderboard() async {
    try {
      final response = await http.get(Uri.parse(
          'https://world-explorer-leaderboard.free.beeceptor.com/leaderboard'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          leaderboard = List<Map<String, dynamic>>.from(data['top20']);
        });
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('leaderboard');
      if (saved != null) {
        setState(() {
          leaderboard = List<Map<String, dynamic>>.from(json.decode(saved));
        });
      }
    }
  }

  Future<void> _submitScore(int score) async {
    try {
      await http.post(
        Uri.parse('https://world-explorer-leaderboard.free.beeceptor.com/submit'),
        body: json.encode({"name": playerName, "score": score}),
        headers: {'Content-Type': 'application/json'},
      );
      _loadLeaderboard();
    } catch (e) {
      // Works offline too
    }
  }

  Future<void> _loadDefaultCountries() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(
          'https://restcountries.com/v3.1/all?fields=name,capital,population,languages,flags,region,subregion'));
      if (response.statusCode == 200) {
        final List<dynamic> all = json.decode(response.body);
        setState(() {
          displayCountries = all.take(8).toList();
        });
      }
    } catch (e) {
      setState(() {
        displayCountries = mockCountries.take(8).toList();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> search(String query) async {
    query = query.trim();
    if (query.isEmpty) {
      _loadDefaultCountries();
      return;
    }
    setState(() {
      isLoading = true;
      displayCountries = [];
      showDefaultCountries = false;
    });

    String url = 'https://restcountries.com/v3.1/name/$query';
    if (africaSubregions.containsKey(query)) {
      url = 'https://restcountries.com/v3.1/subregion/$query';
    }

    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        setState(() => displayCountries = json.decode(resp.body));
      }
    } catch (e) {
      // silent
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAfricaSubregions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              const Text("Africa Subregions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...africaSubregions.keys.map((subregion) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.public, color: Colors.blue),
                  title: Text(subregion, style: const TextStyle(fontSize: 18)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    search(subregion);
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _onFavoriteSelected(String? value) {
    if (value == null) return;
    selectedFavorite = value;
    _controller.clear();
    if (value == "Africa") {
      _showAfricaSubregions();
    } else if (["Asia", "Europe", "America"].contains(value)) {
      search(value);
    } else {
      search(value);
    }
  }

  void _showCountryDetails(dynamic country) {
    final name = country['name']['common'] ?? 'Unknown';
    final capital = country['capital']?[0] ?? 'No capital';
    final population = NumberFormat.compact().format(country['population'] ?? 0);
    final languages = country['languages'] != null
        ? (country['languages'] as Map).values.take(3).join(', ')
        : 'Not specified';

    showDialog(
      context: context,
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 20,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        country['flags']?['png'] ?? '',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Icon(Icons.public, size: 90),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    _centeredDetail("Capital", capital),
                    const SizedBox(height: 20),
                    _centeredDetail("Population", population),
                    const SizedBox(height: 20),
                    _centeredDetail("Language", languages),
                    const SizedBox(height: 20),
                    _centeredDetail("Region", country['region'] ?? 'Unknown'),
                    const SizedBox(height: 20),
                    _centeredDetail("Subregion", country['subregion'] ?? 'Unknown'),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                        label: const Text("Close", style: TextStyle(fontSize: 17)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _centeredDetail(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 26), textAlign: TextAlign.center),
      ],
    );
  }

  void _showLeaderboardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Global Leaderboard", textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: leaderboard.isEmpty
              ? const Center(child: Text("No scores yet!\nBe the first!", textAlign: TextAlign.center))
              : ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, i) {
              final player = leaderboard[i];
              final isMe = player['name'] == playerName;
              return ListTile(
                leading: Text("${i + 1}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                title: Text(player['name'],
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      color: isMe ? Colors.blue[700] : Colors.black,
                    )),
                trailing: Text("${player['score']}", style: const TextStyle(fontSize: 18)),
                tileColor: i == 0 ? Colors.amber[100]
                    : i == 1 ? Colors.grey[200]
                    : i == 2 ? Colors.brown[100]
                    : null,
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  void _changeNameDialog() {
    final controller = TextEditingController(text: playerName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Your Name"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Enter your name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim().isEmpty ? "Student" : controller.text.trim();
              _savePlayerName(newName);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("World Explorer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.leaderboard, color: Colors.yellow), onPressed: _showLeaderboardDialog),
          IconButton(icon: const Icon(Icons.person), onPressed: _changeNameDialog),
        ],
      ),
      body: Column(
        children: [
          // SEARCH + FAVORITES
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 180,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.blue[300]!),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Row(children: const [Icon(Icons.favorite, color: Colors.red), SizedBox(width: 8), Text("Favorites")]),
                      value: selectedFavorite,
                      items: favorites.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item["name"],
                          child: Row(
                            children: [
                              if (item["type"] == "country")
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(item["flag"], width: 36, height: 24, fit: BoxFit.cover),
                                )
                              else
                                const Icon(Icons.public, color: Colors.blue, size: 28),
                              const SizedBox(width: 10),
                              Text(item["name"],
                                  style: TextStyle(
                                    fontWeight: item["type"] == "country" ? FontWeight.bold : FontWeight.normal,
                                    color: item["type"] == "continent" ? Colors.blue[800] : Colors.black87,
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _onFavoriteSelected,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (v) => search(v),
                    decoration: InputDecoration(
                      hintText: "Search country or continent...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.blue[700]),
                        onPressed: () => search(_controller.text),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue[200]!, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue[700]!, width: 3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // QUIZ BUTTONS
          LayoutBuilder(
            builder: (context, constraints) {
              final isLarge = constraints.maxWidth > 700;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isLarge
                    ? Row(children: [
                  Expanded(child: _quizButton("Play World Countries Quiz", Colors.purple[700]!, const QuizScreen())),
                  const SizedBox(width: 20),
                  Expanded(child: _quizButton("Ethiopian Regions Quiz", Colors.green[700]!, const EthiopiaQuizScreen())),
                ])
                    : Column(children: [
                  _quizButton("Play World Countries Quiz", Colors.purple[700]!, const QuizScreen()),
                  const SizedBox(height: 16),
                  _quizButton("Ethiopian Regions Quiz", Colors.green[700]!, const EthiopiaQuizScreen()),
                ]),
              );
            },
          ),

          const SizedBox(height: 20),

          // RESULTS
          Expanded(
            child: Container(
              color: Colors.blue[50],
              padding: const EdgeInsets.all(16),
              child: _buildResultsContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizButton(String title, Color color, Widget screen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        label: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  Widget _buildResultsContent() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (displayCountries.isEmpty && !showDefaultCountries) {
      return const Center(child: Text("No countries found", style: TextStyle(fontSize: 18)));
    }
    if (displayCountries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text("Explore Countries of the World", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
            Text("Start typing to search...", style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    final title = showDefaultCountries
        ? "Click any country card to view details"
        : "Found ${displayCountries.length} countr${displayCountries.length > 1 ? 'ies' : 'y'}";

    if (displayCountries.length == 1 && !showDefaultCountries) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: CountryCard(
                  country: displayCountries[0],
                  index: 0,
                  hoveredIndex: hoveredIndex,
                  onHover: (i) => setState(() => hoveredIndex = i),
                  onDetails: (country) => _showCountryDetails(country),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              int columns = 1;
              if (constraints.maxWidth >= 1400) columns = 5;
              else if (constraints.maxWidth >= 1100) columns = 4;
              else if (constraints.maxWidth >= 800) columns = 3;
              else if (constraints.maxWidth >= 550) columns = 2;

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: 0.78,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: displayCountries.length,
                itemBuilder: (_, i) => CountryCard(
                  country: displayCountries[i],
                  index: i,
                  hoveredIndex: hoveredIndex,
                  onHover: (i) => setState(() => hoveredIndex = i),
                  onDetails: (country) => _showCountryDetails(country),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}