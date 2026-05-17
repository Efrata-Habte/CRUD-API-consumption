import 'package:crud_api_consumption_http/models/country.dart';
import 'package:crud_api_consumption_http/screens/country_form_screen.dart';
import 'package:crud_api_consumption_http/services/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Country> _countries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  // READ ALL
  Future<void> _loadCountries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final countries = await ApiServices.getCountries();
      setState(() => _countries = countries);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // DELETE
  Future<void> _deleteCountry(String commonName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$commonName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final deletedName = await ApiServices.deleteCountry(commonName);

      setState(() {
        _countries = List.from(ApiServices.countriesStore);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$deletedName" was deleted successfully.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Navigate to Create form
  Future<void> _openCreateForm() async {
    final created = await Navigator.push<Country>(
      context,
      MaterialPageRoute(
        builder: (_) => const CountryFormScreen(mode: FormMode.create),
      ),
    );

    if (created != null) {
      setState(() => _countries = List.from(ApiServices.countriesStore));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${created.name.common}" was created successfully.'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }

  // Navigate to Update form
  Future<void> _openUpdateForm(Country country) async {
    final updated = await Navigator.push<Country>(
      context,
      MaterialPageRoute(
        builder: (_) => CountryFormScreen(
          mode: FormMode.update,
          existingCountry: country,
        ),
      ),
    );

    if (updated != null) {
      setState(() => _countries = List.from(ApiServices.countriesStore));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${updated.name.common}" was updated successfully.'),
            backgroundColor: Colors.blue.shade600,
          ),
        );
      }
    }
  }

  // Build helpers
  Widget _buildCountryCard(Country country) {
    final currencyEntries = country.currency.entries.toList();
    final currencyText = currencyEntries.isEmpty
        ? 'N/A'
        : currencyEntries
            .map((e) => '${e.key}: ${e.value.name} (${e.value.symbol})')
            .join(', ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    country.name.common,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Update',
                  onPressed: () => _openUpdateForm(country),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: () => _deleteCountry(country.name.common),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // ── Details ──
            _infoRow(Icons.flag, 'Official', country.name.official),
            _infoRow(
              Icons.location_city,
              'Capital',
              country.capitals.isEmpty ? 'N/A' : country.capitals.join(', '),
            ),
            _infoRow(Icons.attach_money, 'Currency', currencyText),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries CRUD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload from API',
            onPressed: _loadCountries,
          ),
        ],
      ),
      body: () {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_errorMessage != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadCountries,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (_countries.isEmpty) {
          return const Center(child: Text('No countries found.'));
        }
        return ListView.builder(
          itemCount: _countries.length,
          itemBuilder: (_, i) => _buildCountryCard(_countries[i]),
        );
      }(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Country'),
      ),
    );
  }
}
