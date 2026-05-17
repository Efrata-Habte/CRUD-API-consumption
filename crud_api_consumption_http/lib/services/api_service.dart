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
    // Send the POST request with the full country payload
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(country.toJson()),
    );

    // Simulate successful creation in the local store
    countriesStore.add(country);

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

    // Send the PATCH request with the updated country payload
    await http.patch(
      Uri.parse('$countryUrl${Uri.encodeComponent(oldCountryName)}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedCountry.toJson()),
    );

    // Simulate successful update in the local store
    countriesStore[index] = updatedCountry;

    return updatedCountry;
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

    // Send the DELETE request
    await http.delete(
      Uri.parse('$countryUrl${Uri.encodeComponent(countryName)}'),
      headers: {'Content-Type': 'application/json'},
    );

    // Simulate successful deletion in the local store
    final deleted = countriesStore.removeAt(index);

    return deleted.name.common;
  }
}