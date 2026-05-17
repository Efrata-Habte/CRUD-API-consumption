import 'dart:convert';

import 'package:crud_api_consumption_http/models/country.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static const String baseUrl =
      'https://restcountries.com/v3.1/all?fields=name,capital,currencies';

  static const String countryUrl =
      'https://restcountries.com/v3.1/name/';

  // local simulated database
  static List<Country> countriesStore = [];

  // READ ALL
  static Future<List<Country>> getCountries() async {
    final response = await http.get(
      Uri.parse(baseUrl),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          jsonDecode(response.body);

      final countries = jsonData
          .map((e) => Country.fromJson(e))
          .toList();

      // save locally
      countriesStore = countries;

      return countries;
    } else {
      throw Exception(
        'Failed to load countries',
      );
    }
  }

  // READ SINGLE
  static Future<Country> getCountry(
    String name,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$countryUrl$name?fields=name,capital,currencies',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          jsonDecode(response.body);

      return Country.fromJson(
        jsonData.first,
      );
    } else {
      throw Exception(
        'Failed to load country',
      );
    }
  }

  // CREATE
  static Future<Country> createCountry(
    Country country,
  ) async {
    // Fire the POST request; silently ignore any API error (read-only API)
    try {
      await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(country.toJson()),
      );
    } catch (_) {}

    // Always add to the local store regardless of API response
    countriesStore.insert(0, country);

    return country;
  }

  // UPDATE
  static Future<Country> updateCountry(
    String oldCountryName,
    Country updatedCountry,
  ) async {
    final index = countriesStore.indexWhere(
      (country) =>
          country.name.common.toLowerCase() ==
          oldCountryName.toLowerCase(),
    );

    if (index == -1) {
      throw Exception(
        'Country "$oldCountryName" not found',
      );
    }

    final oldJson = countriesStore[index].toJson();
    final newJson = updatedCountry.toJson();

    final patchBody = _diffJson(oldJson, newJson);

    try {
      await http.patch(
        Uri.parse('$countryUrl${Uri.encodeComponent(oldCountryName)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(patchBody),
      );
    } catch (_) {}

    final mergedJson = _deepMerge(oldJson, patchBody);
    final mergedCountry = Country.fromJson(mergedJson);
    countriesStore[index] = mergedCountry;

    return mergedCountry;
  }

  // DELETE
  static Future<String> deleteCountry(
    String countryName,
  ) async {
    final index = countriesStore.indexWhere(
      (country) =>
          country.name.common.toLowerCase() ==
          countryName.toLowerCase(),
    );

    if (index == -1) {
      throw Exception(
        'Country "$countryName" not found',
      );
    }

    // Fire the DELETE request; silently ignore any API error (read-only API)
    try {
      await http.delete(
        Uri.parse('$countryUrl${Uri.encodeComponent(countryName)}'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (_) {}

    final deleted = countriesStore.removeAt(index);

    return deleted.name.common;
  }


  /// Returns a map containing only the keys whose values differ between
  /// [oldMap] and [newMap]. Nested maps are diffed recursively.
  static Map<String, dynamic> _diffJson(
    Map<String, dynamic> oldMap,
    Map<String, dynamic> newMap,
  ) {
    final diff = <String, dynamic>{};

    newMap.forEach((key, newValue) {
      final oldValue = oldMap[key];

      if (newValue is Map<String, dynamic> &&
          oldValue is Map<String, dynamic>) {
        // Recurse into nested objects
        final nestedDiff = _diffJson(oldValue, newValue);
        if (nestedDiff.isNotEmpty) diff[key] = nestedDiff;
      } else if (jsonEncode(newValue) != jsonEncode(oldValue)) {
        // Primitive or list that changed
        diff[key] = newValue;
      }
    });

    return diff;
  }

  /// Deep-merges [overrides] on top of [base].
  /// Nested maps are merged recursively; other values are replaced.
  static Map<String, dynamic> _deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> overrides,
  ) {
    final result = Map<String, dynamic>.from(base);

    overrides.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          result[key] is Map<String, dynamic>) {
        result[key] = _deepMerge(
          result[key] as Map<String, dynamic>,
          value,
        );
      } else {
        result[key] = value;
      }
    });

    return result;
  }
}