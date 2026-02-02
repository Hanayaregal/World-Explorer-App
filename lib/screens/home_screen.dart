import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:world_explorer/screens/profile_screen.dart';
import 'package:world_explorer/screens/quizzes_screen.dart';
import '../widgets/country_card.dart';
import 'analytics_screen.dart';
//import 'quizzes/quizzes_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

// NEW: Simple Debouncer class (added only this)
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeContent(),
    const AnalyticsScreen(),
    const QuizzesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple[50]!, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple[700]!, Colors.purple[900]!],
              ),
            ),
          ),
          title: Text(
            _selectedIndex == 0
                ? "World Explorer"
                : _selectedIndex == 1
                ? "Analytics"
                : _selectedIndex == 2
                ? "Choose a Quiz"
                : "Profile",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          elevation: 8,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purple[700]!, Colors.purple[900]!],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz),
                label: 'Quizzes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

// ── HOME CONTENT ────────────────────────────────────────────────────────────

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Debouncer _debouncer = Debouncer(milliseconds: 400);

  List<dynamic> displayCountries = [];
  List<dynamic> allCountries = [];
  List<String> _autocompleteSuggestions = [];

  bool isLoading = false;
  int? hoveredIndex;
  String? selectedFavorite;

  final List<Map<String, dynamic>> ethiopiaRegions = [
    {"region": "Addis Ababa", "capital": "Addis Ababa"},
    {"region": "Afar", "capital": "Semera"},
    {"region": "Amhara", "capital": "Bahir Dar"},
    {"region": "Benishangul-Gumuz", "capital": "Asosa"},
    {"region": "Dire Dawa", "capital": "Dire Dawa"},
    {"region": "Gambela", "capital": "Gambela"},
    {"region": "Harari", "capital": "Harar"},
    {"region": "Oromia", "capital": "Finfinne"},
    {"region": "Sidama", "capital": "Hawassa"},
    {"region": "Somali", "capital": "Jijiga"},
    {"region": "South Ethiopia", "capital": "Wolaita Sodo"},
    {"region": "South West Ethiopia", "capital": "Bonga"},
    {"region": "Central Ethiopia", "capital": "Shashemene"},
    {"region": "Tigray", "capital": "Mekelle"},
  ];

  final Map<String, List<Map<String, String>>> ethiopiaZones = {
    "Addis Ababa": [
      {
        "name": "City Administration",
        "description": "Modern capital with African Union headquarters, stunning skyline and Holy Trinity Cathedral",
      },
    ],
    "Afar": [
      {
        "name": "Awsi Rasu (Zone 1)",
        "description": "Danakil Depression — one of the hottest places on Earth with colorful salt lakes and Dallol volcano",
      },
    ],
    "Amhara": [
      {
        "name": "North Gondar",
        "description": "Historic Gondar — UNESCO-listed Fasil Ghebbi royal castles and palaces",
      },
      {
        "name": "West Gojjam",
        "description": "Blue Nile Falls (Tis Abay) and ancient island monasteries on Lake Tana",
      },
      {
        "name": "South Wollo",
        "description": "Lalibela — incredible rock-hewn churches carved from solid rock (UNESCO)",
      },
    ],
    "Benishangul-Gumuz": [
      {
        "name": "Metekel",
        "description": "Grand Ethiopian Renaissance Dam (GERD) — Africa's largest hydropower project",
      },
    ],
    "Dire Dawa": [
      {
        "name": "City Administration",
        "description": "Historic railway station and multicultural commercial hub",
      },
    ],
    "Gambela": [
      {
        "name": "Anyuak Zone",
        "description": "Gambela National Park — diverse wildlife and Baro River landscapes",
      },
    ],
    "Harari": [
      {
        "name": "City Administration",
        "description": "Ancient walled city of Harar Jugol — UNESCO World Heritage with 82 mosques",
      },
    ],
    "Oromia": [
      {
        "name": "Bale",
        "description": "Bale Mountains National Park — endemic Ethiopian wolf and highland scenery",
      },
      {
        "name": "Jimma",
        "description": "Birthplace of Arabica coffee with lush rainforests",
      },
    ],
    "Sidama": [
      {
        "name": "Sidama Zone",
        "description": "Premium Sidamo coffee and beautiful Lake Hawassa",
      },
    ],
    "Somali": [
      {
        "name": "Fafan",
        "description": "Jijiga city and surrounding pastoral lands",
      },
    ],
    "South Ethiopia": [
      {
        "name": "Wolayita",
        "description": "Wolaita Sodo city with fertile lands and traditional culture",
      },
    ],
    "South West Ethiopia": [
      {
        "name": "Kafa",
        "description": "Birthplace of coffee, UNESCO Kafa Biosphere Reserve with wild forests",
      },
    ],
    "Central Ethiopia": [
      {
        "name": "Gurage",
        "description": "Known for enset cultivation and traditional round houses",
      },
    ],
    "Tigray": [
      {
        "name": "Central Tigray",
        "description": "Ancient Axum — giant obelisks and archaeological treasures",
      },
      {
        "name": "Eastern Tigray",
        "description": "Gheralta rock-hewn churches in dramatic cliffs",
      },
    ],
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

  List<String> _getSubregions(String continent) {
    if (continent == "Africa") {
      return ["Eastern Africa", "Western Africa", "Northern Africa", "Middle Africa", "Southern Africa"];
    } else if (continent == "Asia") {
      return ["Eastern Asia", "South-Eastern Asia", "Southern Asia", "Central Asia", "Western Asia"];
    } else if (continent == "Europe") {
      return ["Eastern Europe", "Northern Europe", "Southern Europe", "Western Europe"];
    } else if (continent == "America") {
      return ["North America", "Central America", "South America", "Caribbean"];
    }
    return [];
  }

  final List<Map<String, dynamic>> defaultCountries = [
    {
      "name": {"common": "Brazil"},
      "capital": ["Brasília"],
      "population": 215313498,
      "flags": {"png": "https://flagcdn.com/w320/br.png"},
      "languages": {"por": "Portuguese"},
      "currencies": {"BRL": {"name": "Brazilian real", "symbol": "R\$"}},
      "region": "Americas",
      "subregion": "South America",
      "timezones": ["UTC-05:00"],
      "idd": {"root": "+5", "suffixes": ["5"]},
      "area": 8515767,
    },
    {
      "name": {"common": "Germany"},
      "capital": ["Berlin"],
      "population": 83240525,
      "flags": {"png": "https://flagcdn.com/w320/de.png"},
      "languages": {"deu": "German"},
      "currencies": {"EUR": {"name": "Euro", "symbol": "€"}},
      "region": "Europe",
      "subregion": "Western Europe",
      "timezones": ["UTC+01:00"],
      "idd": {"root": "+4", "suffixes": ["9"]},
      "area": 357114,
    },
    {
      "name": {"common": "Nigeria"},
      "capital": ["Abuja"],
      "population": 218541212,
      "flags": {"png": "https://flagcdn.com/w320/ng.png"},
      "languages": {"eng": "English"},
      "currencies": {"NGN": {"name": "Nigerian naira", "symbol": "₦"}},
      "region": "Africa",
      "subregion": "Western Africa",
      "timezones": ["UTC+01:00"],
      "idd": {"root": "+2", "suffixes": ["34"]},
      "area": 923768,
    },
    {
      "name": {"common": "India"},
      "capital": ["New Delhi"],
      "population": 1428627663,
      "flags": {"png": "https://flagcdn.com/w320/in.png"},
      "languages": {"eng": "English", "hin": "Hindi"},
      "currencies": {"INR": {"name": "Indian rupee", "symbol": "₹"}},
      "region": "Asia",
      "subregion": "Southern Asia",
      "timezones": ["UTC+05:30"],
      "idd": {"root": "+9", "suffixes": ["1"]},
      "area": 3287590,
    },
    {
      "name": {"common": "France"},
      "capital": ["Paris"],
      "population": 67935660,
      "flags": {"png": "https://flagcdn.com/w320/fr.png"},
      "languages": {"fra": "French"},
      "currencies": {"EUR": {"name": "Euro", "symbol": "€"}},
      "region": "Europe",
      "subregion": "Western Europe",
      "timezones": ["UTC+01:00"],
      "idd": {"root": "+3", "suffixes": ["3"]},
      "area": 551695,
    },
    {
      "name": {"common": "United States"},
      "capital": ["Washington, D.C."],
      "population": 338289857,
      "flags": {"png": "https://flagcdn.com/w320/us.png"},
      "languages": {"eng": "English"},
      "currencies": {"USD": {"name": "United States dollar", "symbol": "\$"}},
      "region": "Americas",
      "subregion": "North America",
      "timezones": ["UTC-10:00"],
      "idd": {"root": "+1", "suffixes": [""]},
      "area": 9372610,
    },
    {
      "name": {"common": "China"},
      "capital": ["Beijing"],
      "population": 1425887337,
      "flags": {"png": "https://flagcdn.com/w320/cn.png"},
      "languages": {"zho": "Chinese"},
      "currencies": {"CNY": {"name": "Chinese yuan", "symbol": "¥"}},
      "region": "Asia",
      "subregion": "Eastern Asia",
      "timezones": ["UTC+08:00"],
      "idd": {"root": "+8", "suffixes": ["6"]},
      "area": 9707611,
    },
    {
      "name": {"common": "Russia"},
      "capital": ["Moscow"],
      "population": 144713314,
      "flags": {"png": "https://flagcdn.com/w320/ru.png"},
      "languages": {"rus": "Russian"},
      "currencies": {"RUB": {"name": "Russian ruble", "symbol": "₽"}},
      "region": "Europe",
      "subregion": "Eastern Europe",
      "timezones": ["UTC+03:00"],
      "idd": {"root": "+7", "suffixes": [""]},
      "area": 17098242,
    },
    {
      "name": {"common": "Ethiopia"},
      "capital": ["Addis Ababa"],
      "population": 126527060,
      "flags": {"png": "https://flagcdn.com/w320/et.png"},
      "languages": {"amh": "Amharic"},
      "currencies": {"ETB": {"name": "Ethiopian birr", "symbol": "Br"}},
      "region": "Africa",
      "subregion": "Eastern Africa",
      "timezones": ["UTC+03:00"],
      "idd": {"root": "+2", "suffixes": ["51"]},
      "area": 1104300,
    },
    {
      "name": {"common": "Japan"},
      "capital": ["Tokyo"],
      "population": 123951692,
      "flags": {"png": "https://flagcdn.com/w320/jp.png"},
      "languages": {"jpn": "Japanese"},
      "currencies": {"JPY": {"name": "Japanese yen", "symbol": "¥"}},
      "region": "Asia",
      "subregion": "Eastern Asia",
      "timezones": ["UTC+09:00"],
      "idd": {"root": "+8", "suffixes": ["1"]},
      "area": 377930,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDefaultCountries();
    _loadAllCountries();

    // Search listener with debouncer
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query == _searchQuery) return;

      _searchQuery = query;
      _debouncer.run(() {
        search(query);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _loadDefaultCountries() {
    setState(() {
      displayCountries = List.from(defaultCountries);
      _autocompleteSuggestions = [];
      isLoading = false;
    });
  }

  Future<void> _loadAllCountries() async {
    setState(() => isLoading = true);
    try {
      final resp = await http.get(Uri.parse(
          'https://restcountries.com/v3.1/all?fields=name,capital,population,flags,languages,currencies,region,subregion,timezones,idd,area'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          allCountries = data;
        });
      }
    } catch (e) {
      // Silent fail
    }
    setState(() => isLoading = false);
  }

  void search(String query) async {
    query = query.trim();
    final lowerQuery = query.toLowerCase();

    if (query.isEmpty) {
      _loadDefaultCountries();
      setState(() => _autocompleteSuggestions = []);
      return;
    }

    // Instant local filtering for suggestions and results
    final localMatches = allCountries.where((c) {
      final name = (c['name']['common'] as String?)?.toLowerCase() ?? '';
      return name.contains(lowerQuery);
    }).toList();

    setState(() {
      _autocompleteSuggestions = localMatches
          .map((c) => c['name']['common'] as String? ?? 'Unknown')
          .toList();
      displayCountries = localMatches;
      isLoading = false;
    });

    // If no local match, fallback to API (partial name search)
    if (localMatches.isEmpty) {
      setState(() => isLoading = true);
      try {
        final resp = await http.get(Uri.parse(
            'https://restcountries.com/v3.1/name/$query?fields=name,capital,population,flags,languages,currencies,region,subregion,timezones,idd,area'));
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          setState(() {
            displayCountries = data is List ? data : [data];
            _autocompleteSuggestions = displayCountries
                .map((c) => c['name']['common'] as String? ?? 'Unknown')
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            displayCountries = [];
            _autocompleteSuggestions = [];
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          displayCountries = [];
          _autocompleteSuggestions = [];
          isLoading = false;
        });
      }
    }
  }

  void _onFavoriteSelected(String? value) {
    if (value == null) return;

    selectedFavorite = value;

    if (value == "Africa" || value == "Asia" || value == "Europe" || value == "America") {
      String continent = value == "America" ? "Americas" : value;
      _showSubregionDialog(continent, _getSubregions(value));
      return;
    }

    // Country favorite
    final lowerValue = value.toLowerCase();
    final country = defaultCountries.firstWhere(
          (c) => (c['name']['common'] as String).toLowerCase() == lowerValue,
      orElse: () => defaultCountries[0],
    );

    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _autocompleteSuggestions = [];
      displayCountries = [country];
      isLoading = false;
    });
  }

  Future<void> _showSubregionDialog(String continent, List<String> subregions) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.blue[50],
        title: Center(
          child: Text(
            "$continent Subregions",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[700]),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose a subregion:", style: TextStyle(fontSize: 17)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[700]!, width: 2),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700], size: 30),
                  hint: Center(child: Text("Select subregion", style: TextStyle(fontSize: 17, color: Colors.blue[700]))),
                  items: subregions.map((sub) {
                    return DropdownMenuItem<String>(
                      value: sub,
                      child: Center(child: Text(sub, style: const TextStyle(fontSize: 17))),
                    );
                  }).toList(),
                  onChanged: (subValue) => Navigator.pop(context, subValue),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(fontSize: 18, color: Colors.red)),
            ),
          ),
        ],
      ),
    );

    if (selected != null) {
      _loadSubregionCountries(selected);
    }
  }

  void _loadSubregionCountries(String subregion) async {
    setState(() => isLoading = true);
    try {
      final resp = await http.get(Uri.parse(
          'https://restcountries.com/v3.1/subregion/$subregion?fields=name,capital,population,flags,languages,currencies,region,subregion,timezones,idd,area'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          displayCountries = data;
          isLoading = false;
        });
      } else {
        setState(() {
          displayCountries = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        displayCountries = [];
        isLoading = false;
      });
    }
  }

  Widget _buildResultsContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (displayCountries.isEmpty) {
      return const Center(
        child: Text(
          "No countries found",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;
        double childAspectRatio = 1.05; // your perfect emulator/phone portrait value

        if (constraints.maxWidth >= 1600) {
          columns = 6;
          childAspectRatio = 0.78; // very wide cards → no tall overflow
        } else if (constraints.maxWidth >= 1200) {
          columns = 5;
          childAspectRatio = 0.80;
        } else if (constraints.maxWidth >= 900) {
          columns = 4;
          childAspectRatio = 0.86;
        } else if (constraints.maxWidth >= 600) {
          columns = 3;
          childAspectRatio = 0.94;
        } else if (constraints.maxWidth >= 480) {
          columns = 2;
          childAspectRatio = 1.02;
        } else {
          columns = 1;
          childAspectRatio = 1.05; // emulator/phone portrait - no extra space
        }

        final grid = GridView.builder(
          shrinkWrap: true, // critical fix: GridView sizes to content only
          physics: const NeverScrollableScrollPhysics(), // no internal scroll = no overflow
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // reduced vertical padding
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: displayCountries.length,
          itemBuilder: (context, i) {
            final country = displayCountries[i];
            return GestureDetector(
              onTap: () => _showCountryDetails(country),
              child: CountryCard(
                country: country,
                index: i,
                hoveredIndex: hoveredIndex,
                onHover: (val) => setState(() => hoveredIndex = val),
                onDetails: _showCountryDetails,
              ),
            );
          },
        );

        // Single country: center + strict constraints (prevents desktop overflow/stretch)
        if (displayCountries.length == 1) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 480),
              child: grid,
            ),
          );
        }

        // Safe wrapper for any overflow risk (small screens or many items)
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 8), // tiny bottom buffer
          child: grid,
        );
      },
    );
  }

  void _showCountryDetails(dynamic country) {
    final name = country['name']['common'] ?? 'Unknown';
    if (name == "Ethiopia") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text("Ethiopian Regions"),
              backgroundColor: Colors.purple[800],
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: ethiopiaRegions.length,
                itemBuilder: (context, i) {
                  final reg = ethiopiaRegions[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    elevation: 3,
                    color: Colors.green[40],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.purple[800],
                        child: Text(
                          (i + 1).toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Region Name — LEFT — Bold & Large
                          Expanded(
                            flex: 2,
                            child: Text(
                              reg["region"]!,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          // "Capital" — MIDDLE — Bold & Large
                          const Text(
                            "Capital",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          // City Name — RIGHT — Bold & Large in Green
                          Expanded(
                            flex: 2,
                            child: Text(
                              reg["capital"]!,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                      onTap: () => _showRegionZones(reg["region"]!),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      return;
    }

    final capital = country['capital']?[0] ?? 'No capital';
    final population = NumberFormat.compact().format(country['population'] ?? 0);
    String languages = "Various languages";
    if (country['languages'] != null) {
      final langMap = country['languages'] as Map<String, dynamic>;
      if (langMap.isNotEmpty) {
        languages = langMap.values.take(3).join(', ');
      }
    }
    String currency = "Unknown";
    if (country['currencies'] != null) {
      final currMap = country['currencies'] as Map<String, dynamic>;
      if (currMap.isNotEmpty) {
        final firstCurr = currMap.values.first as Map<String, dynamic>;
        final symbol = firstCurr['symbol'] ?? '';
        currency = "${firstCurr['name']} $symbol".trim();
      }
    }
    String callingCode = "N/A";
    if (country['idd'] != null) {
      final idd = country['idd'] as Map<String, dynamic>;
      callingCode = "${idd['root'] ?? ''}${idd['suffixes']?[0] ?? ''}";
    }
    final region = country['region'] ?? 'Unknown';
    final subregion = country['subregion'] ?? 'Unknown';
    final timezone = country['timezones']?[0] ?? 'Unknown';
    final area = NumberFormat().format(country['area'] ?? 0);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(country['flags']['png'], width: 80, height: 50, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(Icons.location_city, "Capital", capital),
              _detailRow(Icons.people, "Population", population),
              _detailRow(Icons.language, "Languages", languages),
              _detailRow(Icons.attach_money, "Currency", currency),
              _detailRow(Icons.phone, "Calling Code", callingCode),
              _detailRow(Icons.public, "Region", "$region - $subregion"),
              _detailRow(Icons.access_time, "Timezone", timezone),
              _detailRow(Icons.square_foot, "Area", "$area km²"),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(fontSize: 18, color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRegionZones(String regionName) {
    final zones = ethiopiaZones[regionName] ?? [];
    if (zones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No zone details yet for $regionName")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("$regionName Landmarks"),
            backgroundColor: Colors.purple[800],
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          body: ListView.builder(
            itemCount: zones.length,
            itemBuilder: (context, index) {
              final zone = zones[index];

              return Card(
                margin: const EdgeInsets.all(15),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ZONE NAME
                      Text(
                        zone['name'] ?? 'Unknown Zone',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ZONE DESCRIPTION
                      Text(
                        zone['description'] ?? 'No description available.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 28),
          const SizedBox(width: 12),
          Text("$label:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 18), textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Favorite Dropdown
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.purple, size: 24),
                      hint: const Center(
                        child: Text("Favorites", style: TextStyle(fontSize: 17)),
                      ),
                      value: selectedFavorite,
                      items: favorites.map((item) {
                        return DropdownMenuItem<String>(
                          value: item["name"],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item["type"] == "country")
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    item["flag"],
                                    width: 30,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                const Icon(Icons.public, color: Colors.purple, size: 22),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  item["name"],
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _onFavoriteSelected,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Search Field with Autocomplete
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple, width: 1),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      final query = textEditingValue.text.toLowerCase().trim();
                      return allCountries
                          .map((c) => c['name']['common'] as String? ?? 'Unknown')
                          .where((name) => name.toLowerCase().contains(query))
                          .toList();
                    },
                    onSelected: (String selection) {
                      _searchController.text = selection;
                      search(selection);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Search country...",
                          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8), // ← reduced vertical padding
                          // Thinner and consistent borders (top & bottom same)
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.purple, width: 0.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.purple, width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.purple, width: 1.3), // slightly thicker only when focused
                          ),
                          // Optional: subtle purple shadow/glow on focus
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 1.3),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 350),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple, width: 2),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildResultsContent()),
      ],
    );
  }
}