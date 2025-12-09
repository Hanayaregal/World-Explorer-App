import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CountryCard extends StatelessWidget {
  final dynamic country;
  final int index;
  final int? hoveredIndex;
  final Function(int) onHover;
  final Function(dynamic) onDetails;

  const CountryCard({
    super.key,
    required this.country,
    required this.index,
    required this.hoveredIndex,
    required this.onHover,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final name = country['name']['common'] ?? 'Unknown';
    final capital = country['capital']?.isNotEmpty == true
        ? country['capital'][0]
        : 'No capital';
    final population = NumberFormat.compact().format(country['population'] ?? 0);
    final languages = country['languages'] != null
        ? (country['languages'] as Map).values.take(3).join(', ')
        : 'Not specified';
    final flagUrl = country['flags']?['png'];

    return MouseRegion(
      onEnter: (_) => onHover(index),
      onExit: (_) => onHover(-1),
      child: GestureDetector(
        onTap: () => onDetails(country),
        child: Card(
          elevation: hoveredIndex == index ? 20 : 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hoveredIndex == index ? Colors.blue[50] : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.blue[100]!, width: hoveredIndex == index ? 3 : 1),
            ),
            child: Column(
              children: [
                // FLAG — BEAUTIFUL
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    flagUrl ?? '',
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 110,
                      color: Colors.grey[300],
                      child: const Icon(Icons.flag, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // COUNTRY NAME — BIG & BOLD
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // DETAILS — PERFECTLY CENTERED, VALUES NOT BOLD
                Text(
                  "Capital: $capital",
                  style: const TextStyle(fontSize: 17, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Population: $population",
                  style: const TextStyle(fontSize: 17, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Language: $languages",
                    style: const TextStyle(fontSize: 17, color: Colors.black87),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}