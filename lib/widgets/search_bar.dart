import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  // Data (not const because we may add dynamic items later)
  static const List<String> favorites = [
    "Ethiopia",
    "Japan",
    "Brazil",
    "Germany",
    "Nigeria",
    "India",
    "France",
    "United States",
  ];

  static const List<String> continents = [
    "Africa",
    "Asia",
    "Europe",
    "Americas",
  ];

  static const List<String> africanSubregions = [
    "Eastern Africa",
    "Western Africa",
    "Northern Africa",
    "Central Africa",
    "Southern Africa",
  ];

  @override
  Widget build(BuildContext context) {
    final suggestions = [...favorites, ...continents, ...africanSubregions];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[700],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // fixed deprecated withAlpha
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return isSmallScreen
              ? _buildMobileLayout(suggestions)
              : _buildDesktopLayout(suggestions);
        },
      ),
    );
  }

  Widget _buildMobileLayout(List<String> suggestions) {
    return Column(
      children: [
        // Search field with clear button
        TextField(
          controller: controller,
          onSubmitted: onSearch,
          decoration: InputDecoration(
            hintText: "Search country or continent...",
            prefixIcon: const Icon(Icons.search, color: Colors.purple),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                controller.clear();
                onSearch('');
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          ),
        ),
        const SizedBox(height: 16),

        // Quick select dropdown + search button
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _quickDropdown(),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => onSearch(controller.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Search",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(List<String> suggestions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            onSubmitted: onSearch,
            decoration: InputDecoration(
              hintText: "Search country or continent...",
              prefixIcon: const Icon(Icons.search, color: Colors.purple),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  controller.clear();
                  onSearch('');
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => onSearch(controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.purple[700],
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            "Search",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 280,
          child: _quickDropdown(),
        ),
      ],
    );
  }

  Widget _quickDropdown() {
    return DropdownButtonFormField<String>(
      value: null,
      hint: const Text("Quick Select"),
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text("All Countries")),
        ...continents.map((continent) => DropdownMenuItem(
          value: continent,
          child: Row(
            children: [
              const Icon(Icons.public, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(continent),
            ],
          ),
        )),
        ...favorites.map((country) => DropdownMenuItem(
          value: country,
          child: Row(
            children: [
              const Icon(Icons.flag, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(country),
            ],
          ),
        )),
        ...africanSubregions.map((sub) => DropdownMenuItem(
          value: sub,
          child: Row(
            children: [
              const Icon(Icons.map, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(sub),
            ],
          ),
        )),
      ],
      onChanged: (value) {
        if (value != null) {
          onSearch(value);
        }
      },
    );
  }
}