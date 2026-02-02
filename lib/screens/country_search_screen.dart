import 'package:flutter/material.dart';
import '../data/default_countries.dart';
import '../utils/debouncer.dart';
//import 'data/default_countries.dart';
import 'country_details_screen.dart';
//import 'debouncer_util.dart';

class CountrySearchScreen extends StatefulWidget {
  const CountrySearchScreen({super.key});

  @override
  State<CountrySearchScreen> createState() => _CountrySearchScreenState();
}

class _CountrySearchScreenState extends State<CountrySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  List<Country> _filteredCountries = List.from(defaultCountries);
  String? _selectedContinent;

  void _filterCountries() {
    _debouncer.run(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredCountries = defaultCountries.where((country) {
          final matchesName = country.name.toLowerCase().contains(query);
          final matchesContinent = _selectedContinent == null
              ? true
              : country.continent == _selectedContinent;
          return matchesName && matchesContinent;
        }).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search countries...",
              prefixIcon: const Icon(Icons.search),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedContinent,
            hint: const Text("Filter by continent"),
            items: [
              "Africa",
              "Americas",
              "Asia",
              "Europe",
              "Oceania"
            ].map((continent) {
              return DropdownMenuItem(
                value: continent,
                child: Text(continent),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedContinent = value;
                _filterCountries();
              });
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3 / 4),
            itemCount: _filteredCountries.length,
            itemBuilder: (context, index) {
              final country = _filteredCountries[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CountryDetailsScreen(country: country),
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            country.flagUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              country.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text("Population: ${country.population}"),
                            Text("Continent: ${country.continent}"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
