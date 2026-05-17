import 'package:crud_api_consumption_http/models/country.dart';
import 'package:crud_api_consumption_http/models/currency.dart';
import 'package:crud_api_consumption_http/models/name.dart';
import 'package:crud_api_consumption_http/models/native_name.dart';
import 'package:crud_api_consumption_http/services/api_service.dart';
import 'package:flutter/foundation.dart';

class CountryProvider extends ChangeNotifier {
  List<Country> _countries = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _visibleCount = 10;

  List<Country> get countries => List.unmodifiable(_countries);
  List<Country> get visibleCountries => _countries.take(_visibleCount).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _visibleCount < _countries.length;
  bool get canShowLess => _visibleCount > 10;
  int get totalCount => _countries.length;
  int get visibleCount => _visibleCount;

  void loadMore() {
    _visibleCount = (_visibleCount + 10).clamp(10, _countries.length);
    notifyListeners();
  }

  void showLess() {
    _visibleCount = 10;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadCountries() async {
    _setLoading(true);
    _setError(null);
    _visibleCount = 10;
    try {
      _countries = await ApiService.getCountries();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Country?> createCountry({
    required String commonName,
    required String officialName,
    required String nativeLangCode,
    required String nativeOfficial,
    required String nativeCommon,
    required String currencyCode,
    required String currencyName,
    required String currencySymbol,
    required String capital,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final country = Country(
        name: Name(
          common: commonName,
          official: officialName,
          nativeName: nativeLangCode.isNotEmpty
              ? {
                  nativeLangCode: NativeName(
                    official: nativeOfficial,
                    common: nativeCommon,
                  ),
                }
              : {},
        ),
        currency: currencyCode.isNotEmpty
            ? {
                currencyCode: Currency(
                  name: currencyName,
                  symbol: currencySymbol,
                ),
              }
            : {},
        capitals: capital.isNotEmpty ? [capital] : [],
      );

      await ApiService.postCountry(country);
      _countries.insert(0, country);
      notifyListeners();
      return country;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Country?> updateCountry({
    required String oldCommonName,
    required String commonName,
    required String officialName,
    required String nativeLangCode,
    required String nativeOfficial,
    required String nativeCommon,
    required String currencyCode,
    required String currencyName,
    required String currencySymbol,
    required String capital,
  }) async {
    final index = _countries.indexWhere(
      (c) => c.name.common.toLowerCase() == oldCommonName.toLowerCase(),
    );

    if (index == -1) {
      _setError('Country "$oldCommonName" not found.');
      return null;
    }

    _setLoading(true);
    _setError(null);
    try {
      final updatedCountry = Country(
        name: Name(
          common: commonName,
          official: officialName,
          nativeName: nativeLangCode.isNotEmpty
              ? {
                  nativeLangCode: NativeName(
                    official: nativeOfficial,
                    common: nativeCommon,
                  ),
                }
              : {},
        ),
        currency: currencyCode.isNotEmpty
            ? {
                currencyCode: Currency(
                  name: currencyName,
                  symbol: currencySymbol,
                ),
              }
            : {},
        capitals: capital.isNotEmpty ? [capital] : [],
      );

      final oldJson = _countries[index].toJson();
      final newJson = updatedCountry.toJson();
      final patchBody = ApiService.diffJson(oldJson, newJson);

      await ApiService.patchCountry(oldCommonName, patchBody);

      final mergedJson = ApiService.deepMerge(oldJson, patchBody);
      final mergedCountry = Country.fromJson(mergedJson);
      _countries[index] = mergedCountry;
      notifyListeners();
      return mergedCountry;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> deleteCountry(String commonName) async {
    final index = _countries.indexWhere(
      (c) => c.name.common.toLowerCase() == commonName.toLowerCase(),
    );

    if (index == -1) {
      _setError('Country "$commonName" not found.');
      return null;
    }

    _setLoading(true);
    _setError(null);
    try {
      await ApiService.deleteCountry(commonName);
      final deleted = _countries.removeAt(index);
      notifyListeners();
      return deleted.name.common;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
