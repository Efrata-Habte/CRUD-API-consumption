import 'dart:convert';

import 'package:crud_api_consumption_http/models/country.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _allUrl =
      'https://restcountries.com/v3.1/all?fields=name,capital,currencies';
  static const String _nameUrl = 'https://restcountries.com/v3.1/name/';

  static Future<List<Country>> getCountries() async {
    final response = await http.get(Uri.parse(_allUrl));
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Country.fromJson(e)).toList();
    }
    throw Exception('Failed to load countries (${response.statusCode})');
  }

  static Future<Country> getCountry(String name) async {
    final uri = Uri.parse(
      '$_nameUrl${Uri.encodeComponent(name)}?fields=name,capital,currencies',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return Country.fromJson(json.first);
    }
    throw Exception('Country "$name" not found (${response.statusCode})');
  }

  static Future<void> postCountry(Country country) async {
    try {
      await http.post(
        Uri.parse(_allUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(country.toJson()),
      );
    } catch (_) {}
  }

  static Future<void> patchCountry(
    String oldName,
    Map<String, dynamic> patchBody,
  ) async {
    try {
      await http.patch(
        Uri.parse('$_nameUrl${Uri.encodeComponent(oldName)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(patchBody),
      );
    } catch (_) {}
  }

  static Future<void> deleteCountry(String name) async {
    try {
      await http.delete(
        Uri.parse('$_nameUrl${Uri.encodeComponent(name)}'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (_) {}
  }

  static Map<String, dynamic> diffJson(
    Map<String, dynamic> oldMap,
    Map<String, dynamic> newMap,
  ) {
    final diff = <String, dynamic>{};
    newMap.forEach((key, newValue) {
      final oldValue = oldMap[key];
      if (newValue is Map<String, dynamic> && oldValue is Map<String, dynamic>) {
        final nested = diffJson(oldValue, newValue);
        if (nested.isNotEmpty) diff[key] = nested;
      } else if (jsonEncode(newValue) != jsonEncode(oldValue)) {
        diff[key] = newValue;
      }
    });
    return diff;
  }

  static Map<String, dynamic> deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> overrides,
  ) {
    final result = Map<String, dynamic>.from(base);
    overrides.forEach((key, value) {
      if (value is Map<String, dynamic> && result[key] is Map<String, dynamic>) {
        result[key] = deepMerge(result[key] as Map<String, dynamic>, value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}