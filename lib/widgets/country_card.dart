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
    final capital = country['capital']?.isNotEmpty == true ? country['capital'][0] : 'No capital';
    final population = NumberFormat.compact().format(country['population'] ?? 0);
    final languages = country['languages'] != null
        ? (country['languages'] as Map).values.take(3).join(', ')
        : 'Various';
    final flagUrl = country['flags']?['png'];

    return MouseRegion(
      onEnter: (_) => onHover(index),
      onExit: (_) => onHover(-1),
      child: GestureDetector(
        onTap: () => onDetails(country),
        child:
        Card(
          elevation: hoveredIndex == index ? 6 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: hoveredIndex == index ? Colors.blue[50] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hoveredIndex == index ? Colors.blue[400]! : Colors.blue[100]!,
                width: hoveredIndex == index ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: hoveredIndex == index ? 10 : 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Flag
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 90,
                    width: 150,
                    child: Image.network(
                      flagUrl ?? '',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.flag, size: 28, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Country Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Details
                _detailText("Capital:", capital),
                const SizedBox(height: 3),
                _detailText("Population:", population),
                const SizedBox(height: 3),
                _detailText("Language:", languages),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailText(String label, String value) {
    final fullText = "$label $value";

    // Check if this detail is long enough to need scrolling
    final isLong = value.length > 35 || value.split(',').length > 4 || value.contains(' ' * 20);

    if (isLong) {
      return SizedBox(
        height: 50, // Small scrollable area (adjust 45–60px as you like)
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Horizontal scroll for long names
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              fullText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Normal short detail — no scroll
    return Text(
      fullText,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}