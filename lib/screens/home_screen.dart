import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:world_explorer/screens/profile_screen.dart';
import 'package:world_explorer/screens/quizzes_screen.dart';
import '../data/ethiopia_data.dart';
import '../data/favorites.dart';
import '../widgets/country_card.dart';
import 'analytics_screen.dart';
import 'package:world_explorer/data/default_countries.dart';

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
  List<dynamic> _autocompleteSuggestions = []; // Changed to List<dynamic>
  bool isLoading = false;
  bool _isSearching = false;
  bool _showSuggestions = false;
  int? hoveredIndex;
  String? selectedFavorite;
  OverlayEntry? _suggestionsOverlay;
  final FocusNode _searchFocusNode = FocusNode(); // NEW: Focus node for search field

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

  @override
  void initState() {
    super.initState();
    _loadDefaultCountries();
    _loadAllCountries();

    _searchController.addListener(() {
      final query = _searchController.text.trim();

      setState(() {
        _isSearching = query.isNotEmpty;
        _showSuggestions = query.isNotEmpty && _searchFocusNode.hasFocus;
      });

      if (query == _searchQuery) return;

      _searchQuery = query;
      _debouncer.run(() {
        _updateAutocompleteSuggestions(query);
      });
    });

    // Handle focus changes
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchController.text.isNotEmpty &&
            _autocompleteSuggestions.isNotEmpty &&
            _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    _searchFocusNode.dispose();
    _removeSuggestionsOverlay();
    super.dispose();
  }

  void _loadDefaultCountries() {
    setState(() {
      displayCountries = List.from(defaultCountries);
      _autocompleteSuggestions = [];
      isLoading = false;
      _isSearching = false;
      _showSuggestions = false;
    });
  }

  Future<void> _loadAllCountries() async {
    setState(() => isLoading = true);
    try {
      final resp = await http.get(Uri.parse(
          'https://restcountries.com/v3.1/all?fields=name,capital,population,flags,languages,currencies,region,subregion,timezones,idd,area'
      ));

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

  // NEW: Function to update autocomplete suggestions only
  void _updateAutocompleteSuggestions(String query) async {
    query = query.trim();
    final lowerQuery = query.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _autocompleteSuggestions = [];
      });
      _removeSuggestionsOverlay();
      return;
    }

    // Local filtering...
    final localMatches = allCountries.where((c) {
      final name = (c['name']['common'] as String?)?.toLowerCase() ?? '';
      final officialName = (c['name']['official'] as String?)?.toLowerCase() ?? '';
      return name.contains(lowerQuery) || officialName.contains(lowerQuery) || name.startsWith(lowerQuery);
    }).toList();

    final suggestions = localMatches.take(5).toList();

    setState(() {
      _autocompleteSuggestions = suggestions;
    });

    // Show overlay after state update
    if (suggestions.isNotEmpty && _searchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuggestionsOverlay();
      });
    } else {
      _removeSuggestionsOverlay();
    }

    // API fallback for more results (if local is not enough)
    try {
      final resp = await http.get(
        Uri.parse(
          'https://restcountries.com/v3.1/name/$query?fields=name,capital,population,flags,languages,currencies,region,subregion,timezones,idd,area',
        ),
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final List<dynamic> apiResults = data is List ? data : [data];

        // Merge local + API results and remove duplicates
        final allResults = [...localMatches, ...apiResults];
        final seen = <String>{};
        final uniqueResults = allResults.where((country) {
          final name = country['name']['common'] as String? ?? '';
          return name.isNotEmpty && seen.add(name);
        }).take(5).toList();

        // Update state with final unique list
        setState(() {
          _autocompleteSuggestions = uniqueResults;
        });

        // Show/hide overlay based on final list
        if (uniqueResults.isNotEmpty && _searchFocusNode.hasFocus) {
          _showSuggestionsOverlay();
        } else {
          _removeSuggestionsOverlay();
        }
      }
    } catch (e) {
      // Silent fail - keep local suggestions
      print("API error in autocomplete: $e");
    }
  }

  void search(String query) async {
    query = query.trim();

    if (query.isEmpty) {
      _loadDefaultCountries();
      return;
    }

    setState(() {
      isLoading = true;
      _showSuggestions = false; // Hide suggestions when performing full search
    });

    try {
      final resp = await http.get(Uri.parse(
          'https://restcountries.com/v3.1/name/$query?fields=name,capital,population,flags,languages,currencies,region,subregion,timezones,idd,area'
      ));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final List<dynamic> results = data is List ? data : [data];

        setState(() {
          displayCountries = results;
          isLoading = false;
        });
      } else {
        // Fallback to local search
        final localMatches = allCountries.where((c) {
          final name = (c['name']['common'] as String?)?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();

        setState(() {
          displayCountries = localMatches;
          isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to local search
      final localMatches = allCountries.where((c) {
        final name = (c['name']['common'] as String?)?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();

      setState(() {
        displayCountries = localMatches;
        isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _loadDefaultCountries();
    setState(() {
      _autocompleteSuggestions = [];
      _isSearching = false;
      _showSuggestions = false;
    });
  }

  void _handleSuggestionSelected(dynamic country) {
    final countryName = country['name']['common'] as String? ?? '';
    _searchController.text = countryName;
    search(countryName);
    setState(() {
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus(); // Unfocus after selection
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
          childAspectRatio = 1.09;
        } else {
          columns = 1;
          childAspectRatio = 1.10; // emulator/phone portrait - no extra space
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

  void _showSuggestionsOverlay() {
    _removeSuggestionsOverlay();

    // Get the search field's position and size
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _suggestionsOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + 45,           // Below the search field
        left: position.dx + 16,          // Align with padding
        width: size.width - 32,          // Exact width of search field (minus padding)
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _autocompleteSuggestions.length,
              itemBuilder: (context, index) {
                final country = _autocompleteSuggestions[index];
                final name = country['name']['common'] as String? ?? 'Unknown';

                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(name, style: const TextStyle(fontSize: 15)),
                  onTap: () {
                    // Fill the field and trigger search
                    _searchController.text = name;
                    search(name);

                    // Hide overlay and suggestions immediately
                    _removeSuggestionsOverlay();

                    // Clear suggestions list
                    setState(() {
                      _autocompleteSuggestions = [];
                    });

                    // Unfocus keyboard
                    _searchFocusNode.unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_suggestionsOverlay!);
  }

  void _removeSuggestionsOverlay() {
    if (_suggestionsOverlay != null) {
      _suggestionsOverlay!.remove();
      _suggestionsOverlay = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & Favorites Row
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Favorites Dropdown – fixed
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple, width: 1),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.purple, size: 24),
                      hint: const Center(child: Text("Favorites", style: TextStyle(fontSize: 17))),
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

              // Search Field – simple TextField
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Search field (unchanged)
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.purple, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Search country...",
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: Colors.purple, size: 22),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearSearch,
                            color: Colors.purple,
                          )
                              : null,
                        ),
                        onChanged: (value) {
                          _updateAutocompleteSuggestions(value);
                        },
                        onSubmitted: (value) {
                          search(value.trim());
                          _removeSuggestionsOverlay();
                          _searchFocusNode.unfocus();
                        },
                      ),
                    ),

                    // Autocomplete dropdown — forced to be EXACTLY same width as search field
                    if (_showSuggestions && _autocompleteSuggestions.isNotEmpty)
                      Positioned(
                        top: 45,
                        left: 0,
                        right: 0,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(30),
                          clipBehavior: Clip.hardEdge, // prevents any visual overflow
                          child: Container(
                            width: double.infinity, // ← this forces exact same width as parent (search field)
                            constraints: const BoxConstraints(maxHeight: 240),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.purple, width: 2),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: _autocompleteSuggestions.length,
                              itemBuilder: (context, index) {
                                final country = _autocompleteSuggestions[index];
                                final name = country['name']['common'] as String? ?? 'Unknown';

                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  title: Text(
                                    name,
                                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                  onTap: () {
                                    _searchController.text = name;
                                    search(name);
                                    _removeSuggestionsOverlay();
                                    setState(() {
                                      _showSuggestions = false;
                                      _autocompleteSuggestions = [];
                                    });
                                    _searchFocusNode.unfocus();
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),


        // Loading indicator
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(color: Colors.purple),
          ),

        // Results grid
        Expanded(child: _buildResultsContent()),
      ],
    );
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
}