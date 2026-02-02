// data/default_countries.dart

class Country {
  final String name;
  final String continent;
  final int population;
  final String flagUrl;

  Country({
    required this.name,
    required this.continent,
    required this.population,
    required this.flagUrl,
  });
}

// Example default countries
final List<Country> defaultCountries = [
  Country(
      name: "Ethiopia",
      continent: "Africa",
      population: 123000000,
      flagUrl: "https://flagcdn.com/w320/et.png"),
  Country(
      name: "United States",
      continent: "Americas",
      population: 331000000,
      flagUrl: "https://flagcdn.com/w320/us.png"),
  Country(
      name: "India",
      continent: "Asia",
      population: 1380000000,
      flagUrl: "https://flagcdn.com/w320/in.png"),
  Country(
      name: "Germany",
      continent: "Europe",
      population: 83000000,
      flagUrl: "https://flagcdn.com/w320/de.png"),
  Country(
      name: "Australia",
      continent: "Oceania",
      population: 25000000,
      flagUrl: "https://flagcdn.com/w320/au.png"),
];
