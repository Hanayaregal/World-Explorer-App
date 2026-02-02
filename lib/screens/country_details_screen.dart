import 'package:flutter/material.dart';
import '../data/default_countries.dart';
//import 'data/default_countries.dart';

class CountryDetailsScreen extends StatelessWidget {
  final Country country;
  const CountryDetailsScreen({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                country.flagUrl,
                width: 180,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 19),
            Text(
              country.name,
              style:
              const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Continent: ${country.continent}",
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              "Population: ${country.population}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
