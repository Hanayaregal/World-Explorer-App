final List<String> continents = ["Africa", "Americas", "Asia", "Europe", "Oceania"];

final List<String> africanSubregions = [
  "Eastern Africa",
  "Western Africa",
  "Northern Africa",
  "Southern Africa",
  "Middle Africa"
];

final List<String> favoriteContinents = ["Africa", "Asia", "Europe", "Oceania"];
final List<String> favoriteCountries = ["Ethiopia", "India", "China", "Mexico"];

List<String> get dropdownFavorites => [...favoriteContinents, ...favoriteCountries, ...africanSubregions];