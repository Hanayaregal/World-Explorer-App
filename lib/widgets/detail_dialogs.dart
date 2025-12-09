import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/regions_data.dart';

void showNormalCountryDetails(BuildContext context, dynamic country) {
  final name = country['name']['common'] ?? '';
  final officialName = country['name']['official'] ?? '';
  final capital = country['capital']?.isNotEmpty == true ? country['capital'].join(', ') : 'N/A';
  final population = NumberFormat('#,##0').format(country['population'] ?? 0);
  final languages = country['languages'] != null ? (country['languages'] as Map).values.join(', ') : 'N/A';
  final region = country['region'] ?? 'N/A';
  final subregion = country['subregion'] ?? 'N/A';
  final area = country['area'] != null ? '${country['area']} km²' : 'N/A';
  final flag = country['flags']?['png'];
  final currencies = country['currencies'] != null
      ? (country['currencies'] as Map).entries.map((e) => '${e.value['name']} (${e.value['symbol'] ?? ''})').join(', ')
      : 'N/A';
  final timezones = country['timezones']?.join(', ') ?? 'N/A';
  final callingCode = country['idd'] != null
      ? '${country['idd']['root'] ?? ''}${country['idd']['suffixes']?.join('') ?? ''}'
      : 'N/A';

  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (flag != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        flag,
                        width: 90,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 90,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.flag, size: 30),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text(officialName, style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ...[
                _detailRow(Icons.location_city, 'Capital', capital),
                _detailRow(Icons.people, 'Population', population),
                _detailRow(Icons.language, 'Languages', languages),
                _detailRow(Icons.phone, 'Calling Code', callingCode),
                _detailRow(Icons.attach_money, 'Currencies', currencies),
                _detailRow(Icons.public, 'Region', region),
                _detailRow(Icons.location_on, 'Subregion', subregion),
                _detailRow(Icons.square_foot, 'Area', area),
                _detailRow(Icons.access_time, 'Timezones', timezones),
              ],

              const SizedBox(height: 20),

              SizedBox(
                width: 140,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 10),
                  label: const Text("Close", style: TextStyle(fontSize: 17)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 8,
                    shadowColor: Colors.blue.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showCountryWithRegions(BuildContext context, dynamic country) {
  final name = country['name']['common'] ?? '';
  final isEthiopia = name == 'Ethiopia';
  final Color primaryColor = isEthiopia ? Colors.green : Colors.blue;

  final officialName = country['name']['official'] ?? '';
  final capital = country['capital']?.isNotEmpty == true ? country['capital'].join(', ') : 'N/A';
  final population = NumberFormat('#,##0').format(country['population'] ?? 0);
  final languages = country['languages'] != null ? (country['languages'] as Map).values.join(', ') : 'N/A';
  final region = country['region'] ?? 'N/A';
  final subregion = country['subregion'] ?? 'N/A';
  final area = country['area'] != null ? '${country['area']} km²' : 'N/A';
  final flag = country['flags']?['png'];
  final currencies = country['currencies'] != null
      ? (country['currencies'] as Map).entries.map((e) => '${e.value['name']} (${e.value['symbol'] ?? ''})').join(', ')
      : 'N/A';
  final timezones = country['timezones']?.join(', ') ?? 'N/A';
  final callingCode = country['idd'] != null
      ? '${country['idd']['root'] ?? ''}${country['idd']['suffixes']?.join('') ?? ''}'
      : 'N/A';

  final regions = isEthiopia ? ethiopianRegions : countryRegions[name] ?? {};

  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (flag != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(flag, width: 90, height: 60, fit: BoxFit.cover),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                        Text(officialName, style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ...[
                _detailRow(Icons.account_balance, 'Capital', capital),
                _detailRow(Icons.people, 'Population', population),
                _detailRow(Icons.language, 'Languages', languages),
                _detailRow(Icons.phone, 'Calling Code', callingCode),
                _detailRow(Icons.attach_money, 'Currencies', currencies),
                _detailRow(Icons.public, 'Region', region),
                _detailRow(Icons.location_on, 'Subregion', subregion),
                _detailRow(Icons.square_foot, 'Area', area),
                _detailRow(Icons.access_time, 'Timezones', timezones),
              ],

              if (regions.isNotEmpty) _regionsSection(regions, name, primaryColor),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEthiopia ? Colors.green.shade700 : Colors.blue.shade700, // ← CORRECT!
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Close", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
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
        Icon(icon, size: 26, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _regionsSection(Map<String, List<String>> regions, String countryName, Color color) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color == Colors.green ? Colors.green.shade50 : Colors.blue.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color == Colors.green ? Colors.green.shade200 : Colors.blue.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const SizedBox(width: 10),
          Text("$countryName Regions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ]),
        const SizedBox(height: 12),
        ...regions.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ${e.key}: ", style: TextStyle(fontWeight: FontWeight.w600, color: color == Colors.green ? Colors.green.shade800 : Colors.blue.shade800)),
              Expanded(child: Text(e.value.join(", "))),
            ],
          ),
        )),
      ],
    ),
  );
}