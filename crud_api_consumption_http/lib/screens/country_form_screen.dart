import 'package:crud_api_consumption_http/models/country.dart';
import 'package:crud_api_consumption_http/models/currency.dart';
import 'package:crud_api_consumption_http/models/name.dart';
import 'package:crud_api_consumption_http/models/native_name.dart';
import 'package:crud_api_consumption_http/services/api_service.dart';
import 'package:flutter/material.dart';

enum FormMode { create, update }

class CountryFormScreen extends StatefulWidget {
  final FormMode mode;
  final Country? existingCountry;

  const CountryFormScreen({
    super.key,
    required this.mode,
    this.existingCountry,
  });

  @override
  State<CountryFormScreen> createState() => _CountryFormScreenState();
}

class _CountryFormScreenState extends State<CountryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // ── Name fields ──────────────────────────────
  late final TextEditingController _commonNameCtrl;
  late final TextEditingController _officialNameCtrl;

  // ── Native name fields (single entry) ────────
  late final TextEditingController _nativeLangCodeCtrl;
  late final TextEditingController _nativeOfficialCtrl;
  late final TextEditingController _nativeCommonCtrl;

  // ── Currency fields (single entry) ───────────
  late final TextEditingController _currencyCodeCtrl;
  late final TextEditingController _currencyNameCtrl;
  late final TextEditingController _currencySymbolCtrl;

  // ── Capital ──────────────────────────────────
  late final TextEditingController _capitalCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCountry;

    // Pre-fill for update mode, empty for create mode
    _commonNameCtrl = TextEditingController(text: c?.name.common ?? '');
    _officialNameCtrl = TextEditingController(text: c?.name.official ?? '');

    // Native name – take first entry if present
    final firstNative = c?.name.nativeName.entries.firstOrNull;
    _nativeLangCodeCtrl =
        TextEditingController(text: firstNative?.key ?? '');
    _nativeOfficialCtrl =
        TextEditingController(text: firstNative?.value.official ?? '');
    _nativeCommonCtrl =
        TextEditingController(text: firstNative?.value.common ?? '');

    // Currency – take first entry if present
    final firstCurrency = c?.currency.entries.firstOrNull;
    _currencyCodeCtrl =
        TextEditingController(text: firstCurrency?.key ?? '');
    _currencyNameCtrl =
        TextEditingController(text: firstCurrency?.value.name ?? '');
    _currencySymbolCtrl =
        TextEditingController(text: firstCurrency?.value.symbol ?? '');

    _capitalCtrl = TextEditingController(
      text: (c?.capitals.isNotEmpty ?? false) ? c!.capitals.first : '',
    );
  }

  @override
  void dispose() {
    _commonNameCtrl.dispose();
    _officialNameCtrl.dispose();
    _nativeLangCodeCtrl.dispose();
    _nativeOfficialCtrl.dispose();
    _nativeCommonCtrl.dispose();
    _currencyCodeCtrl.dispose();
    _currencyNameCtrl.dispose();
    _currencySymbolCtrl.dispose();
    _capitalCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Build Country from form fields
  // ──────────────────────────────────────────────
  Country _buildCountryFromForm() {
    final nativeLangCode = _nativeLangCodeCtrl.text.trim();
    final nativeMap = nativeLangCode.isNotEmpty
        ? {
            nativeLangCode: NativeName(
              official: _nativeOfficialCtrl.text.trim(),
              common: _nativeCommonCtrl.text.trim(),
            ),
          }
        : <String, NativeName>{};

    final currencyCode = _currencyCodeCtrl.text.trim();
    final currencyMap = currencyCode.isNotEmpty
        ? {
            currencyCode: Currency(
              name: _currencyNameCtrl.text.trim(),
              symbol: _currencySymbolCtrl.text.trim(),
            ),
          }
        : <String, Currency>{};

    final capital = _capitalCtrl.text.trim();

    return Country(
      name: Name(
        common: _commonNameCtrl.text.trim(),
        official: _officialNameCtrl.text.trim(),
        nativeName: nativeMap,
      ),
      currency: currencyMap,
      capitals: capital.isNotEmpty ? [capital] : [],
    );
  }

  // ──────────────────────────────────────────────
  // Submit
  // ──────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final country = _buildCountryFromForm();
      Country result;

      if (widget.mode == FormMode.create) {
        result = await ApiServices.createCountry(country);
      } else {
        result = await ApiServices.updateCountry(
          widget.existingCountry!.name.common,
          country,
        );
      }

      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isCreate = widget.mode == FormMode.create;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCreate ? 'Add Country' : 'Update Country'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader('Name'),
              _field(
                controller: _commonNameCtrl,
                label: 'Common Name',
                hint: 'e.g. Ethiopia',
                required: true,
              ),
              _field(
                controller: _officialNameCtrl,
                label: 'Official Name',
                hint: 'e.g. Federal Democratic Republic of Ethiopia',
                required: true,
              ),
              const SizedBox(height: 12),
              _sectionHeader('Native Name (first entry)'),
              _field(
                controller: _nativeLangCodeCtrl,
                label: 'Language Code',
                hint: 'e.g. amh',
              ),
              _field(
                controller: _nativeOfficialCtrl,
                label: 'Native Official Name',
                hint: 'e.g. የኢትዮጵያ ፌዴራላዊ ዲሞክራሲያዊ ሪፐብሊክ',
              ),
              _field(
                controller: _nativeCommonCtrl,
                label: 'Native Common Name',
                hint: 'e.g. ኢትዮጵያ',
              ),
              const SizedBox(height: 12),
              _sectionHeader('Currency (first entry)'),
              _field(
                controller: _currencyCodeCtrl,
                label: 'Currency Code',
                hint: 'e.g. ETB',
              ),
              _field(
                controller: _currencyNameCtrl,
                label: 'Currency Name',
                hint: 'e.g. Ethiopian birr',
              ),
              _field(
                controller: _currencySymbolCtrl,
                label: 'Currency Symbol',
                hint: 'e.g. Br',
              ),
              const SizedBox(height: 12),
              _sectionHeader('Capital'),
              _field(
                controller: _capitalCtrl,
                label: 'Capital City',
                hint: 'e.g. Addis Ababa',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isCreate ? 'Create Country' : 'Update Country',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: required
            ? (value) =>
                (value == null || value.trim().isEmpty) ? '$label is required' : null
            : null,
      ),
    );
  }
}
