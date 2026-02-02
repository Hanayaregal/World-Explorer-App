import 'package:flutter/material.dart';
class SimpleSearchWithSuggestion extends StatefulWidget {
  const SimpleSearchWithSuggestion({super.key});

  @override
  State<SimpleSearchWithSuggestion> createState() => _SimpleSearchWithSuggestionState();
}

class _SimpleSearchWithSuggestionState extends State<SimpleSearchWithSuggestion> {
  // Your list of data (can be countries, regions, capitals, anything)
  final List<String> allItems = [
    "Ethiopia",
    "Egypt",
    "Ecuador",
    "Estonia",
    "El Salvador",
    "Equatorial Guinea",
    "Eritrea",
    "Addis Ababa",
    "Amhara",
    "Oromia",
    "Tigray",
    "Lalibela",
    "Axum",
    "Gondar",
    "India",
    "Japan",
  ];

  String query = '';
  List<String> suggestions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Search country, region, city...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              query = value.trim().toLowerCase();
              if (query.isEmpty) {
                suggestions = [];
              } else {
                suggestions = allItems.where((item) {
                  return item.toLowerCase().contains(query);
                }).toList();
              }
            });
          },
        ),

        const SizedBox(height: 4),

        // Dropdown suggestions
        if (suggestions.isNotEmpty)
          Container(
            constraints: BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                )
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final item = suggestions[index];
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    // When user selects
                    setState(() {
                      query = '';
                      suggestions = [];
                    });
                    print("Selected: $item");
                    // Here you can: fill text field, filter cards, show details, etc.
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}