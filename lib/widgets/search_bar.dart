import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SearchBarWidget({super.key, required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final suggestions = [...dropdownFavorites, ...continents, ...africanSubregions];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmall = constraints.maxWidth < 600;

          if (isSmall) {
            return _buildMobileLayout(suggestions);
          }
          return _buildDesktopLayout(suggestions);
        },
      ),
    );
  }

  Widget _buildMobileLayout(List<String> suggestions) {
    return Column(
      children: [
        Autocomplete<String>(
          optionsBuilder: (text) => text.text.isEmpty ? [] : suggestions.where((s) => s.toLowerCase().contains(text.text.toLowerCase())),
          onSelected: onSearch,
          fieldViewBuilder: (_, controller, focusNode, __) => TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: onSearch,
            decoration: InputDecoration(
              hintText: "Search country, continent or African region...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: ElevatedButton(onPressed: () => onSearch(controller.text), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue[700], padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold)))),
            const SizedBox(width: 12),
            Expanded(child: _quickDropdown()),
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
          width: 350,
          child: Autocomplete<String>(
            optionsBuilder: (v) => v.text.isEmpty ? [] : suggestions.where((s) => s.toLowerCase().contains(v.text.toLowerCase())),
            onSelected: onSearch,
            fieldViewBuilder: (_, c, f, __) => TextField(
              controller: c,
              focusNode: f,
              onSubmitted: onSearch,
              decoration: InputDecoration(
                hintText: "Search country, continent or African region...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => onSearch(controller.text),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue[700], padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18)),
          child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 250, child: _quickDropdown()),
      ],
    );
  }

  Widget _quickDropdown() {
    return DropdownButtonFormField<String>(
      hint: const Text("Quick Select"),
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text("All Countries")),
        ...favoriteContinents.map((e) => DropdownMenuItem(value: e, child: Text("🌍 $e"))),
        ...favoriteCountries.map((e) => DropdownMenuItem(value: e, child: Text("🇺🇳 $e"))),
        ...africanSubregions.map((e) => DropdownMenuItem(value: e, child: Text("📍 $e"))),
      ],
      onChanged: (v) => v != null ? onSearch(v) : null,
    );
  }
}